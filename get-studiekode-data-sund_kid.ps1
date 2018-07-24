
#- - - - - - ->
#
# Script  : get-studiekode-data-sund_kid.ps1
# Runs    : Manually
# Login   : 
# Purpose : Looks for possible new "KID_SUND_ACCESS_V1.STUDIERETN_KODE"
# Author  : 
# Input   : Query KID_SUND_ACCESS_V1
# From    : Oracle
# Output  : $dato-sund_kid-studiekoder.csv
# Mail    : 
# Need    : oracle-KID_SUND-ps2008schedule.credential
# To Do   : Compare with current list of STUDIERETN_KODE's           
#
# <- - - - - - -


$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

$dato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()

[void][Reflection.Assembly]::Load("System.Data.OracleClient, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")


$QueryString = "Select Distinct KID_SUND_ACCESS_V1.STUDIERETN_KODE,
KID_SUND_ACCESS_V1.STUDIERETN_NAVN
From KID_SUND_ACCESS_V1"

# $cred = Get-Credential
# $foenix = $cred.getnetworkcredential().password

# if running sceduled task use this
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
		Write-Output $StringBuilder.ToString() | Out-File ".\DATA\$dato-sund_kid-studiekoder.csv" -Append
	}
	#Close the Connection
	$recordset.Close()
	$connection.Close();
}



