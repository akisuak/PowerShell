
#- - - - - - ->
#
# Script  : create-credential-esba-ps2008schedule.ps1
# Runs    : Manually on the ps2008schedule server
# Login   : 
# Purpose : Creates a "credential" file to secure the password of sund\lsh369a.
# Author  : 
# Input   : Read-Host
# From    : 
# Output  : oracle-esba-ps2008schedule.credential
# Mail    : 
# Need    : Can only be used on the server where it was created.
# To Do   :
#           
#
# <- - - - - - -

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

read-host -prompt "Password for esba" -assecurestring | convertfrom-securestring | out-file .\oracle-esba-ps2008schedule.credential

