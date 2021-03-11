import ballerinax/github.webhook as webhook;
import ballerinax/googleapis_sheets as sheets;
import ballerina/websub;

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
