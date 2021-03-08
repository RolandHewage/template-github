import ballerinax/googleapis_sheets as sheets;
import ballerinax/github.webhook as webhook;
import ballerina/websub;
import ballerina/log;

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
sheets:Client spreadsheetClient = checkpanic new (spreadsheetConfig);

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
        // Set Spreadsheet Headings
        (string)[] headerValues = ["Commit Author Name", "Commit Author Email", "Commit Message", "Commit URL", 
            "Repository Name", "Repository URL"];
        var headers = spreadsheetClient->getRow(sheets_spreadsheet_id, sheets_worksheet_name, 1);
        if (headers == []){
            error? headerAppendResult = spreadsheetClient->appendRowToSheet(sheets_spreadsheet_id, 
                sheets_worksheet_name, headerValues);
            if (headerAppendResult is error) {
                log:printError(headerAppendResult.message());
            }
        }

        var payload = githubListener.getEventType(event);
        if (payload is webhook:PushEvent) {
            foreach var item in payload.commits {
                (int|string|float)[] values = [item.author.name, item.author.email, item.message, item.url, 
                    payload.repository.name, payload.repository.url];
                error? append = spreadsheetClient->appendRowToSheet(sheets_spreadsheet_id, 
                    sheets_worksheet_name, values);
                if (append is error) {
                    log:printError(append.message());
                }
            }
        }        
    } 
}
