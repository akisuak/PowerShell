

Function random-password ($length = 8) {

# $punc = 46..46
$digits = 50..57
$smallletters = 97..107 + 109..110 + 112..122
$bigletters = 65..72 + 74..78 + 80..90
     
$script:tal = get-random -count 2 `
-input $digits |
% -begin { $aa = $null } `
-process {$aa += [char]$_} `
-end {$aa}

$script:big = get-random -count 3 `
-input $bigletters |
% -begin { $bb = $null } `
-process {$bb += [char]$_} `
-end {$bb}

$script:small = get-random -count 3 `
-input $smallletters |
% -begin { $cc = $null } `
-process {$cc += [char]$_} `
-end {$cc}

$script:password = $script:small+$script:tal+$script:big
   
return $script:password
} # end function

function Simple-menu {

$title = "Select the kind of temporary users"
$message = "Choose one of the possible choices!"

$CEKU = New-Object System.Management.Automation.Host.ChoiceDescription "&CEKU", `
    "CEKU users"

$D3UP4 = New-Object System.Management.Automation.Host.ChoiceDescription "&D3UP4", `
    "D3UP4 users"

$FandI = New-Object System.Management.Automation.Host.ChoiceDescription "&FandI", `
    "F&I users"

$MODUL1 = New-Object System.Management.Automation.Host.ChoiceDescription "&MUDUL1", `
    "MODUL1 users"

$PHD = New-Object System.Management.Automation.Host.ChoiceDescription "&PHD", `
    "PHD users"

$RHpharm = New-Object System.Management.Automation.Host.ChoiceDescription "&RHpharm", `
    "RHpharm users"

$SpecAlmMed = New-Object System.Management.Automation.Host.ChoiceDescription "&SpecAlmMed", `
    "SpecAlmMed users"

$VIRMIK = New-Object System.Management.Automation.Host.ChoiceDescription "&VIRMIK", `
    "VIRMIK users"

$test =  New-Object System.Management.Automation.Host.ChoiceDescription "&Test", `
    "Test"

$Guest =  New-Object System.Management.Automation.Host.ChoiceDescription "&Guest", `
    "Guest"

$SEMS =  New-Object System.Management.Automation.Host.ChoiceDescription "S&EMS", `
    "SEMS"

$Nothing = New-Object System.Management.Automation.Host.ChoiceDescription "&Nothing", `
    "Do nothing"


$options = [System.Management.Automation.Host.ChoiceDescription[]]($CEKU, $D3UP4, $FandI, $MODUL1, $PHD, $RHpharm, $SpecAlmMed, $VIRMIK, $Test, $Guest, $SEMS, $Nothing)

$result = $host.ui.PromptForChoice($title, $message, $options, 11 ) 

switch ($result)
    {
        0 {"You selected CEKU";$script:OU = "OU=CeKU,OU=Limited Accounts,OU=Domain Special,DC=sund,DC=root,DC=ku,DC=dk";$script:TempUser = "CEKU"}
        1 {"You selected D3UP4";$script:OU = "OU=D3UP4Linux,OU=Limited Accounts,OU=Domain Special,DC=sund,DC=root,DC=ku,DC=dk";$script:TempUser = "D3UP4"}
        2 {"You selected F&I";$script:OU = "OU=FandI,OU=Limited Accounts,OU=Domain Special,DC=sund,DC=root,DC=ku,DC=dk";$script:TempUser = "FandI"}
        3 {"You selected MODUL1";$script:OU = "OU=MODUL1,OU=Limited Accounts,OU=Domain Special,DC=sund,DC=root,DC=ku,DC=dk";$script:TempUser = "MODUL1"}
        4 {"You selected PHD";$script:OU = "OU=PHD,OU=Limited Accounts,OU=Domain Special,DC=sund,DC=root,DC=ku,DC=dk";$script:TempUser = "PHD"}
        5 {"You selected RHpharm";$script:OU = "OU=RHpharm,OU=Limited Accounts,OU=Domain Special,DC=sund,DC=root,DC=ku,DC=dk";$script:TempUser = "RHpharm"}
        6 {"You selected SpecAlmMed";$script:OU = "OU=SpecAlmMed,OU=Limited Accounts,OU=Domain Special,DC=sund,DC=root,DC=ku,DC=dk";$script:TempUser = "SpecAlmMed"}
        7 {"You selected VIRMIK";$script:OU = "OU=Virmik,OU=Limited Accounts,OU=Domain Special,DC=sund,DC=root,DC=ku,DC=dk";$script:TempUser = "VIRMIK"}
        8 {"You selected Test";$script:OU = "OU=Test,OU=Limited Accounts,OU=Domain Special,DC=sund,DC=root,DC=ku,DC=dk";$script:TempUser = "Test"}
        9 {"You selected Guest";$script:OU = "OU=Guest,OU=Limited Accounts,OU=Domain Special,DC=sund,DC=root,DC=ku,DC=dk";$script:TempUser = "Guest"}
        10 {"You selected SEMS";$script:OU = "OU=SEMS,OU=Limited Accounts,OU=Domain Special,DC=sund,DC=root,DC=ku,DC=dk";$script:TempUser = "SEMS"}
        11 {"You selected nothing";$script:OU = "";$script:TempUser = "";exit}
    }

    
} # end function

function Date-Picker {

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object Windows.Forms.Form 

$form.Text = "Select the expire date for the accounts (plus one day)" 
$form.Size = New-Object Drawing.Size @(243,230) 
$form.StartPosition = "CenterScreen"

$calendar = New-Object System.Windows.Forms.MonthCalendar 
$calendar.ShowTodayCircle = $False
$calendar.MaxSelectionCount = 1
$form.Controls.Add($calendar) 

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(38,165)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(113,165)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$form.Topmost = $True

$result = $form.ShowDialog() 

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $script:date = $calendar.SelectionStart
    # Write-Host "Date selected: $($script:date.ToShortDateString())"
}


} # end function 

function Initialize-Variables {

Set-StrictMode -Version 1.0 # latest or 2.0

Set-location 'C:\create\manuel-korsel'

$script:logdato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()

random-password # function

$script:secure_string_pwd = ConvertTo-SecureString "$script:password" -AsPlainText -Force  

$testdate = $($script:date.ToShortDateString())

$script:tekst1 = 'Password skal ændres ved første login. Enten på en SUND PC eller på https://password.sund.ku.dk' | Out-File ".\$script:logdato-$script:TempUser.txt" -Append
$script:tekst2 = 'Password skal indeholde mindst 8 tegn, et stort og et lille bogstav, og tal (0-9) eller specialtegn (!-#%&)' | Out-File ".\$script:logdato-$script:TempUser.txt" -Append
$script:tekst3 = "De midlertidige konti udløber $testdate" | Out-File ".\$script:logdato-$script:TempUser.txt" -Append
$script:tekst4 = 'Brugernavn;Password' | Out-File ".\$script:logdato-$script:TempUser.txt" -Append

} # end function

function Stop-Script {

param()

# Stop-Transcript

move-item ".\$script:logdato*.*" .\old-data\

break;

} # end function

function Read-Number-Users {

$loop1 = $false

while($loop1 -eq $false)
{  

Number-Users # function

Get-Menufor-NumberUsers # function

if ($script:result1 -eq '1') { $loop1 = $false; clear-host }

elseif ($script:result1 -eq '0') {$loop1 = $true; } # end elseif

} # end while 

} # end function Read-Date-Time

function Number-Users {

[int]$script:NumberUsers = Read-Host -Prompt "Please enter the number of temp login accounts"


} # end function

function Get-Menufor-NumberUsers {

$title = "[ Please confirm the number of users ]"
$message = "Is $script:NumberUsers correct? "

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "The number of users is correct"

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "The number of users is incorrect"

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$script:result1 = $host.ui.PromptForChoice($title, $message, $options, 1) 

switch ($script:result1)
    {
        0 {"You selected Yes."}
        1 {"You selected No."}
    } # end switch

} # end function

function Test-RunNumber {

$script:dayofyear = get-date -uformat %j
$script:year = get-date -uformat %y

$testcsv = Test-Path -Path ".\$script:dayofyear-$script:year.txt" # for eksempel: 112-16.txt

if ($testcsv -eq $false)
{
[Int]$script:RunNumber = 1
$script:RunNumber | out-file -filepath  ".\$script:dayofyear-$script:year.txt" -Append 
}
elseif ($testcsv -eq $true)
{
$script:Last = (Get-Content ".\$script:dayofyear-$script:year.txt" | Select-Object -Last 1)

[Int]$script:RunNumber = [Int]$script:Last+1

$script:RunNumber | out-file -filepath  ".\$script:dayofyear-$script:year.txt" -Append 
}


} # end function

function create-Temp-users {

 for($i=1; $i -le $script:NumberUsers; $i++)
 {
  
 $USERNAME = "$script:TempUser$script:dayofyear$script:year$script:RunNumber$i"

 $random = Get-Random -Minimum 82000 -Maximum 88000

 "$USERNAME;$script:password" | Out-File ".\$script:logdato-$script:TempUser.txt" -Append

new-aduser -Server "dc3.sund.root.ku.dk" -Name "$USERNAME" -Enabled $True -Path "$script:OU" `
-SamAccountName "$USERNAME" -DisplayName "$USERNAME" -GivenName "$USERNAME" `
-Surname "$script:TempUser" -UserPrincipalName "$USERNAME@sund.root.ku.dk" `
-OtherAttributes @{'loginShell'="/bin/bash"; 'unixHomeDirectory'="%H/$USERNAME"; 'gidNumber'="972030465"; 'gecos'="$USERNAME"; 'uidNumber'="$random"} `
-Description "$script:TempUser Expires $($script:date.ToShortDateString())" -AccountPassword $script:secure_string_pwd `
-ChangePasswordAtLogon $True -AccountExpirationDate "$($script:date.ToShortDateString())"
 
 }


} # end function

function send-Temp-mail {

$MailBody = " `
To $script:TempUser `
 `
Enclosed are the usernames and passwords for the $script:NumberUsers $script:TempUser user accounts `
 `
The $script:NumberUsers accounts expires $($script:date.ToShortDateString()) `
 `
At first logon the password is $script:password `
 `
Kind regards `
SUND-IT `
 `
itsupport@sund.ku.dk `
 ` 
You cannot reply to this mail."  

# sending mail

Write-Verbose "Sending e-mail"

# 'Cc'='choj@sund.ku.dk'

$params = @{'To'='BCC-Mail@sund.ku.dk'
'Cc'='itsupport@sund.ku.dk'
'Bcc'='esba@sund.ku.dk'
'From'='do-not-reply@sund.ku.dk'
          'Subject'="$script:TempUser user accounts with expiration date"
          'Body'="$MailBody"
          'Attachments'=".\$script:logdato-$script:TempUser.txt"
          'SMTPServer'='smtpgw.sund.root.ku.dk'}
Send-MailMessage @params -Encoding UTF8

} # end function



#
# *** Entry Point To Script ***
#


Import-Module activedirectory # 

Simple-menu # Data: $script:OU, $script:TempUser, ($CEKU, $D3UP4, $FandI, $MODUL1, $PHD, $RHpharm, $SpecAlmMed, $VIRMIK, $Nothing)

Date-Picker; # Data: $($script:date.ToShortDateString())

Initialize-Variables # Data: $script:logdato, $script:password, $script:secure_string_pwd, 

Test-RunNumber; # Data: $script:RunNumber

Read-Number-Users # Data: $script:NumberUsers

create-Temp-users # Data: $USERNAME, Out-File ".\$script:logdato-$script:TempUser.csv"

send-Temp-mail # Data: $MailBody, $params

Stop-Script
