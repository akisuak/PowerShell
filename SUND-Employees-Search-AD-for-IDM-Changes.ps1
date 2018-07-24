
#- - - - - - ->
#
# Script  : SUND-Employees-Search-AD-for-IDM-Changes.ps1
# Runs    : Every day 19:30 CET Task Scheduler ps2008schedule
# Login   : 
# Purpose : Collects IDM-data from the AD msDS-cloudExtensionAttribute1-6
#           Data are later used for the 3 SUND-EMPLOYEE-CREATE/RENAME/MODIFY scripts
#           After collecting data the  AD msDS-cloudExtensionAttribute1-6 are reset
# Author  : 
# Input   : OU=Employees,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk
# From    : 
# Output  : The 3 data files CREATE/RENAME/MODIFY-SUND-employee-SET.csv
# Mail    : 
# Need    : 
# To Do   : 
#           
#
# <- - - - - - -


function Initialize-Script {

BEGIN {}

PROCESS {

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
Set-location -Path "$ScriptDir"

$script:logdato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()

Start-Transcript -Path ".\DATA\$script:logdato-transcript-Employee-IDM-Changes.log"

} # end process

} # end

function LogCloudData {

# Param([string]$FunctionName) 

BEGIN {}

PROCESS {

Get-ADUser -filter * -Properties * -SearchBase 'OU=Employees,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,msDS-cloudExtensionAttribute3,msDS-cloudExtensionAttribute4,msDS-cloudExtensionAttribute5,msDS-cloudExtensionAttribute6,Mail | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\DATA\$script:logdato-ALL-SUND-Employees.csv" -append

Get-ADUser -filter {msDS-cloudExtensionAttribute6 -eq 'MODIFY'} -Properties * -SearchBase 'OU=Employees,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,msDS-cloudExtensionAttribute3,msDS-cloudExtensionAttribute4,msDS-cloudExtensionAttribute5,msDS-cloudExtensionAttribute6 | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\DATA\$script:logdato-MODIFY-SUND-Employees.csv" -append

Get-ADUser -filter {msDS-cloudExtensionAttribute6 -eq 'RENAME'} -Properties * -SearchBase 'OU=Employees,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,msDS-cloudExtensionAttribute3,msDS-cloudExtensionAttribute4,msDS-cloudExtensionAttribute5,msDS-cloudExtensionAttribute6 | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\DATA\$script:logdato-RENAME-SUND-Employees.csv" -append

Get-ADUser -filter {msDS-cloudExtensionAttribute6 -eq 'CREATE'} -Properties * -SearchBase 'OU=Employees,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,msDS-cloudExtensionAttribute3,msDS-cloudExtensionAttribute4,msDS-cloudExtensionAttribute5,msDS-cloudExtensionAttribute6,Mail | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\DATA\$script:logdato-CREATE-SUND-Employees.csv" -append

Get-ADUser -filter {msDS-cloudExtensionAttribute6 -eq 'ENABLE'} -Properties * -SearchBase 'OU=Employees,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,msDS-cloudExtensionAttribute3,msDS-cloudExtensionAttribute4,msDS-cloudExtensionAttribute5,msDS-cloudExtensionAttribute6,Mail | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\DATA\$script:logdato-CREATE-SUND-Employees.csv" -append

} # end process

} # end

function RemoveTextSeparator {

BEGIN {}

PROCESS {

Get-Content ".\DATA\$script:logdato-MODIFY-SUND-employees.csv" | ForEach-Object {$_ -replace '"','' } | `
Set-Content ".\DATA\$script:logdato-MODIFY-SUND-employee-SET.csv" -Encoding UTF8

Get-Content ".\DATA\$script:logdato-RENAME-SUND-employees.csv" | ForEach-Object {$_ -replace '"','' } | `
Set-Content ".\DATA\$script:logdato-RENAME-SUND-employee-SET.csv" -Encoding UTF8

Get-Content ".\DATA\$script:logdato-CREATE-SUND-employees.csv" | ForEach-Object {$_ -replace '"','' } | `
Set-Content ".\DATA\$script:logdato-CREATE-SUND-employee-SET.csv" -Encoding UTF8

} # end process

} # end

function RemoveFirstLine {

BEGIN {}

PROCESS {

Get-Content ".\DATA\$script:logdato-MODIFY-SUND-employee-SET.csv" | Select-Object -Skip 1 | Out-File ".\MODIFY-SUND-employee-SET-1.csv" -Encoding utf8

Get-Content ".\DATA\$script:logdato-RENAME-SUND-employee-SET.csv" | Select-Object -Skip 1 | Out-File ".\RENAME-SUND-employee-SET-1.csv" -Encoding utf8

Get-Content ".\DATA\$script:logdato-CREATE-SUND-employee-SET.csv" | Select-Object -Skip 1 | Out-File ".\CREATE-SUND-employee-SET-1.csv" -Encoding utf8

} # end process

} # end

function ClearAttribute6 {

BEGIN {}

PROCESS {

Get-Content -Path ".\MODIFY-SUND-employee-SET-1.csv" | ForEach-EmployeeADuser

Get-Content -Path ".\RENAME-SUND-employee-SET-1.csv" | ForEach-EmployeeADuser

Get-Content -Path ".\CREATE-SUND-employee-SET-1.csv" | ForEach-EmployeeADuser

} # end process

} # end

function ForEach-EmployeeADuser {

BEGIN {}

PROCESS {

$script:newAry = $_.split(',')

$script:USERNAME = $script:newAry[0]

Get-ADUser -Identity $script:USERNAME -Properties * | set-aduser -clear msDS-cloudExtensionAttribute6, ProfilePath -CannotChangePassword $true

} # end process

} # end

# Not used any more
<#
function MoveFilesToOld {

BEGIN {}

PROCESS {

Move-Item '.\MODIFY-SUND-employee-SET.csv' -Destination ".\DATA\$script:logdato-MODIFY-SUND-employee-SET.csv"

Move-Item '.\RENAME-SUND-employee-SET.csv' -Destination ".\DATA\$script:logdato-RENAME-SUND-employee-SET.csv"

Move-Item '.\CREATE-SUND-employee-SET.csv' -Destination ".\DATA\$script:logdato-CREATE-SUND-employee-SET.csv"

Move-Item ".\$script:logdato*.*" -Destination ".\DATA\"

} # end process

} # end
#>

# Entry Point


Initialize-Script # function

LogCloudData # function

RemoveTextSeparator # function

RemoveFirstLine # function

ClearAttribute6 # function

Stop-Transcript




