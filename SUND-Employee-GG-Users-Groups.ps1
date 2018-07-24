
#- - - - - - ->
#
# Script  : SUND-Employee-GG-Users-Groups.ps1
# Runs    : Saturdays 23:00 CET Task Scheduler ps2008schedule
# Login   : 
# Purpose : Updates the msDS-cloudExtensionAttribute19
#           Is used by a SSCM query against the AD
#           Giving a rough idea of how many PC's a group have,
#           and how many that should be replaced by a new PC model.
# Author  : 
# SCCM    : 
# Input   : $logdato-Ver2-SUND-SamAccountName-Set-1.csv
# From    : Get-ADUser
# Output  : Set-ADUser -Replace @{'msDS-cloudExtensionAttribute19' = $script:GGUSERGRP}
# Mail    :
# Need    :    
#         : See ### Entry point ### for sequence information
# To Do   : 
# 
# <- - - - - - -

function Initialize-Get-ALL-GROUPS {

Set-StrictMode -Version 1.0 # latest or 2.0

# Set-location 'C:\create'

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

$script:logdato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()

Start-Transcript -Path ".\DATA\$script:logdato-transcript-Get-GG-Users-Groups.log"

} # end

function LogCloudData {

BEGIN {}

PROCESS {

Get-ADUser -filter * -Properties * -SearchBase 'OU=Employees,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName | export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\DATA\$script:logdato-Ver2-SUND-SamAccountName.csv" -append

} # end process

} # end

function RemoveTextSeparator {

BEGIN {}

PROCESS {

Get-Content ".\DATA\$script:logdato-Ver2-SUND-SamAccountName.csv" | ForEach-Object {$_ -replace '"','' } | `
Set-Content ".\DATA\$script:logdato-Ver2-SUND-SamAccountName-Set.csv" -Encoding UTF8

} # end process

} # end

function RemoveFirstLine {

BEGIN {}

PROCESS {

Get-Content ".\DATA\$script:logdato-Ver2-SUND-SamAccountName-Set.csv" | Select-Object -Skip 1 | Out-File ".\DATA\$script:logdato-Ver2-SUND-SamAccountName-Set-1.csv" -Encoding utf8

} # end process

} # end

function Test-InputFile {

$testcsv = Test-Path ".\DATA\$script:logdato-Ver2-SUND-SamAccountName-Set-1.csv"
if ($testcsv -eq $false)
{
write-host -foregroundcolor red 'Ver2-SUND-SamAccountName-Set-1.csv is missing'

MoveFilesToOld # function

}

} # end

function ForEach-SUND-User {

Param([string]$FunctionName) 

BEGIN {}

PROCESS {

$script:SamAccountName = $_

& (Get-ChildItem "Function:$FunctionName")

} # end process

} # end

function Get-ALL-SUNDS-GROUPS {

"------" >> ".\DATA\$script:logdato-Ver2-SUND-GG-Users-Group.csv"
"$script:SamAccountName" >> ".\DATA\$script:logdato-Ver2-SUND-GG-Users-Group.csv"

$grupper = (Get-ADUser -Identity $script:SamAccountName -Server "dc3.sund.root.ku.dk" -Properties MemberOf).MemberOf >> ".\DATA\$script:logdato-Ver2-SUND-GG-Users-Group.csv"

} # end

function Prepare-For-SCCMReport {

BEGIN {}

PROCESS {

[string]$Input = $_

If ($_ -eq '------') {
"$Input" >>  ".\DATA\$script:logdato-Ver2-SUND-SCCM-GG-Users-Group.csv" 
} 
elseif ($Input.length -eq 6) {
"$Input" >>  ".\DATA\$script:logdato-Ver2-SUND-SCCM-GG-Users-Group.csv"
}
elseif ($Input.contains('_GG_Users_')) {
"$Input" >>  ".\DATA\$script:logdato-Ver2-SUND-SCCM-GG-Users-Group.csv" 
}  
else {$Input = ''
}

} # end process 

} # end function

function Prepare-For-AD-Write {

BEGIN {[string]$Script:ADNavn = ""; [string]$Script:ADGruppe = ""; [string]$Script:ADData = "" ; [string]$Script:ONLYone = 'no';  }

PROCESS {

[string]$Input = $_

If ($Input -eq '------') {

"$Script:ADData" >>  ".\DATA\$script:logdato-SUND-AD-Write-Prepare-GG-Users-Group.csv"

$Script:ADData = ""; $Script:ADGruppe = ""; $Script:ADNavn = ""; $Script:ONLYone = 'no'

} 
elseif ($Input.length -eq 6) {

$Script:KUNavn = $Input

$Script:ADData = "$Script:ADData"+"$Script:KUNavn"+";"

}
elseif ($Input.contains('_GG_Users_')) {

if ($Script:ONLYone -eq 'no') {

$GroupAry = $Input.split('=')

$Script:ADGruppe = $GroupAry[1]

$Script:ADData = "$Script:ADData"+"$Script:ADGruppe"+";"

$Script:ONLYone = 'yes';
}

}  
else {

$Input = ''

}


} # end process 

} # end function

function RemoveFirstLine-WritePrepare {

BEGIN {}

PROCESS {

Get-Content -Path ".\DATA\$script:logdato-SUND-AD-Write-Prepare-GG-Users-Group.csv" | Select-Object -Skip 1 | Out-File ".\DATA\$script:logdato-SUND-AD-Write-Prepare-GG-Users-Group-1.csv" -Encoding utf8

} # end process

} # end

function Split-AND-Clean-Before-AD-Write {

BEGIN {}

PROCESS {

$script:CurrentUserData = "$_"

$script:newAry = $_.split(';')

$script:USERNAME = $script:newAry[0]
$script:GGLONG = $script:newAry[1]

$script:GGAry = $script:newAry[1].split(',')
$script:GGSHORT = $script:GGAry[0]

if ($script:GGSHORT.length -gt 5 ) {
"$script:USERNAME"+";"+"$script:GGSHORT" >>  ".\DATA\$script:logdato-Split-AND-Clean-Before-AD-Write.csv"
}

} # end process 

} # end function

function WRITE-AD-extensionAttribute {

Param() 

BEGIN {}

PROCESS {

$script:newAry = $_.split(';')

$script:USERNAME = $script:newAry[0]
$script:GGUSERGRP = $script:newAry[1]

Get-ADUser -Identity $script:USERNAME -Properties * | Set-ADUser -Replace @{'msDS-cloudExtensionAttribute19' = $script:GGUSERGRP}

} # end process

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

Get-Content -Path ".\DATA\$script:logdato-Ver2-SUND-SamAccountName-Set-1.csv" | ForEach-SUND-User -FunctionName "Get-ALL-SUNDS-GROUPS"

Get-Content -Path ".\DATA\$script:logdato-Ver2-SUND-GG-Users-Group.csv" | Prepare-For-SCCMReport

Get-Content -Path ".\DATA\$script:logdato-Ver2-SUND-SCCM-GG-Users-Group.csv" | Prepare-For-AD-Write

RemoveFirstLine-WritePrepare # function

Get-Content -Path ".\DATA\$script:logdato-SUND-AD-Write-Prepare-GG-Users-Group-1.csv" | Split-AND-Clean-Before-AD-Write

Get-Content -Path ".\DATA\$script:logdato-Split-AND-Clean-Before-AD-Write.csv" | WRITE-AD-extensionAttribute

MoveFilesToOld # function
