import ballerinax/github.webhook as webhook;
import ballerinax/googleapis_sheets as sheets;
import ballerina/log;
import ballerina/websub;

// Spreadsheet Header Constants
const string COMMIT_AUTHOR_NAME = "Commit Author Name";
const string COMMIT_AUTHOR_EMAIL = "Commit Author Email";
const string COMMIT_MESSAGE = "Commit Message";
const string COMMIT_URL = "Commit URL";
const string REPOSITORY_NAME = "Repository Name";
const string REPOSITORY_URL = "Repository URL";

// google sheet configuration parameters
configurable string sheets_refreshToken = ?;
configurable string sheets_clientId = ?;
configurable string sheets_clientSecret = ?;
configurable string sheets_spreadsheet_id = ?;
configurable string sheets_worksheet_name = ?;

sheets:SpreadsheetConfiguration spreadsheetConfig = {
    oauthClientConfig: {
        clientId: sheets_clientId,
        clientSecret: sheets_clientSecret,
        refreshUrl: sheets:REFRESH_URL,
        refreshToken: sheets_refreshToken
    }
};

// Initialize the Spreadsheet Client
sheets:Client spreadsheetClient = check new (spreadsheetConfig);

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
    remote function onPush(webhook:PushEvent event) returns webhook:Acknowledgement? {
        log:print("Received push-event-message ", eventPayload = event);
        // Set Spreadsheet Headings
        (string)[] headerValues = [COMMIT_AUTHOR_NAME, COMMIT_AUTHOR_EMAIL, COMMIT_MESSAGE, COMMIT_URL, 
            REPOSITORY_NAME, REPOSITORY_URL];
        var headers = spreadsheetClient->getRow(sheets_spreadsheet_id, sheets_worksheet_name, 1);
        if (headers == []){
            error? headerAppendResult = spreadsheetClient->appendRowToSheet(sheets_spreadsheet_id, 
                sheets_worksheet_name, headerValues);
            if (headerAppendResult is error) {
                log:printError(headerAppendResult.message());
            }
        }

        foreach var item in event.commits {
            (int|string|float)[] values = [item.author.name, item.author.email, item.message, item.url, 
                event.repository.name, event.repository.url];
            error? append = spreadsheetClient->appendRowToSheet(sheets_spreadsheet_id, 
                sheets_worksheet_name, values);
            if (append is error) {
                log:printError(append.message());
            }
        }                 
    }
}
