import ballerinax/github.webhook as webhook;
import ballerinax/twilio;
import ballerina/websub;

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

