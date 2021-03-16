import ballerinax/github.webhook as webhook;
import ballerinax/googleapis_sheets as sheets;
import ballerina/http;
import ballerina/websub;

// google sheet configuration parameters
configurable http:OAuth2DirectTokenConfig & readonly directTokenConfig = ?;
configurable string & readonly sheets_spreadsheet_id = ?;
configurable string & readonly sheets_worksheet_name = ?;

sheets:SpreadsheetConfiguration spreadsheetConfig = {
    oauthClientConfig: directTokenConfig
};

// Initialize the Spreadsheet Client
sheets:Client spreadsheetClient = check new (spreadsheetConfig);

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
    remote function onPush(webhook:PushEvent event) returns error? {
        // Set Spreadsheet Headings
        (string)[] headerValues = [COMMIT_AUTHOR_NAME, COMMIT_AUTHOR_EMAIL, COMMIT_MESSAGE, COMMIT_URL, 
            REPOSITORY_NAME, REPOSITORY_URL];
        var headers = spreadsheetClient->getRow(sheets_spreadsheet_id, sheets_worksheet_name, 1);
        if (headers == []){
            check spreadsheetClient->appendRowToSheet(sheets_spreadsheet_id, 
                sheets_worksheet_name, headerValues);
        }

        foreach var item in event.commits {
            (int|string|float)[] values = [item.author.name, item.author.email, item.message, item.url, 
                event.repository.name, event.repository.url];
            check spreadsheetClient->appendRowToSheet(sheets_spreadsheet_id, 
                sheets_worksheet_name, values);
        }                 
    }
}
