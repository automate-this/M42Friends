This script was created for integrating Zabbix Monitoring into the M42 Ticket system.

It accepts two arguments, subject and description, parses the description for the hostname of the affected host from the zabbix notification, and creates an incident with the subject, description and affected asset.