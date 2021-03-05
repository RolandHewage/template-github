# Send Twilio sms when new release is made in Github

## Intergration use case

At the execution of this template, each time a new release is made in github or when the release is updated, A Twilio sms containing infomation about the 
release is sent to a given mobile number. 

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
   <td>Twilio Basic API
   </td>
   <td>2010-04-01
   </td>
  </tr>
</table>


## Pre-requisites

* Download and install [Ballerina](https://ballerinalang.org/downloads/).
* Github account
* Twilio account with sms capable phone number
* Ballerina connectors for Github and Twilio which will be automatically downloaded when building 
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


### Setup Twilio configurations
Create a [Twilio developer account](https://www.twilio.com/). 

1. Create a Twilio project with SMS capabilities.
2. Obtain the Account Sid and Auth Token from the project dashboard.
3. Obtain the phone number from the project dashboard and set as the value of the `from_mobile` variable in the `Config.toml`.
4. Give a mobile number where the SMS should be send as the value of the `to_mobile` variable in the `Config.toml`.
5. Once you obtained all configurations, Replace "" in the `Config.toml` file with your data.

### Config.toml 

#### ballerinax/github related configurations 

accessToken = ""  
githubTopic = ""  
githubSecret = ""  
githubCallback = ""  

#### ballerinax/twilio related configurations  

account_sid = ""  
auth_token = ""  
from_mobile = ""  
to_mobile = ""  

## Running the template

1. First you need to build the integration template and create the executable binary. Run the following command from the 
root directory of the integration template. 
`$ bal build`. 

2. Then you can run the integration binary with the following command. 
`$ bal run /target/bin/github_new_release_to_twilio_sms.jar`. 

3. Now you can make a new release in Github Account and observe that integration template runtime has received the event 
notification for the new release.

4. You can check the SMS received to verify that information about the new github release. 


