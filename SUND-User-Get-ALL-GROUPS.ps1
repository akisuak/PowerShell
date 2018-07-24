
#- - - - - - ->
#
# Script  : SUND-User-Get-ALL-GROUPS.ps1
# Runs    : Saturdays 21:00 CET Task Scheduler ps2008schedule
# Login   : 
# Purpose : Logs membership of AD groups for both employees and students
# Author  : 
# Input   : $logdato-ALL-SUND-GROUPS.csv
# From    : 
# Output  : $logdato-SUND-User-Get-ALL-GROUPS.csv 
# Mail    : 
# Need    : 
# To Do   : function ForEach-SUND-User og function LogCloudData
#           Det er reelt kun SamAccountName der benyttes
#
#
# <- - - - - - -


function Initialize-Get-ALL-GROUPS {

Set-StrictMode -Version 1.0 # latest or 2.0

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

$script:logdato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()

$script:logdato | out-file ".\DATA\$script:logdato-SUND-User-Get-ALL-GROUPS.csv" -Append

Start-Transcript -Path ".\DATA\$script:logdato-transcript-ALL-SUND-GROUPS.log"

} # end

function LogCloudData {

BEGIN {}

PROCESS {

Get-ADUser -filter * -Properties * -SearchBase 'OU=Employees,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,msDS-cloudExtensionAttribute3,msDS-cloudExtensionAttribute4,msDS-cloudExtensionAttribute5,msDS-cloudExtensionAttribute6 | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\DATA\$script:logdato-ALL-SUND-GROUPS.csv" -append

Get-ADUser -filter * -Properties * -SearchBase 'OU=Students,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,msDS-cloudExtensionAttribute3,msDS-cloudExtensionAttribute4,msDS-cloudExtensionAttribute5,msDS-cloudExtensionAttribute6 | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\DATA\$script:logdato-ALL-SUND-GROUPS.csv" -append

} # end process

} # end

function RemoveTextSeparator {

BEGIN {}

PROCESS {

Get-Content ".\DATA\$script:logdato-ALL-SUND-GROUPS.csv" | ForEach-Object {$_ -replace '"','' } | `
Set-Content ".\DATA\$script:logdato-ALL-SUND-GROUPS-SET.csv" -Encoding UTF8

} # end process

} # end

function RemoveFirstLine {

BEGIN {}

PROCESS {

Get-Content ".\DATA\$script:logdato-ALL-SUND-GROUPS-SET.csv" | Select-Object -Skip 1 | Out-File ".\DATA\$script:logdato-ALL-SUND-GROUPS-SET-1.csv" -Encoding utf8

} # end process

} # end

function Test-InputFile {

$testcsv = Test-Path ".\DATA\$script:logdato-ALL-SUND-GROUPS-SET-1.csv"
if ($testcsv -eq $false)
{
write-host -foregroundcolor red "$script:logdato-ALL-SUND-GROUPS-SET-1.csv is missing"

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

& (Get-ChildItem "Function:$FunctionName") # -FunctionName "LIST-SUND-Get-ALL-GROUPS"

} # end process

} # end

function LIST-SUND-Get-ALL-GROUPS {

"------" >> ".\DATA\$script:logdato-SUND-User-Get-ALL-GROUPS.csv"
"$script:USERNAME" >> ".\DATA\$script:logdato-SUND-User-Get-ALL-GROUPS.csv"

$grupper = (Get-ADUser -Identity $script:USERNAME -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf `
>> ".\DATA\$script:logdato-SUND-User-Get-ALL-GROUPS.csv"

} # end

function Prepare-For-Masterfile {

BEGIN {$script:tempary = ''}

PROCESS {

$script:CurrentUserData = "$_"

If ($_ -eq '------') {

"$script:tempary;$script:logdato" >>  ".\DATA\$script:logdato-Merge-ALL-With-Groups-DB.csv" 

$script:tempary = ''

} 
else {
$script:tempary = "$script:tempary" + "$_;"

}


} # end process

} # end Not Used

function sendmail-BCCMail {

$MailBody = " `
 `
ALL users GROUPS $script:logdato `
 `
 ` 
This mail is automaticaly created, please do not respond."  

$params = @{'To'='BCC-Mail@sund.ku.dk'
'From'='do-not-reply@sund.ku.dk'
          'Subject'="$script:logdato-SUND-User-Get-ALL-GROUPS.csv"
          'Body'="$MailBody"
          'Attachments'=".\DATA\$script:logdato-SUND-User-Get-ALL-GROUPS.csv"
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


Initialize-Get-ALL-GROUPS # function

LogCloudData # function

RemoveTextSeparator # function

RemoveFirstLine # function

Test-InputFile # function

Get-Content -Path ".\DATA\$script:logdato-ALL-SUND-GROUPS-SET-1.csv" | ForEach-SUND-User -FunctionName "LIST-SUND-Get-ALL-GROUPS"

sendmail-BCCMail # function

MoveFilesToOld # function
