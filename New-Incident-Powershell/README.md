This script was created for integrating Zabbix Monitoring into the M42 Ticket system.

It accepts two arguments, subject and description, parses the description for the hostname of the affected host from the zabbix notification, and creates an incident with the subject, description and affected asset.

You have to change these variables according to your setup:
$apitoken = ""
$baseurl = "https://my.servicestore.com/M42Services"
$userID = "" # GUID of the M42 API User