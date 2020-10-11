
# poshwebserver
Simple Webserver based on Powershell for VMware vCenter and AWS
Note: This project is WorkInProgress and code is under refactoring and could radically change form a release to another.

Using this WebServer it's possible:
* serve html, css, js and images
* Execute script with params via GET /api/script?filename=...&params=....: 
  * filename is the relative or absolute path of the script
  * params contains all params in a single string with the following format: -param value
  * Script must not be interactive (any mandatory params must passed by params value in the querystring)
* List all ps1 script in directory GET /api/list_scripts
  * path it the path where list all scripts
  * TODO: Improve with params lists
* Execute vCenter Login via GET /api/connect_vcenter (WIP)
  * Specify VC_SERVER, VC_USER, VC_PASSWORD in Template.ps1 file
  * TODO: Cerate and store credentials in a keystore
* Other options:
  * logs GET /log
  * start time GET /starttime
  * current time GET /time
  * status GET /status
  * quit GET /quit

Without specification webserver is binding port 8080 on localhost. it's possible specify an alternative IP:port simply specify them as argoument: Start-Webserver.ps1 "http://<ip>:<port>/"

# TODO
- Improve OOP (use static class for template with tpl files)
- AWS and vCenter Keystore and profiles and with the following APIs
  -  Store 
  -  Check
  -  Login
  -  Logout

# Notes and Thanks
Project Idea and First Author: Markus Scholtes, 2016-10-22 (Thank you!)
Modified by: Lino Telera, 2017-08-29
Refactoring started by: Lino Telera 2020-10-01