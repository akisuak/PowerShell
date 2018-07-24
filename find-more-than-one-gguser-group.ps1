
#- - - - - - ->
#
# Script  : find-more-than-one-gguser-group.ps1
# Runs    : Manually on the ps2008schedule server
# Login   : 
# Purpose : Look for users with more than one *_GG_User group
# Author  : 
# Input   : SUND-User-Get-EMPLOYEE-GROUPS.csv
# From    : SUND-User-Get-ALL-GROUPS.ps1
# Output  : more-than-one-gg-user-group.txt
# Mail    : 
# Need    : 
# To Do   : 
#           
#
# <- - - - - - -


# Initialize
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

$script:logdato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()

Start-Transcript -path .\$script:logdato-more-GG_Users-transcript.txt

$exist = Test-Path '.\more-than-one-gg-user-group.txt'
if ($exist-eq $true) { Remove-Item -Path '.\more-than-one-gg-user-group.txt'}

$tmp = Test-Path '.\temp.txt'
if ($tmp -eq $true) { Remove-Item -Path '.\temp.txt'}

$antalgguser = 0

#　Get-Content SUND-User-Get-EMPLOYEE-GROUPS.csv

ForEach ($line in (Get-Content .\SUND-User-Get-EMPLOYEE-GROUPS.csv)) {

if (($line.Contains("------") -and ($antalgguser -gt 1)) ) # ny bruger - gem data og nulstil
{ $antalgguser = 0; ForEach ($L in (Get-Content temp.txt)) { $L | Out-File '.\more-than-one-gg-user-group.txt' -Append};Remove-Item -Path .\temp.txt }

if ($line.Contains("------")) # ny bruger - nulstil og slet temp data
{ $antalgguser = 0; $exist = Test-Path '.\temp.txt'; if ($exist-eq $true) { Remove-Item -Path '.\temp.txt'}} 

if ($line.length -eq 6) # gem ku-brugernavn eller "------"
{ $line | Out-File '.\temp.txt' -Append } 

if ($line.contains("_GG_Users_")) 
{$antalgguser = $antalgguser+1; $line | Out-File '.\temp.txt' -Append }

}
　
Stop-Transcript 


