import ballerinax/github.webhook as webhook;
import ballerina/http;
import ballerinax/twilio;
import ballerina/websub;

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
    remote function onReleased(webhook:ReleaseEvent event) returns error? {
        webhook:Release releaseInfo = event.release; 
        check sendMessageForNewRelease(releaseInfo);
    }

    remote function onReleaseEdited(webhook:ReleaseEvent event) returns error? {
        webhook:Release releaseInfo = event.release; 
        check sendMessageForNewRelease(releaseInfo);
    }
}

function sendMessageForNewRelease(webhook:Release release) returns error? {
    (string)[] releaseKeys = [RELEASE_URL, RELEASE_TAG_NAME, RELEASE_NAME, RELEASE_DESCRIPTION];
    string message = "Github new release available! \n";

    foreach var releaseKey in releaseKeys {
        if (release.hasKey(releaseKey)) {
            message = message + releaseKey + " : " + release.get(releaseKey).toString() + "\n";  
        }   
    }

    twilio:SmsResponse result = check twilioClient->sendSms(from_mobile, to_mobile, message);
}

