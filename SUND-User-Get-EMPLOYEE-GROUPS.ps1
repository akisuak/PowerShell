
#- - - - - - ->
#
# Script  : SUND-User-Get-EMPLOYEE-GROUPS.ps1
# Runs    : Saturdays 23:00 CET Task Scheduler ps2008schedule
# Login   : 
# Purpose : Logs employee membership of AD groups
# Author  : 
# Input   : $logdato-EMPLOYEE-SUND-GROUPS-SET-1.csv
# From    : 
# Output  : $logdato-SUND-User-Get-EMPLOYEE-GROUPS.csv
# Mail    : 
# Need    : 
# To Do   : 
#           
#
# <- - - - - - -


function Initialize-Get-EMPLOYEE-GROUPS {

Set-StrictMode -Version 1.0 # latest or 2.0

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

$script:logdato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()

$script:logdato | out-file ".\$script:logdato-SUND-User-Get-EMPLOYEE-GROUPS.csv" -Append

Start-Transcript -Path ".\$script:logdato-transcript-EMPLOYEE-SUND-GROUPS.log"

} # end

function LogCloudData {

BEGIN {}

PROCESS {

Get-ADUser -filter * -Properties * -SearchBase 'OU=Employees,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,msDS-cloudExtensionAttribute3,msDS-cloudExtensionAttribute4,msDS-cloudExtensionAttribute5,msDS-cloudExtensionAttribute6 | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\$script:logdato-EMPLOYEE-SUND-GROUPS.csv" -append

} # end process

} # end

function RemoveTextSeparator {

BEGIN {}

PROCESS {

Get-Content ".\$script:logdato-EMPLOYEE-SUND-GROUPS.csv" | ForEach-Object {$_ -replace '"','' } | `
Set-Content ".\$script:logdato-EMPLOYEE-SUND-GROUPS-SET.csv" -Encoding UTF8

} # end process

} # end

function RemoveFirstLine {

BEGIN {}

PROCESS {

Get-Content ".\$script:logdato-EMPLOYEE-SUND-GROUPS-SET.csv" | Select-Object -Skip 1 | Out-File ".\$script:logdato-EMPLOYEE-SUND-GROUPS-SET-1.csv" -Encoding utf8

} # end process

} # end

function Test-InputFile {

$testcsv = Test-Path ".\$script:logdato-EMPLOYEE-SUND-GROUPS-SET-1.csv"
if ($testcsv -eq $false)
{
write-host -foregroundcolor red "$script:logdato-EMPLOYEE-SUND-GROUPS-SET-1.csv is missing"

MoveFilesToOld # function

}

} # end

function ForEach-SUND-User {

Param([string]$FunctionName) 

BEGIN {}

PROCESS {

$script:CurrentUserData = "$_"

$script:newAry = $_.split(',')

$script:USERNAME = $script:newAry[0]
$script:stedkode = $script:newAry[1]
$script:STUDIERETN = $script:newAry[2]
$script:SPOR2_KODE = $script:newAry[3]
$script:DATOTID = $script:newAry[4]
$script:FELTER = $script:newAry[5]
$script:ACTIONTYPE = $script:newAry[6]

& (Get-ChildItem "Function:$FunctionName")

} # end process

} # end

function LIST-SUND-Get-EMPLOYEE-GROUPS {

"------" >> ".\$script:logdato-SUND-User-Get-EMPLOYEE-GROUPS.csv"
"$script:USERNAME" >> ".\$script:logdato-SUND-User-Get-EMPLOYEE-GROUPS.csv"

$grupper = (Get-ADUser -Identity $script:USERNAME -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf `
>> ".\$script:logdato-SUND-User-Get-EMPLOYEE-GROUPS.csv"

} # end

function Prepare-For-Masterfile {

BEGIN {$script:tempary = ''}

PROCESS {

$script:CurrentUserData = "$_"

If ($_ -eq '------') {

"$script:tempary;$script:logdato" >>  ".\$script:logdato-Merge-EMPLOYEE-With-Groups-DB.csv" 

$script:tempary = ''

} 
else {
$script:tempary = "$script:tempary" + "$_;"

}


} # end process

} # end

function sendmail-BCCMail {

$MailBody = " `
 `
ALL users GROUPS $script:logdato `
 `
 ` 
This mail is automaticaly created, please do not respond."  

$params = @{'To'='BCC-Mail@sund.ku.dk'
'From'='do-not-reply@sund.ku.dk'
          'Subject'="$script:logdato-SUND-User-Get-EMPLOYEE-GROUPS.csv"
          'Body'="$MailBody"
          'Attachments'=".\$script:logdato-SUND-User-Get-EMPLOYEE-GROUPS.csv"
          'SMTPServer'='smtpgw.sund.root.ku.dk'}

Send-MailMessage @params -Encoding UTF8

} # end

function MoveFilesToOld {

param()

Stop-Transcript

Move-Item ".\$script:logdato*.*" -Destination ".\DATA\"

exit;

} # end


### Entry point ###


Initialize-Get-EMPLOYEE-GROUPS # function

LogCloudData # function

RemoveTextSeparator # function

RemoveFirstLine # function

Test-InputFile # function

Get-Content -Path ".\$script:logdato-EMPLOYEE-SUND-GROUPS-SET-1.csv" | ForEach-SUND-User -FunctionName "LIST-SUND-Get-EMPLOYEE-GROUPS"

sendmail-BCCMail # function

MoveFilesToOld # function
