
#- - - - - - ->
#
# Script  : SUND-EMPLOYEE-RENAME.ps1
# Runs    : Every day 21:30 CET Task Scheduler ps2008schedule
# Login   : 
# Purpose : Handels the RENAME status on user objects in AD
#           Includes users that are moved to Employees from Disabled or Students OU's
#           Removes STUD groups and creates P-drives
# Author  : 
# Input   : RENAME-SUND-Employee-SET-1.csv
# From    :
# Output  : logdato-Groups-RENAME-Employee.csv
# Mail    : 
# Need    : sund-alle-stedkoder-string.txt
#           sund-opret-ansatte-LANG-STEDKODE.xml
#           Linux-P-drev.txt
# To Do   : 
#
# <- - - - - - -


function Initialize-ScriptEmployee {

Set-StrictMode -Version 1.0 # Latest or 2.0

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

$script:SUNDStedkoder = Get-Content -Path '.\sund-alle-stedkoder-string.txt'

$script:LinuxPdrive = Get-Content -Path '.\Linux-P-drev.txt'

[xml]$script:xmldata = Get-Content -Path '.\sund-opret-ansatte-LANG-STEDKODE.xml'

$script:skarray = $script:SUNDStedkoder.Split(',')

$script:Linuxarray = $script:LinuxPdrive.Split(',')

$script:logdato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()

$script:logdato | out-file -FilePath ".\$script:logdato-Groups-RENAME-Employee.csv" -Append

$script:MailInfo = '' # Extra mail info about 333000 and 348300

Start-Transcript -Path ".\$script:logdato-transcript-employee-RENAME.log"

} # end

function Test-InputFilesEmployee {

$testdata1 = Test-Path -Path '.\RENAME-SUND-Employee-SET-1.csv'

$testdata2 = Test-Path -Path '.\sund-alle-stedkoder-string.txt'
$testdata3 = Test-Path -Path '.\sund-opret-ansatte-LANG-STEDKODE.xml'
$testdata4 = Test-Path -Path '.\Linux-P-drev.txt'

if (($testdata1 -eq $false) -or ($testdata2 -eq $false) -or ($testdata3 -eq $false)  -or ($testdata4 -eq $false)) 
{
write-host -foregroundcolor red 'One or more of the 4 input-files are missing'  
write-host -foregroundcolor red "1. $testdata1, 2. $testdata2, 3. $testdata3, 4. $testdata4 "
Stop-SaveData
}

} # end

function sendmail-GroupsEmployees {

$MailBody = " `
 `
RENAME employees GROUPS $script:logdato `
 `
 ` 
This mail is automaticaly created, please do not respond."  

$params = @{'To'='BCC-Mail@sund.ku.dk'
'From'='do-not-reply@sund.ku.dk'
          'Subject'="$script:logdato-Groups-RENAME-Employee-$script:MailInfo.csv"
          'Body'="$MailBody"
          'Attachments'="$script:logdato-Groups-RENAME-Employee.csv"
          'SMTPServer'='smtpgw.sund.root.ku.dk'}

Send-MailMessage @params -Encoding UTF8

} # end function

function ForEach-EmployeeADuser {

Param([string]$FunctionName) 

BEGIN {}

PROCESS {

# For the log
$script:CurrentUserData = "$_"

$script:newAry = $_.split(',')
$script:USERNAME = $script:newAry[0]
$script:stedkode = $script:newAry[1]
$script:Stedary = $script:stedkode.split(';')

# construct P-drive path
$script:first = $script:USERNAME.Substring(0,1).ToUpper()
$script:Pdrive = "\\sund.root.ku.dk\users\USER"+"$script:first"+"\"+"$script:USERNAME"
$script:IFSVPdrive = "\\sund.root.ku.dk\users\LINUX\ifsv\"+"$script:USERNAME"
$script:ILFPdrive = "\\sund.root.ku.dk\users\LINUX\ilf\"+"$script:USERNAME"

# init
$script:CreatePdrive = $false
$script:kopiaf = 'nogroups'
$script:IFSVILF = $false
$script:MailInfo = ''

# looks for SUND stedkoder in the skarray file. If found the CreatePdrive and Xstedkode are set 
foreach($script:element in $script:Stedary) {if ($script:skarray -contains $script:element) {$script:CreatePdrive = $true;$script:Xstedkode = "S"+$script:element;break} }

# reads the xmldata for the group-memberships user-template
if ($script:CreatePdrive -eq $true) {$script:kopiaf = $script:xmldata.root.$script:Xstedkode.kopiaf}

# IFSV Biostat and ILF BiostructuralResearch Linux users # Read Stedary once more
foreach($script:element in $script:Stedary) {
if ($script:element -eq '333000' ) {$script:Pdrive = $script:IFSVPdrive;$script:Xstedkode = 'S333000';$script:IFSVILF = $true }
elseif ($script:element -eq '348300') {$script:Pdrive = $script:ILFPdrive;$script:Xstedkode = 'S348300';$script:IFSVILF = $true }
}

# IFSV Biostat and ILF BiostructuralResearch Linux users # Read xmldata once more
if ($script:IFSVILF -eq $true) {$script:kopiaf = $script:xmldata.root.$script:Xstedkode.kopiaf; $script:MailInfo = '333000-348300'}

if (($script:IFSVILF -eq $true) -and ($script:Xstedkode -eq 'S333000')){
Set-ADUser -Identity $script:USERNAME -Replace @{'loginShell'="/bin/bash"; 'unixHomeDirectory'="%H/$script:USERNAME"; 'gidNumber'="972047585"}
}
# ; 'gecos'="$script:displayName"

if (($script:IFSVILF -eq $true) -and ($script:Xstedkode -eq 'S348300')){
Set-ADUser -Identity $script:USERNAME -Replace @{'loginShell'="/bin/bash"; 'unixHomeDirectory'="%H/$script:USERNAME"; 'gidNumber'="972089636"}
}
# ; 'gecos'="$script:displayName"

# Search for a P-drive
$script:TestPath = Test-Path -Path $script:Pdrive -PathType Container

# logging the group membership 
& (Get-ChildItem "Function:$FunctionName") # -FunctionName "MemberOfGroups"

# Copy menbership of groups from user kopiaf # This is not done in the MODIFY script
foreach ($script:group in (Get-ADUser $script:kopiaf -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf) {   Add-ADGroupMember -Identity $script:group -Members "$script:USERNAME"; }

# if no P-drive exists and a SUND stedkode is found in the skarray file
if (($script:TestPath -eq $false) -and ($script:CreatePdrive -eq $true) ) {
New-Item -type Directory -path $script:Pdrive

start-sleep -s 10

$script:WinGrant = "$script:USERNAME"+":(CI)(OI)M"

if ($script:IFSVILF -eq $false) {C:\Windows\System32\icacls.exe $script:Pdrive /GRANT $script:WinGrant}

} # end if

if ($script:Xstedkode -ne $null) {Clear-Variable Xstedkode}
if ($script:kopiaf -ne $null) {Clear-Variable kopiaf}
if ($script:stedkode -ne $null) {Clear-Variable stedkode}
if ($script:Stedary -ne $null) {Clear-Variable Stedary}
if ($script:TestPath -ne $null) {Clear-Variable TestPath}
if ($script:CreatePdrive -ne $null) {Clear-Variable CreatePdrive}
if ($script:Pdrive -ne $null) {Clear-Variable Pdrive}

} # end process

} # end function

function MemberOfGroups {

"------" >> ".\$script:logdato-Groups-RENAME-Employee.csv"

"$script:CurrentUserData" >> ".\$script:logdato-Groups-RENAME-Employee.csv" 

"$script:USERNAME" >> ".\$script:logdato-Groups-RENAME-Employee.csv"

$grupper = (Get-ADUser -Identity $script:USERNAME -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf `
>> ".\$script:logdato-Groups-RENAME-Employee.csv"

} # end function

function Stop-SaveData {

param()

Stop-Transcript

Move-Item ".\$script:logdato*.*" -Destination ".\DATA\"

Move-Item '.\RENAME-SUND-Employee-SET-1.csv' -Destination ".\DATA\$script:logdato-RENAME-SUND-Employee-SET-1.csv"

exit;

} # end function


### Script Entry Point ###


Initialize-ScriptEmployee # function

Test-InputFilesEmployee # function

Get-Content -Path '.\RENAME-SUND-Employee-SET-1.csv' | ForEach-EmployeeADuser -FunctionName "MemberOfGroups" # functions

sendmail-GroupsEmployees # function

Stop-SaveData # function
