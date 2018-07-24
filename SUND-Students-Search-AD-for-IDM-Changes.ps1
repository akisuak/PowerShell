
#- - - - - - ->
#
# Script  : SUND-Students-Search-AD-for-IDM-Changes.ps1
# Runs    : Every day 19:00 CET Task Scheduler psscheduled
# Login   : 
# Purpose : Collects IDM-data from the AD msDS-cloudExtensionAttribute1-6
#           Data are later used for the 3 SUND-STUD-CREATE/RENAME/MODIFY scripts
#           After collecting data the AD msDS-cloudExtensionAttribute1-6 are reset 
# Author  : 
# Input   : OU=Students,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk
# From    : 
# Output  : The 3 data files SUND-STUD-CREATE/RENAME/MODIFY.csv
# Mail    : 
# Need    : 
# To Do   :
#           
#
# <- - - - - - -


function Initialize-Script {

BEGIN {}

PROCESS {

Set-StrictMode -Version 1.0 # latest or 2.0

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

$script:logdato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()

Start-Transcript -Path ".\DATA\$script:logdato-transcript-Students-IDM-Changes.log"

} # end process

} # end

function LogCloudData {

BEGIN {}

PROCESS {

Get-ADUser -filter * -Properties * -SearchBase 'OU=Students,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,msDS-cloudExtensionAttribute3,msDS-cloudExtensionAttribute4,msDS-cloudExtensionAttribute5,msDS-cloudExtensionAttribute6 | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\DATA\$script:logdato-ALL-SUND-Students.csv" -append

Get-ADUser -filter {msDS-cloudExtensionAttribute6 -eq 'MODIFY'} -Properties * -SearchBase 'OU=Students,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,msDS-cloudExtensionAttribute3,msDS-cloudExtensionAttribute4,msDS-cloudExtensionAttribute5,msDS-cloudExtensionAttribute6 | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\DATA\$script:logdato-MODIFY-SUND-Students.csv" -append

Get-ADUser -filter {msDS-cloudExtensionAttribute6 -eq 'RENAME'} -Properties * -SearchBase 'OU=Students,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,msDS-cloudExtensionAttribute3,msDS-cloudExtensionAttribute4,msDS-cloudExtensionAttribute5,msDS-cloudExtensionAttribute6 | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\DATA\$script:logdato-RENAME-SUND-Students.csv" -append

Get-ADUser -filter {msDS-cloudExtensionAttribute6 -eq 'CREATE'} -Properties * -SearchBase 'OU=Students,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,msDS-cloudExtensionAttribute3,msDS-cloudExtensionAttribute4,msDS-cloudExtensionAttribute5,msDS-cloudExtensionAttribute6 | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\DATA\$script:logdato-CREATE-SUND-Students.csv" -append

Get-ADUser -filter {msDS-cloudExtensionAttribute6 -eq 'ENABLE'} -Properties * -SearchBase 'OU=Students,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,msDS-cloudExtensionAttribute3,msDS-cloudExtensionAttribute4,msDS-cloudExtensionAttribute5,msDS-cloudExtensionAttribute6 | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\DATA\$script:logdato-CREATE-SUND-Students.csv" -append

} # end process

END {}

} # end

function RemoveTextSeparator {

BEGIN {}

PROCESS {

Get-Content ".\DATA\$script:logdato-MODIFY-SUND-Students.csv" | ForEach-Object {$_ -replace '"','' } | `
Set-Content ".\DATA\$script:logdato-MODIFY-SUND-Students-SET.csv" -Encoding UTF8

Get-Content ".\DATA\$script:logdato-RENAME-SUND-Students.csv" | ForEach-Object {$_ -replace '"','' } | `
Set-Content ".\DATA\$script:logdato-RENAME-SUND-Students-SET.csv" -Encoding UTF8

Get-Content ".\DATA\$script:logdato-CREATE-SUND-Students.csv" | ForEach-Object {$_ -replace '"','' } | `
Set-Content ".\DATA\$script:logdato-CREATE-SUND-Students-SET.csv" -Encoding UTF8

} # end process

END {}

} # end

function RemoveFirstLine {

BEGIN {}

PROCESS {

Get-Content ".\DATA\$script:logdato-MODIFY-SUND-Students-SET.csv" | Select-Object -Skip 1 | Out-File '.\MODIFY-SUND-Students-SET-1.csv' -Encoding utf8

Get-Content ".\DATA\$script:logdato-RENAME-SUND-Students-SET.csv" | Select-Object -Skip 1 | Out-File '.\RENAME-SUND-Students-SET-1.csv' -Encoding utf8

Get-Content ".\DATA\$script:logdato-CREATE-SUND-Students-SET.csv" | Select-Object -Skip 1 | Out-File '.\CREATE-SUND-Students-SET-1.csv' -Encoding utf8

} # end process

} # end

function ClearAttribute6 {

BEGIN {}

PROCESS {

Get-Content -Path '.\MODIFY-SUND-Students-SET-1.csv' | ForEach-StudentADuser

Get-Content -Path '.\RENAME-SUND-Students-SET-1.csv' | ForEach-StudentADuser

Get-Content -Path '.\CREATE-SUND-Students-SET-1.csv' | ForEach-StudentADuser

} # end process

} # end

function ForEach-StudentADuser {

BEGIN {}

PROCESS {

$script:newAry = $_.split(',')

$script:USERNAME = $script:newAry[0]

Get-ADUser -Identity $script:USERNAME -Properties * | set-aduser -clear msDS-cloudExtensionAttribute6 -CannotChangePassword $true

} # end process

END {}

} # end


# Entry Point


Initialize-Script # function

LogCloudData # function

RemoveTextSeparator # function

RemoveFirstLine # function

ClearAttribute6 # function

Stop-Transcript


