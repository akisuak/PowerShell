
#- - - - - - ->
#
# Script  : EnableUsers.ps1
# Runs    : Manually on the ps2008schedule server
# Login   : 
# Purpose : Enable users listed in the ".\disabled1.txt" file.
# Author  : 
# Input   : .\disabled1.txt
# From    : 
# Output  : Start-Transcript -Path ".\enable.log"
# Mail    : 
# Need    : 
# To Do   : 
#           
#
# <- - - - - - -


$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

Start-Transcript -Path ".\enable.log"

ForEach ($line in (Get-Content .\disabled1.txt)) {Set-ADUser -Identity $line -Enabled $true}

Stop-Transcript

