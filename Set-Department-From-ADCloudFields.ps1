
#- - - - - - ->
#
# Script  : Set-Department-From-ADCloudFields.ps1
# Runs    : Every day 23:30 CET Task Scheduler ps2008schedule
# Login   : 
# Purpose : Gets KU-Username and "stedkode" from AD
#           "Stedkode" is translated to "Name of Institute" and written into the AD departmentNumber attribute. 
#           The departmentNumber attribute is then used for a SCCM report.
# Author  : 
# SCCM    : 
# Input   : $script:logdato-ALL-SUND-Employees.csv
# From    : OU=Employees,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk
# Output  : 
# Mail    : 
# Need    : sund-alle-stedkoder-string.txt
# To Do   : 
#           
#
# <- - - - - - -


function Initialize-GetStedkoderFromAD {

Set-StrictMode -Version 1.0 # latest or 2.0

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

$script:SUNDStedkoder = Get-Content -Path '.\sund-alle-stedkoder-string.txt'

$script:skarray = $script:SUNDStedkoder.Split(',')

$script:logdato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()

Start-Transcript -Path ".\$script:logdato-Transcript-StedkoderFromAD.log"

} # 

function GetStedkoderFromAD {

BEGIN {}

PROCESS {

Get-ADUser -filter * -Properties * -SearchBase 'OU=Employees,OU=Domain Users,DC=sund,DC=root,DC=ku,DC=dk' -Server "dc3.sund.root.ku.dk" -ResultSetSize $null | `
Select-Object SamAccountName,msDS-cloudExtensionAttribute1 | `
export-csv -Delimiter "," -NoTypeInformation -Encoding UTF8 -path ".\$script:logdato-ALL-SUND-Employees.csv" -append
  
} # end process

END {}

} # 

function RemoveTextSeparator {

BEGIN {}

PROCESS {

Get-Content ".\$script:logdato-ALL-SUND-Employees.csv" | ForEach-Object {$_ -replace '"','' } | `
Set-Content ".\$script:logdato-ALL-SUND-Employees-SET.csv" -Encoding UTF8

} # end process

} #

function RemoveFirstLine {

BEGIN {}

PROCESS {

Get-Content ".\$script:logdato-ALL-SUND-Employees-SET.csv" | Select-Object -Skip 1 | Out-File ".\$script:logdato-ALL-SUND-Employees-SET-1.csv" -Encoding utf8

} # end process

} #

function ForEach-StedkodeFromAD {

BEGIN {}

PROCESS {

$script:newAry = $_.split(',')

$script:USERNAME = $script:newAry[0]
$script:stedkode = $script:newAry[1]
$script:Stedary = $script:stedkode.split(';')

if ($script:skarray -contains $script:stedary[0] ){

"$script:USERNAME"+','+$script:stedary[0]+'' | out-file ".\$script:logdato-SUND-Stedkoder-FromAD.csv" -Append

} # end if

} # end process

} # end function

# function ForEach-InstitutStedkode
# Kunne overvejes at vedligeholde data i en xml fil, men er det hurtigere/lettere at vedligeholde?
# Det er selvfølgelig god praksis at adskille kode og data

function ForEach-InstitutStedkode {

BEGIN {}

PROCESS {

$script:newAry = $_.split(',')

$script:USERNAME = $script:newAry[0]
$script:stedkode = $script:newAry[1]

if (($script:stedkode -ge 300000) -and ($script:stedkode -le 302900)) {$script:Institut = 'FAK'}        # 3000-3029 FAK
elseif (($script:stedkode -ge 303000) -and ($script:stedkode -le 303900))  {$script:Institut = 'DRIFT'}   # 3030-3039 DRIFT
elseif (($script:stedkode -ge 304100) -and ($script:stedkode -le 304200))  {$script:Institut = 'TECHT'}   # 3041-3042 TECHT
elseif (($script:stedkode -ge 310000) -and ($script:stedkode -le 311900))  {$script:Institut = 'BMI'}   # 3100-3119 BMI
elseif (($script:stedkode -ge 312000) -and ($script:stedkode -le 313900))  {$script:Institut = 'ISIM'}   # 3120-3139 ISIM
elseif (($script:stedkode -ge 314000) -and ($script:stedkode -le 315600))  {$script:Institut = 'INF'}   # 3140-3156 INF
elseif (($script:stedkode -ge 316000) -and ($script:stedkode -le 317900))  {$script:Institut = 'ICMM'}   # 3160-3179 ICMM
elseif (($script:stedkode -ge 328000) -and ($script:stedkode -le 329000))  {$script:Institut = 'KLINI'}   # 3280-3290 KLINI
elseif (($script:stedkode -ge 330000) -and ($script:stedkode -le 339900))  {$script:Institut = 'IFSV'}   # 3300-3399 IFSV
elseif (($script:stedkode -ge 348100) -and ($script:stedkode -le 348900))  {$script:Institut = 'ILF'}   # 3481-3489 ILF
elseif (($script:stedkode -ge 349000) -and ($script:stedkode -le 349900))  {$script:Institut = 'IF'}   # 3490-3499 IF
elseif (($script:stedkode -ge 360000) -and ($script:stedkode -le 363100))  {$script:Institut = 'RMI'}   # 3600-3631 RMI
elseif (($script:stedkode -ge 366000) -and ($script:stedkode -le 366700))  {$script:Institut = 'IPH'}   # 3660-3667 IPH
elseif (($script:stedkode -ge 367000) -and ($script:stedkode -le 367900))  {$script:Institut = 'IKVH'}   # 3670-3679 IKVH
elseif (($script:stedkode -ge 368000) -and ($script:stedkode -le 368900))  {$script:Institut = 'IVS'}   # 3680-3689 IVS
elseif (($script:stedkode -ge 370000) -and ($script:stedkode -le 373900))  {$script:Institut = 'BRIC'}   # 3700-3739 BRIC
elseif (($script:stedkode -ge 380000) -and ($script:stedkode -le 384900))  {$script:Institut = 'ODONT'}   # 3800-3849 ODONT
elseif (($script:stedkode -ge 385000) -and ($script:stedkode -le 385900))  {$script:Institut = 'CPR'}   # 3850-3859 CPR
elseif (($script:stedkode -ge 386000) -and ($script:stedkode -le 386900))  {$script:Institut = 'CBMR'}   # 3860-3869 CBMR
elseif ($script:stedkode -eq 386600) {$script:Institut = 'MUSEION'}                                       # 3866 MUSEION
elseif ($script:stedkode -eq 387000) {$script:Institut = 'ALDRING'}                                       # 3870 ALDRING
elseif ($script:stedkode -eq 387500) {$script:Institut = 'BIOPEOP'}                                       # 3875 BIOPEOP
elseif ($script:stedkode -eq 387600) {$script:Institut = 'CBTN'}                                       # 3876 CBTN
elseif ($script:stedkode -eq 388000) {$script:Institut = 'UNIK'}                                       # 3880 UNIK
elseif (($script:stedkode -ge 388100) -and ($script:stedkode -le 388700))  {$script:Institut = 'DANSTEM'}   # 3881-3887 DANSTEM
elseif (($script:stedkode -ge 389000) -and ($script:stedkode -le 389400))  {$script:Institut = 'SSC'}   # 3890-3894 SSC
elseif (($script:stedkode -ge 390000) -and ($script:stedkode -le 393500))  {$script:Institut = 'BACHELO'}   # 3900-3935 BACHELO
elseif (($script:stedkode -ge 394100) -and ($script:stedkode -le 394800))  {$script:Institut = 'EMED'}   # 3941-3948 EMED
elseif (($script:stedkode -ge 396100) -and ($script:stedkode -le 396500))  {$script:Institut = 'SKT'}   # 3961-3965 SKT
elseif (($script:stedkode -ge 396600) -and ($script:stedkode -le 399200))  {$script:Institut = 'MASTER'}   # 3966-3992 MASTER
elseif ($script:stedkode -eq 399500) {$script:Institut = 'PHD'}
elseif (($script:stedkode -ge 852000) -and ($script:stedkode -le 852700))  {$script:Institut = 'BRIC'}   # 8520-8527 BRIC
elseif (($script:stedkode -ge 862100) -and ($script:stedkode -le 865800))  {$script:Institut = 'BRIC'}   # 8621-8658 BRIC                                       # 3995 PHD
elseif ($script:stedkode -eq 989700) {$script:Institut = 'ALMENMED'}                                       # 9897 ALMENMED

Get-ADUser -Identity $script:USERNAME -Properties * | set-aduser -Department "$script:Institut"
  
} # end process

END {}

} ## end

function MoveFilesToDATA {

Stop-Transcript

Move-Item ".\$script:logdato*.*" -Destination 'C:\create\DATA\'

exit;

} # end


# Entry Point


Initialize-GetStedkoderFromAD # function

GetStedkoderFromAD # function

RemoveTextSeparator # function

RemoveFirstLine # function

Get-Content -Path ".\$script:logdato-ALL-SUND-Employees-SET-1.csv" | ForEach-StedkodeFromAD

Get-Content -Path  ".\$script:logdato-SUND-Stedkoder-FromAD.csv" | ForEach-InstitutStedkode

MoveFilesToDATA # function

