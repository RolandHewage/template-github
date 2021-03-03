# Add rows to Google sheets spreadsheet when new commit is made in Github

## Intergration use case

At the execution of this template, each time new commmit is made in github and pushed, Google sheets spreadsheet rows 
will be added containing info about the commit. 

## Supported versions

<table>
  <tr>
   <td>Ballerina language version
   </td>
   <td>Swan Lake Alpha2
   </td>
  </tr>
  <tr>
   <td>Java development kit (JDK) 
   </td>
   <td>11
   </td>
  </tr>
  <tr>
   <td>Github REST API version
   </td>
   <td>V3
   </td>
  </tr>
  <tr>
   <td>Google sheets API version
   </td>
   <td>V4
   </td>
  </tr>
</table>


## Pre-requisites

* Download and install [Ballerina](https://ballerinalang.org/downloads/).
* Google cloud platform account
* Github account
* Ballerina connectors for Github and Google Sheets which will be automatically downloaded when building 
the application for the first time


## Configuration

### Setup Github configurations
* First obtain a [Personal access token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) or [GitHub OAuth App token](https://docs.github.com/en/developers/apps/creating-an-oauth-app).
* Next you need to create a Github repository where you want to get new commits to the google spreadsheet.
* Set the github topic in the following format. Replace the `<Github-User-Name>` with the username of the Github account &
`<Repository-Name-To-Get-Commits>` with the name of the repository you created.
`https://github.com/<Github-User-Name>/<Repository-Name-To-Get-Commits>/events/*.json`
* Then you can optionally add a github secret for signature validation.
* To setup a github callback URL, you can install [ngrok](https://ngrok.com/download) and [expose a local web server to 
the internet](https://ngrok.com/docs).
* Then start the ngork with webhook:Listener service port (8080 in this example) by using the command ./ngrok http 8080 
and obtain a public URL which expose your local service to the internet.
* Set the github callback URL which is in the format `<public-url-obtained-by-ngrok>/<name-of-the-websub-service>`
(eg: https://ea0834f44458.ngrok.io/subscriber)
* Add the accessToken, githubTopic, githubSecret and githubCallback to the config(Config.toml) file.


### Setup Google sheets configurations
Create a Google account and create a connected app by visiting [Google cloud platform APIs and services](https://console.cloud.google.com/apis/dashboard). 

1. Click library from the left side menu.
2. In the search bar enter Google sheets.
3. Then select Google sheets API and click enable button.
4. Complete OAuth consent screen setup.
5. Click `credential` tab from left side bar. In the displaying window click `create credentials` button and select 
OAuth client Id.
6. Fill the required field. Add https://developers.google.com/oauthplayground to the Redirect URI field.
7. Get clientId and secret. Put it on the config(Config.toml) file.
8. Visit https://developers.google.com/oauthplayground/ 
    Go to settings (Top right corner) -> Tick 'Use your own OAuth credentials' and insert Oauth ClientId and secret.Click close.
9. Then,complete step1 (select and authotrize API's)
10. Make sure you select https://www.googleapis.com/auth/drive & https://www.googleapis.com/auth/spreadsheets Oauth scopes.
11. Click authorize API's and You will be in step 2.
12. Exchange auth code for tokens.
13. Copy access token and refresh token. Put it on the config(Config.toml) file.

## Configuring the integration template

1. Create new spreadsheet.
2. Rename the sheet if you want.
3. Get the ID of the spreadsheet. 
Spreadsheet ID in the URL "https://docs.google.com/spreadsheets/d/" + `<spreadsheetId>` + "/edit#gid=" + `<worksheetId>` 
5. Get the sheet name
6. Once you obtained all configurations, Create `Config.toml` in root directory.
7. Replace "" in the `Config.toml` file with your data.

### Config.toml 

#### ballerinax/github related configurations 

accessToken = ""
githubTopic = ""
githubSecret = ""
githubCallback = ""

#### ballerinax/googleapis_sheet related configurations  

sheets_refreshToken = ""
sheets_clientId = ""
sheets_clientSecret = ""
sheets_refreshurl = ""
sheets_spreadsheet_id = ""
sheets_worksheet_name = ""

## Running the template

1. First you need to build the integration template and create the executable binary. Run the following command from the 
root directory of the integration template. 
`$ bal build`. 

2. Then you can run the integration binary with the following command. 
`$ bal run /target/bin/github_new_commit_to_google_sheet_row.jar`. 

3. Now you can add new commits in Github Account and observe that integration template runtime has received the event 
notification for new commits on push.

4. You can check the Google Sheet to verify that new commits are added to the Specified Sheet. 


