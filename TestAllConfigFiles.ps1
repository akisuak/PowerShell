
# C:\windows\System32\WindowsPowerShell\v1.0\SessionConfig\TempUsersEndpoint_ccff5cec-5de8-43ba-b876-d77063671d34.pssc

function Test-AllConfigFiles
{
    Get-PSSessionConfiguration | ForEach-Object { if ($_.ConfigFilePath)
    {$_.ConfigFilePath; Test-PSSessionConfigurationFile -Verbose `
     -Path $_.ConfigFilePath }}
}

Test-AllConfigFiles
