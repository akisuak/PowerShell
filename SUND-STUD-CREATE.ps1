

#- - - - - - ->
#
# Script  : SUND-STUD-CREATE.ps1
# Runs    : Every day 22:00 CET psscheduled
# Login   : 
# Purpose : Add security-groups from template user
# Author  : 
# Input   : CREATE-SUND-Students-SET-1.csv
# From    : SUND-Students-Search-AD-for-IDM-Changes.ps1
# Output  : $script:logdato-Groups-CREATE-Students.csv
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

$script:logdato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()

Start-Transcript -Path ".\$script:logdato-transcript-CREATE-stud.log"

$script:logdato | out-file ".\$script:logdato-Groups-CREATE-Students.csv" -Append

$script:FARMAcodes = Get-Content -Path '.\FARMAcodes.txt'
$script:FARMAarray = $script:FARMAcodes.Split(',')

$script:ODONTcodes = Get-Content -Path '.\ODONTcodes.txt'
$script:ODONTarray = $script:ODONTcodes.Split(',')

$script:SKTcodes = Get-Content -Path '.\SKTcodes.txt'
$script:SKTarray = $script:SKTcodes.Split(',')

$script:SUNDcodes = Get-Content -Path '.\SUNDcodes.txt'
$script:SUNDarray = $script:SUNDcodes.Split(',')

} # end

function Test-InputFilesStudent {

$script:testcreate = Test-Path '.\CREATE-SUND-Students-SET-1.csv'
if ($script:testcreate -eq $false) {
write-host -foregroundcolor red 'CREATE-SUND-Students-SET-1.csv missing'
Stop-MoveData
} # end if

} # end

function ForEach-StudentADuser {

Param([string]$FunctionName) 

BEGIN {}

PROCESS {

# $script:CurrentUserData = "$_"

$script:newAry = $_.split(',')

$script:USERNAME = $script:newAry[0]
# $script:STEDKODE = $script:newAry[1]
$script:STUDIERETN = $script:newAry[2]
# $script:SPOR2_KODE = $script:newAry[3]
# $script:DATOTID = $script:newAry[4]
# $script:FELTER = $script:newAry[5]
# $script:ACTIONTYPE = $script:newAry[6]

$script:StudKode = $script:STUDIERETN.split(';')

& (Get-ChildItem "Function:$FunctionName")

} # end process

END {}

} # end

function Stop-MoveData {

param()

Stop-Transcript

Move-Item ".\$script:logdato*.*" -Destination ".\DATA\"

Move-Item '.\CREATE-SUND-Students-SET-1.csv' -Destination ".\DATA\$script:logdato-CREATE-SUND-Students-SET-1.csv"

exit;

} # end

function Get-STUDIERETNcodes {

foreach($script:element in $script:StudKode) { if ($script:FARMAarray -contains $script:element) {
foreach ($group in (Get-ADUser -Identity "farmastud" -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf) { Add-ADGroupMember -Identity $group -Members "$script:USERNAME"; }
Get-ADUser -Identity $script:USERNAME | Set-ADUser -ProfilePath '\\sund.root.ku.dk\NETLOGON\Stud\profile\default'} } # end foreach 

foreach($script:element in $script:StudKode) { if ($script:ODONTarray -contains $script:element) {
foreach ($group in (Get-ADUser -Identity "odontstud" -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf) { Add-ADGroupMember -Identity $group -Members "$script:USERNAME"; }
Get-ADUser -Identity $script:USERNAME | Set-ADUser -clear ProfilePath } } # end foreach

foreach($script:element in $script:StudKode) { if ($script:SKTarray -contains $script:element) {
foreach ($group in (Get-ADUser -Identity "sktstud" -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf) { Add-ADGroupMember -Identity $group -Members "$script:USERNAME"; }
Get-ADUser -Identity $script:USERNAME | Set-ADUser -clear ProfilePath } } # end foreach

foreach($script:element in $script:StudKode) { if ($script:SUNDarray -contains $script:element) {
foreach ($group in (Get-ADUser -Identity "allstud" -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf) { Add-ADGroupMember -Identity $group -Members "$script:USERNAME"; }
Get-ADUser -Identity $script:USERNAME | Set-ADUser -ProfilePath '\\sund.root.ku.dk\NETLOGON\Stud\profile\default' } } # end foreach

} # end function

function MemberOfGroups {

"------" >> ".\$script:logdato-Groups-CREATE-Students.csv"
"$script:USERNAME" >> ".\$script:logdato-Groups-CREATE-Students.csv"

$grupper = (Get-ADUser -Identity $script:USERNAME -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf `
>> ".\$script:logdato-Groups-CREATE-Students.csv"

} # end

function sendmail-GroupsStudents {

$MailBody = " `
 `
CREATE students GROUPS $script:logdato `
 `
 ` 
This mail is automaticaly created, please do not respond."  

$params = @{'To'='BCC-Mail@sund.ku.dk'
'From'='do-not-reply@sund.ku.dk'
          'Subject'="$script:logdato-Groups-CREATE-Students.csv"
          'Body'="$MailBody"
          'Attachments'=".\$script:logdato-Groups-CREATE-Students.csv"
          'SMTPServer'='smtpgw.sund.root.ku.dk'}

Send-MailMessage @params -Encoding UTF8

} # end


### Entry point ###


initialize-ScriptStudent # function

Test-InputFilesStudent # function

Get-Content -Path '.\CREATE-SUND-Students-SET-1.csv' | ForEach-StudentADuser -FunctionName "Get-STUDIERETNcodes"

start-sleep -Seconds 60

Get-Content -Path '.\CREATE-SUND-Students-SET-1.csv' | ForEach-StudentADuser -FunctionName "MemberOfGroups"

sendmail-GroupsStudents # function

Stop-MoveData # function
