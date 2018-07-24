
#- - - - - - ->
#
# Script  : create-credential-KID_SUND-psscheduled.ps1
# Runs    : Manually psscheduled
# Login   : 
# Purpose : Creates a .credential file to secure the KID_SUND password.
# Author  : 
# Input   : Read-Host
# From    : 
# Output  : oracle-KID_SUND-psscheduled.credential
# Mail    : 
# Need    : Can only be used on the server where it was created.
# To Do   :
#           
#
# <- - - - - - -


$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

read-host -prompt "Password for KID_SUND" -assecurestring | convertfrom-securestring | out-file .\oracle-KID_SUND-psscheduled.credential



