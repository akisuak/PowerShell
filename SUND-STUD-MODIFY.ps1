
#- - - - - - ->
#
# Script  : SUND-STUD-MODIFY.ps1
# Runs    : Every day 20:00 CET Task Scheduler psscheduled
# Login   : 
# Purpose : Add security-groups from template user
# Author  : 
# Input   : MODIFY-SUND-Students-SET-1.csv
# From    : SUND-Students-Search-AD-for-IDM-Changes.ps1
# Output  : $script:logdato-Groups-MODIFY-Students.csv
# Mail    : 
# Need    : FARMAcodes.txt, ODONTcodes.txt, SKTcodes.txt, SUNDcodes.txt
# To Do   :
#           
#
# <- - - - - - -


function Initialize-ScriptStudent {

Set-StrictMode -Version 1.0 # latest or 2.0

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

# Set-location 'C:\create'

$script:logdato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()

$script:logdato | out-file ".\$script:logdato-Groups-MODIFY-Students.csv" -Append

Start-Transcript -Path ".\$script:logdato-transcript-MODIFY-stud.log"

$script:FARMAcodes = "SFAA00001T","SMDM00001T","SMIM00001T","SPRM00001T","SLVK00001T","SFVK00001T","SMCK00001T"
$script:ODONTcodes = "SODA00001T"
$script:SKTcodes = "PTPB00001T","PTPF00001T","PKLA00001T"
$script:SUNDcodes = "NMBA00001T;PODA00001T;PTPB00001T;SCAM00001T;SDMM00001T;SFAA00001T;SFOA00001T;SFVK00001T;SGLA00001T;SHSM00001T;SHUA00001T;SINM00001T;SITA00001T;SLVK00001T;SMCK00001T;SMEA00001T;SMIM00001T;SMTA00001T;SODA00001T;SPRM00001T;SPUM00001T;SSSF00001T;SSUK00001T;SVEA00001T;SVEA00002T;GÆST-SUND;ÅU-SUND"

} # end function

function Test-InputFilesStudent {

$script:testcreate = Test-Path '.\MODIFY-SUND-Students-SET-1.csv'
if ($script:testcreate -eq $false) {
write-host -foregroundcolor red 'MODIFY-SUND-Students-SET-1.csv missing'
Stop-ScriptZipData
} # end if

} # end function

function ForEach-StudentADuser {

Param([string]$FunctionName) 

BEGIN {}

PROCESS {

$script:CurrentUserData = "$_"

$script:newAry = $_.split(',')

$script:USERNAME = $script:newAry[0]
$script:STEDKODE = $script:newAry[1]
$script:STUDIERETN = $script:newAry[2]
$script:SPOR2_KODE = $script:newAry[3]
$script:DATOTID = $script:newAry[4]
$script:FELTER = $script:newAry[5]
$script:ACTIONTYPE = $script:newAry[6]

$script:StudKode = $script:STUDIERETN.split(';')
$script:STUDIE0 =  $script:StudKode[0]
$script:STUDIE1 =  $script:StudKode[1]

Get-ADUser -Identity $script:USERNAME -Properties * | set-aduser -Department " "

& (Get-ChildItem "Function:$FunctionName")

} # end process

END {}

} # end function

function Get-STUDIERETNcodes {

if (($script:FARMAcodes -ccontains $script:STUDIE0) -or ($script:FARMAcodes -ccontains $script:STUDIE1)) {
foreach ($group in (Get-ADUser -Identity "farmastud" -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf) {   Add-ADGroupMember -Identity $group -Members "$script:USERNAME"; }
Get-ADUser -Identity $script:USERNAME | Set-ADUser -ProfilePath '\\sund.root.ku.dk\NETLOGON\Stud\profile\default'} # end if

elseif (($script:ODONTcodes -ccontains $script:STUDIE0) -or ($script:ODONTcodes -ccontains $script:STUDIE1)) {
foreach ($group in (Get-ADUser -Identity "odontstud" -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf) {   Add-ADGroupMember -Identity $group -Members "$script:USERNAME"; }
Get-ADUser -Identity $script:USERNAME | Set-ADUser -clear ProfilePath} # end if

elseif (($script:SKTcodes -ccontains $script:STUDIE0) -or ($script:SKTcodes -ccontains $script:STUDIE1)) {
foreach ($group in (Get-ADUser -Identity "sktstud" -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf) {   Add-ADGroupMember -Identity $group -Members "$script:USERNAME"; }
Get-ADUser -Identity $script:USERNAME | Set-ADUser -clear ProfilePath} # end if

elseif (($script:SUNDcodes -ccontains $script:STUDIE0) -or ($script:SUNDcodes -ccontains $script:STUDIE1)) {
foreach ($group in (Get-ADUser -Identity "allstud" -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf) {   Add-ADGroupMember -Identity $group -Members "$script:USERNAME"; }
Get-ADUser -Identity $script:USERNAME | Set-ADUser -ProfilePath '\\sund.root.ku.dk\NETLOGON\Stud\profile\default'}

} # end function

function MemberOfGroups {

"------" >> ".\$script:logdato-Groups-MODIFY-Students.csv"
"$script:USERNAME" >> ".\$script:logdato-Groups-MODIFY-Students.csv"

$grupper = (Get-ADUser -Identity $script:USERNAME -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf `
>> ".\$script:logdato-Groups-MODIFY-Students.csv"

}

function sendmail-GroupsStudents {

$MailBody = " `
 `
MODIFY students GROUPS $script:logdato `
 `
 ` 
This mail is automaticaly created, please do not respond."  

$params = @{'To'='BCC-Mail@sund.ku.dk'
'From'='do-not-reply@sund.ku.dk'
          'Subject'="$script:logdato-Groups-MODIFY-Students.csv"
          'Body'="$MailBody"
          'Attachments'=".\$script:logdato-Groups-MODIFY-Students.csv"
          'SMTPServer'='smtpgw.sund.root.ku.dk'}

Send-MailMessage @params -Encoding UTF8

} # end function

function Stop-ScriptZipData {

param()

Stop-Transcript

Move-Item ".\$script:logdato*.*" -Destination ".\DATA\"

Move-Item '.\MODIFY-SUND-Students-SET-1.csv' -Destination ".\DATA\$script:logdato-MODIFY-SUND-Students-SET-1.csv"

exit;

} # end function


### Entry point ###


initialize-ScriptStudent # function

Test-InputFilesStudent # function

Get-Content -Path '.\MODIFY-SUND-Students-SET-1.csv' | ForEach-StudentADuser -FunctionName "Get-STUDIERETNcodes"

start-sleep -Seconds 60

Get-Content -Path '.\MODIFY-SUND-Students-SET-1.csv' | ForEach-StudentADuser -FunctionName "MemberOfGroups"

sendmail-GroupsStudents # function

Stop-ScriptZipData # function
