#! /usr/bin/pwsh

$subject = $args[0]
$description = $args[1]
<# For testing the regex hostname search:
$subject = @"
Problem: Free disk space is less than 10% on volume C:\
"@
$description = @"
Problem started at 11:51:37 on 2019.07.26 
Problem name: Free disk space is less than 10% on volume C:\ 
Host: myhostname
Severity: High 

Original problem ID: 274319890 
"@
#>

$apitoken = ""

$baseurl = "https://my.servicestore.com/M42Services"
$userID = "" # GUID of the M42 API User
<#
You can get the GUID directly from the Database with:
SELECT ID
  FROM [M42Production].[dbo].[SPSUserClassBase]
  WHERE LastName LIKE 'lastnameofapiuser'
#>

function Get-Accesstoken {
    param (
        [Parameter(Mandatory=$true)][string]$apitoken
    )
    $header = @{
        Authorization="Bearer $apitoken"
    }
    Invoke-RestMethod -Method Post -Uri "$baseurl/api/ApiToken/GenerateAccessTokenFromApiToken/" -Headers $header | Select-Object -ExpandProperty RawToken

}

function Get-ComputerID {
    param (
        [Parameter(Mandatory=$true)][string]$computername
    )
    $header = @{
        Authorization="Bearer $accesstoken"
    }
    Invoke-RestMethod -Method Get -Uri "$baseurl/api/data/fragments/SPSAssetclassBase?where=Name='$computername'&columns=ID" -Headers $header
}

$accesstoken = Get-Accesstoken -apitoken $apitoken

$Regex = [Regex]::new("(?<=Host: ).*")
$Match = $Regex.Match($description)
if($Match.Success)           
{           
    $computername = $Match.Value
}
else {
    $computername = ""
}

#Write-Output $computername
$computer = Get-ComputerID -computername $computername.Trim()
#Write-Output $computer

if ($computer) {
    $affectedassetID = $computer.ID
    #Write-Output $affectedassetID
    $body = @{
        "AffectedAsset"="$affectedassetID";
        "Subject"="$subject";
        "Description"="$description";
        "User"= "$userID";
        "EntryBy"="4";
    }
}
else {
    $body = @{
        "Subject"="$subject";
        "Description"="$description";
        "User"= "$userID";
        "EntryBy"="4";
    }
}

$header = @{
    Authorization="Bearer $accesstoken"
}

Invoke-RestMethod -Method Post -Uri "$baseurl/api/incident/create" -Headers $header -Body ($body|ConvertTo-Json) -ContentType "application/json"
