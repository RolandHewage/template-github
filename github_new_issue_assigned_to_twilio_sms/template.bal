import ballerinax/github.webhook as webhook;
import ballerina/http;
import ballerinax/twilio;
import ballerina/websub;
import ballerina/io;

// Twilio configuration parameters
configurable twilio:TwilioConfiguration & readonly twilioConfig = ?;
configurable string & readonly from_mobile = ?;
configurable string & readonly to_mobile = ?;

// Initialize the Twilio Client
twilio:Client twilioClient = new (twilioConfig);

// github configuration parameters
configurable http:BearerTokenConfig & readonly bearerTokenConfig = ?;
configurable string & readonly githubTopic = ?;
configurable string & readonly githubSecret = ?;
configurable string & readonly githubCallback = ?;
configurable int & readonly port = ?;
configurable string & readonly issueAssigneeGithubUsername = ?;

// Initialize the Github Listener
listener webhook:Listener githubListener = new (port);

@websub:SubscriberServiceConfig {
    target: [webhook:HUB, githubTopic],
    secret: githubSecret,
    callback: githubCallback,
    httpConfig: {
        auth: bearerTokenConfig
    }
}
service /subscriber on githubListener {
    remote function onIssuesAssigned(webhook:IssuesEvent event) returns error? {
        webhook:Issue issueInfo = event.issue; 
        io:StringReader reader = new (event.issue.assignee.toJsonString());
        json issueAssignee = check reader.readJson();
        if (issueAssignee.login == issueAssigneeGithubUsername) {
            check sendMessageForNewIssueAssigned(issueInfo);
        }
    }
}

function sendMessageForNewIssueAssigned(webhook:Issue issue) returns error? {
    (string)[] issueKeys = [ISSUE_URL, ISSUE_TITLE];
    string message = "Github new issue assigned! \n";

    foreach var issueKey in issueKeys {
        if (issue.hasKey(issueKey)) {
            message = message + issueKey + " : " + issue.get(issueKey).toString() + "\n";  
        }   
    }

    twilio:SmsResponse result = check twilioClient->sendSms(from_mobile, to_mobile, message);
}
