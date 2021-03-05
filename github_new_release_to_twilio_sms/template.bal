import ballerinax/github.webhook as webhook;
import ballerinax/twilio;
import ballerina/websub;
import ballerina/log;
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

twilio:Client twilioClient = new(twilioConfig);

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
    remote function onEventNotification(websub:ContentDistributionMessage event) {
        io:StringReader sr = new (event.content.toJsonString());
        json|error contentInfo = sr.readJson();
        if (contentInfo is json) {
            if (contentInfo.action == RELEASED || contentInfo.action == EDITED) {
                json|error releaseInfo = contentInfo.release; 
                if (releaseInfo is json) {
                    sendMessageForNewRelease(releaseInfo);
                } else {
                    log:printError(releaseInfo.message());
                }
            } 
        } else {
            log:printError(contentInfo.message());
        }
    } 
}

function sendMessageForNewRelease(json release) {
    (string)[] releaseKeys = [RELEASE_URL, RELEASE_TAG_NAME, RELEASE_NAME, RELEASE_DESCRIPTION];
    string message = "Github new release available! \n";
    map<json> releaseMap = <map<json>> release;

    foreach var releaseKey in releaseKeys {
        if (releaseMap.hasKey(releaseKey)) {
            message = message + releaseKey + " : " + releaseMap.get(releaseKey).toString() + "\n";  
        }   
    }

    var result = twilioClient->sendSms(from_mobile, to_mobile, message);
    if (result is twilio:SmsResponse) {
        log:print("SMS sent successfully for the new Github release" + "\nSMS_SID: " + result.sid.toString() + 
            "\nSMS Body: \n" + result.body.toString());
    } else {
        log:printError(result.message());
    }
}

