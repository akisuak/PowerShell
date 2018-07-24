
#- - - - - - ->
#
# Script  : create-credential-esba-psscheduled.ps1
# Runs    : Manually psscheduled
# Login   : 
# Purpose : Creates a "credential" file to secure the sund\lsh369a password.
# Author  : 
# Input   : Read-Host
# From    : 
# Output  : oracle-esba-psscheduled.credential
# Mail    : 
# Need    : Can only be used on the server where it was created.
# To Do   :
#           
#
# <- - - - - - -


$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

read-host -prompt "Password for esba" -assecurestring | convertfrom-securestring | out-file .\oracle-esba-psscheduled.credential

# try get-content .\password.txt

