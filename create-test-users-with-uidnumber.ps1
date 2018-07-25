
$USERNAME = 'aey988'

$OU = 'OU=ScriptTest,OU=FAK,OU=Funktions Konti,OU=Domain Special,DC=sund,DC=root,DC=ku,DC=dk'

$uidNumber = '497696355'

$password = 'q55Ys64u'

$secure_string_pwd = ConvertTo-SecureString "$password" -AsPlainText -Force  

# -AccountPassword $script:secure_string_pwd

$gidNumber = '972047585' # 333000

# $gidNumber = '972089636' # 348300

new-aduser -Server "dc3.sund.root.ku.dk" -Name "$USERNAME" -Enabled $True -Path "$OU" `
-SamAccountName "$USERNAME" -DisplayName "$USERNAME" -GivenName "$USERNAME" `
-Surname "$USERNAME" -UserPrincipalName "$USERNAME@sund.root.ku.dk" `
-OtherAttributes @{'loginShell'="/bin/bash"; 'unixHomeDirectory'="%H/$USERNAME"; 'gidNumber'="$gidNumber"; 'gecos'="$USERNAME"; 'uidNumber'="$uidNumber"} `
-Description "" -AccountPassword $secure_string_pwd -ChangePasswordAtLogon $False
 
