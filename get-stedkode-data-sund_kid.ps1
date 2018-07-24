
#- - - - - - ->
#
# Script  : get-stedkode-data-sund_kid.ps1
# Runs    : Manually on the ps2008schedule server
# Login   : oracle-KID_SUND-ps2008schedule.credential KID_SUND
# Purpose : Discovery of new SUND STEDKODE and STEDKODE_NAVN
# Author  : 
# Input   : sund-alle-stedkoder-string.txt
# From    : Oracle KID_SUND_ACCESS_V1
# Output  : $dato-sund_kid-stedkoder.csv
#         : $dato-Sund-NY-Stedkode.csv
# Mail    : 
# Need    : 
# To Do   : 
#           
#
# <- - - - - - -


$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

$dato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()

Start-Transcript -Path ".\DATA\$dato-transcript-get-stedkode-data.log"

[void][Reflection.Assembly]::Load("System.Data.OracleClient, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")


$QueryString = "Select Distinct KID_SUND_ACCESS_V1.STEDKODE,
KID_SUND_ACCESS_V1.STEDKODE_NAVN
From KID_SUND_ACCESS_V1"

# $cred = Get-Credential
# $foenix = $cred.getnetworkcredential().password

# if running a sceduled task use this
$cred = Get-Content '.\oracle-KID_SUND-ps2008schedule.credential' | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PSCredential "KID_SUND",$cred
$foenix = $credential.GetNetworkCredential().Password

$ConnectionString = "Data Source=prku;Integrated Security=False;User ID=KID_SUND;Password=$foenix"

$connection = New-Object System.Data.OracleClient.OracleConnection ($ConnectionString)
$connection.Open()
if($connection.State -eq [System.Data.ConnectionState]::Open)
{
	$command = New-Object System.Data.OracleClient.OracleCommand ($QueryString,$connection)
	$StringBuilder = New-Object System.Text.StringBuilder
	#Run the query
	$recordset = $command.ExecuteReader()
	While($recordset.Read() -eq $true)
	{
		#Clear the StringBuilder
		[void]$StringBuilder.Remove(0, $StringBuilder.Length)
		
		#Loop through each field
		for($index=0; $index -lt $recordset.FieldCount; $index++)
		{
			if($index -ne 0)
			{
				[void]$StringBuilder.Append(";")
			}
			[void]$StringBuilder.Append($recordset.GetValue($index).ToString())
		}
		#Output the Row
		Write-Output $StringBuilder.ToString() | Out-File ".\DATA\$dato-sund_kid-stedkoder.csv" -Append
	}
	#Close the Connection
	$recordset.Close()
	$connection.Close();
}


function ForEach-Stedkode {

BEGIN {}

PROCESS {

$script:newAry = $_.split(';')

$script:stedkode = $script:newAry[0]+"00"
$script:stedkodenavn = $script:newAry[1]

if ($script:skarray -contains $script:stedkode) { Out-Null }  
else {"$script:StedKode"+","+"$script:stedkodenavn" | Out-File ".\DATA\$dato-Sund-NY-Stedkode.csv" -Append}

}

}


$script:SUNDStedkoder = Get-Content -Path '.\sund-alle-stedkoder-string.txt'

$script:skarray = $script:SUNDStedkoder.Split(',')

Get-Content -Path ".\DATA\$dato-sund_kid-stedkoder.csv" | ForEach-Stedkode

Stop-Transcript

#>