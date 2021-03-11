import ballerinax/github.webhook as webhook;
import ballerinax/twilio;
import ballerina/websub;
import ballerina/io;

// Twilio configuration parameters
configurable string account_sid = ?;
configurable string auth_token = ?;
configurable string from_mobile = ?;
configurable string to_mobile = ?;

twilio:TwilioConfiguration twilioConfig = {
    accountSId: account_sid,
    authToken: auth_token
};

twilio:Client twilioClient = new (twilioConfig);

// github configuration parameters
configurable string accessToken = ?;
configurable string githubTopic = ?;
configurable string githubSecret = ?;
configurable string githubCallback = ?;
configurable string issueAssigneeGithubUsername = ?;

// Initialize the Github Listener
listener webhook:Listener githubListener = new (8080);

@websub:SubscriberServiceConfig {
    target: [webhook:HUB, githubTopic],
    secret: githubSecret,
    callback: githubCallback,
    httpConfig: {
        auth: {
            token: accessToken
        }
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
