
#- - - - - - ->
#
# Script  : SUND-User-DISABLED-GROUPS.ps1
# Runs    : Saturdays 20:00 CET Task Scheduler ps2008schedule
# Login   : 
# Purpose : Removes Group membership from user objects in OU=Disabled,OU=Domain Users,DC=sund..
# Author  : 
# Input   : SUND-Disabled-Users-SET-1.csv
# From    : OU=Disabled,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk
# Output  : $script:logdato-Groups-DISABLED-SUND-Users.csv
# Mail    : $script:logdato-Groups-DISABLED-SUND-Users.csv
# Need    : 
# To Do   : 
#           
#
# <- - - - - - -


function Initialize-Script-Disabled {

Set-StrictMode -Version 1.0 # latest or 2.0

#- - - - - - ->
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

# <- - - - - - -

# Set-location 'C:\create'

$script:logdato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()

$script:logdato | out-file ".\$script:logdato-Groups-DISABLED-SUND-Users.csv" -Append

Start-Transcript -Path ".\$script:logdato-transcript-DISABLED-SUND-Users.log"

} # end

function LogCloudData {

BEGIN {}

PROCESS {

Get-ADUser -filter { (msDS-cloudExtensionAttribute6 -ne "$null") } -Properties * -SearchBase 'OU=Disabled,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,msDS-cloudExtensionAttribute3,msDS-cloudExtensionAttribute4,msDS-cloudExtensionAttribute5,msDS-cloudExtensionAttribute6 | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\$script:logdato-SUND-Disabled-Users.csv" -append

} # end process

} # end

function RemoveTextSeparator {

BEGIN {}

PROCESS {

Get-Content ".\$script:logdato-SUND-Disabled-Users.csv" | ForEach-Object {$_ -replace '"','' } | `
Set-Content ".\SUND-Disabled-Users-SET.csv" -Encoding UTF8

} # end process

} # end

function RemoveFirstLine {

BEGIN {}

PROCESS {

Get-Content .\SUND-Disabled-Users-SET.csv | Select-Object -Skip 1 | Out-File .\SUND-Disabled-Users-SET-1.csv -Encoding utf8

} # end process

} # end

function Test-InputFile {

$testcsv = Test-Path '.\SUND-Disabled-Users-SET-1.csv'
if ($testcsv -eq $false)
{
write-host -foregroundcolor red 'SUND-Disabled-Users-SET-1.csv is missing'

MoveFilesToOld # function

}

} # end

function ForEach-ClearCloud {

BEGIN {}

PROCESS {

$script:newAry = $_.split(',')

$script:USERNAME = $script:newAry[0]

Get-ADUser -Identity $script:USERNAME -Properties * | set-aduser -clear msDS-cloudExtensionAttribute6, ProfilePath -CannotChangePassword $true -Department "Disabled"

} # end process

} # end

function ForEach-DisabledUser {

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

function LIST-Groups-From-Disabled {

"------" >> ".\.\$script:logdato-Groups-DISABLED-SUND-Users.csv"
"$script:USERNAME" >> ".\.\$script:logdato-Groups-DISABLED-SUND-Users.csv"

$grupper = (Get-ADUser -Identity $script:USERNAME -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf `
>> ".\.\$script:logdato-Groups-DISABLED-SUND-Users.csv"

} # end

function REMOVE-Groups-From-Disabled {

foreach ($script:group in (Get-ADUser -Identity "$script:USERNAME" -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf) {   remove-ADGroupMember -Identity $script:group -Members "$script:USERNAME" -Confirm:$false; }

} # end

function sendmail-BCCMail {

$MailBody = " `
 `
DISABLED users GROUPS $script:logdato `
 `
 ` 
This mail is automaticaly created, please do not respond."  

$params = @{'To'='BCC-Mail@sund.ku.dk'
'From'='do-not-reply@sund.ku.dk'
          'Subject'="$script:logdato-Groups-DISABLED-SUND-Users.csv"
          'Body'="$MailBody"
          'Attachments'=".\$script:logdato-Groups-DISABLED-SUND-Users.csv"
          'SMTPServer'='smtpgw.sund.root.ku.dk'}

Send-MailMessage @params -Encoding UTF8

} # end

function MoveFilesToOld {

BEGIN {}

PROCESS {

Stop-Transcript

Move-Item '.\SUND-Disabled-Users-SET.csv' -Destination ".\DATA\$script:logdato-SUND-Disabled-Users-SET.csv"

Move-Item '.\SUND-Disabled-Users-SET-1.csv' -Destination ".\DATA\$script:logdato-SUND-Disabled-Users-SET-1.csv"

Move-Item ".\$script:logdato*.*" -Destination ".\DATA\"

exit;

} # end process

} # end


### Entry point ###


Initialize-Script-Disabled # function

LogCloudData # function

RemoveTextSeparator # function

RemoveFirstLine # function

Test-InputFile # function

Get-Content -Path '.\SUND-Disabled-Users-SET-1.csv' | ForEach-ClearCloud

Get-Content -Path '.\SUND-Disabled-Users-SET-1.csv' | ForEach-DisabledUser -FunctionName "LIST-Groups-From-Disabled"

Get-Content -Path '.\SUND-Disabled-Users-SET-1.csv' | ForEach-DisabledUser -FunctionName "REMOVE-Groups-From-Disabled"

sendmail-BCCMail # function

MoveFilesToOld # function
