
#- - - - - - ->
#
# Script  : SUND-User-Get-SPECIAL-GROUPS.ps1
# Runs    : Every Saturday 22:00 CET Task Scheduler ps2008schedule
# Login   : 
# Purpose : Logging group memberships
# Author  : 
# Input   : SPECIAL-SUND-GROUPS-SET-1.csv
# From    : OU=Administrators,OU=Domain Special,DC=sund,DC=root,DC=ku,DC=dk
# Output  : $script:logdato-SUND-Get-SPECIAL-GROUPS.csv
#         : $script:logdato-Merge-SPECIAL-With-Groups-DB.csv (not used)
# Mail    : 
# Need    : 
# To Do   : 
#           
#
# <- - - - - - -


function Initialize-Get-SPECIAL-GROUPS {

Set-StrictMode -Version 1.0 # latest or 2.0

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

$script:logdato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()

$script:logdato | out-file ".\$script:logdato-SUND-GET-SPECIAL-GROUPS.csv" -Append

Start-Transcript -Path ".\$script:logdato-transcript-SPECIAL-SUND-GROUPS.log"

} # end

function LogCloudData {

BEGIN {}

PROCESS {

Get-ADUser -filter * -Properties * -SearchBase 'OU=Administrators,OU=Domain Special,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,msDS-cloudExtensionAttribute3,msDS-cloudExtensionAttribute4,msDS-cloudExtensionAttribute5,msDS-cloudExtensionAttribute6 | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\$script:logdato-SPECIAL-SUND-GROUPS.csv" -append

} # end process

} # end

function RemoveTextSeparator {

BEGIN {}

PROCESS {

Get-Content ".\$script:logdato-SPECIAL-SUND-GROUPS.csv" | ForEach-Object {$_ -replace '"','' } | `
Set-Content ".\SPECIAL-SUND-GROUPS-SET.csv" -Encoding UTF8

} # end process

} # end

function RemoveFirstLine {

BEGIN {}

PROCESS {

Get-Content .\SPECIAL-SUND-GROUPS-SET.csv | Select-Object -Skip 1 | Out-File .\SPECIAL-SUND-GROUPS-SET-1.csv -Encoding utf8

} # end process

} # end

function Test-InputFile {

$testcsv = Test-Path '.\SPECIAL-SUND-GROUPS-SET-1.csv'
if ($testcsv -eq $false)
{
write-host -foregroundcolor red 'SPECIAL-SUND-GROUPS-SET-1.csv is missing'

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

} # end function

function LIST-SUND-Get-SPECIAL-GROUPS {

"------" >> ".\$script:logdato-SUND-Get-SPECIAL-GROUPS.csv"
"$script:USERNAME" >> ".\$script:logdato-SUND-Get-SPECIAL-GROUPS.csv"

$grupper = (Get-ADUser -Identity $script:USERNAME -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf `
>> ".\$script:logdato-SUND-Get-SPECIAL-GROUPS.csv"

} # end function

function Prepare-For-Masterfile {

BEGIN {$script:tempary = ''}

PROCESS {

$script:CurrentUserData = "$_"

If ($_ -eq '------') {

"$script:tempary;$script:logdato" >>  ".\$script:logdato-Merge-SPECIAL-With-Groups-DB.csv" 

$script:tempary = ''

} 
else {
$script:tempary = "$script:tempary" + "$_;"

}


} # end process

} # end function

function sendmail-BCCMail {

$MailBody = " `
 `
SPECIAL users GROUPS $script:logdato `
 `
 ` 
This mail is automaticaly created, please do not respond."  

$params = @{'To'='BCC-Mail@sund.ku.dk'
'From'='do-not-reply@sund.ku.dk'
          'Subject'="$script:logdato-SUND-Get-SPECIAL-GROUPS.csv"
          'Body'="$MailBody"
          'Attachments'=".\$script:logdato-SUND-Get-SPECIAL-GROUPS.csv"
          'SMTPServer'='smtpgw.sund.root.ku.dk'}

Send-MailMessage @params -Encoding UTF8

} # end

function MoveFilesToOld {

param()

Stop-Transcript

Move-Item ".\$script:logdato*.*" -Destination ".\DATA\"

Move-Item '.\SPECIAL-SUND-GROUPS-SET.csv' -Destination ".\DATA\$script:logdato-SPECIAL-SUND-GROUPS-SET.csv"

Move-Item '.\SPECIAL-SUND-GROUPS-SET-1.csv' -Destination ".\DATA\$script:logdato-SPECIAL-SUND-GROUPS-SET-1.csv"

exit;

} # end function Stop


### Entry point ###


Initialize-Get-SPECIAL-GROUPS # function

LogCloudData # function

RemoveTextSeparator # function

RemoveFirstLine # function

Test-InputFile # function

Get-Content -Path '.\SPECIAL-SUND-GROUPS-SET-1.csv' | ForEach-SUND-User -FunctionName "LIST-SUND-Get-SPECIAL-GROUPS"

# Get-Content -Path ".\$script:logdato-SUND-Get-SPECIAL-GROUPS.csv" | Prepare-For-Masterfile

sendmail-BCCMail # function

MoveFilesToOld # function
