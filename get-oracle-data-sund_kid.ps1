
#- - - - - - ->
#
# Script  : get-oracle-data-sund_kid.ps1
# Runs    : Manually on the ps2008schedule server
# Login   : oracle-KID_SUND-ps2008schedule.credential KID_SUND
# Purpose : Used to compare with data in SUND AD objects.
#           Has been used for Pcounter ID-Card imports.
# Author  : 
# Input   : Oracle
# From    : KID_SUND_ACCESS_V1
# Output  : $dato-kid-sund-access-v1-alle/stud/ansat.csv
# Mail    : 
# Need    : oracle-KID_SUND-ps2008schedule.credential
# To Do   : should only query "ER_STUDENT = J" or "ER_ANSAT = J"
#           
#
# <- - - - - - -


$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Set-location -Path "$ScriptDir"

$dato = (get-date -uformat "%d%m%Y@%H-%M-%S").tostring()


[void][Reflection.Assembly]::Load("System.Data.OracleClient, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")

#Database Query
$QueryString = "Select Distinct KID_SUND_ACCESS_V1.USERNAME,
  KID_SUND_ACCESS_V1.PERSON_ID,
  KID_SUND_ACCESS_V1.IDKORT_PERSONNR,
  KID_SUND_ACCESS_V1.FORNAVN,
  KID_SUND_ACCESS_V1.EFTERNAVN,
  KID_SUND_ACCESS_V1.ER_STUDENT,
  KID_SUND_ACCESS_V1.ER_ANSAT,
  KID_SUND_ACCESS_V1.NYESTE_KORT,
  KID_SUND_ACCESS_V1.MAIL,
  KID_SUND_ACCESS_V1.SPOR2_KODE,
  KID_SUND_ACCESS_V1.KORTTYPE_ID,
  KID_SUND_ACCESS_V1.KORTTYPE_TX,
  KID_SUND_ACCESS_V1.KORT_ID,
  KID_SUND_ACCESS_V1.PINKODE,
  KID_SUND_ACCESS_V1.STUDIERETN_KODE,
  KID_SUND_ACCESS_V1.STEDKODE,
  KID_SUND_ACCESS_V1.STEDKODE_NAVN
From KID_SUND_ACCESS_V1
Where KID_SUND_ACCESS_V1.NYESTE_KORT = 'J'"

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
		Write-Output $StringBuilder.ToString() | Out-File ".\DATA\$dato-kid-sund-access-v1-alle.csv" -Append
	}
	#Close the Connection
	$recordset.Close()
	$connection.Close();
}


$QueryString = "Select Distinct KID_SUND_ACCESS_V1.USERNAME,
  KID_SUND_ACCESS_V1.PERSON_ID,
  KID_SUND_ACCESS_V1.IDKORT_PERSONNR,
  KID_SUND_ACCESS_V1.FORNAVN,
  KID_SUND_ACCESS_V1.EFTERNAVN,
  KID_SUND_ACCESS_V1.ER_STUDENT,
  KID_SUND_ACCESS_V1.ER_ANSAT,
  KID_SUND_ACCESS_V1.NYESTE_KORT,
  KID_SUND_ACCESS_V1.MAIL,
  KID_SUND_ACCESS_V1.SPOR2_KODE,
  KID_SUND_ACCESS_V1.KORTTYPE_ID,
  KID_SUND_ACCESS_V1.KORTTYPE_TX,
  KID_SUND_ACCESS_V1.KORT_ID,
  KID_SUND_ACCESS_V1.PINKODE,
  KID_SUND_ACCESS_V1.STUDIERETN_KODE,
  KID_SUND_ACCESS_V1.STEDKODE,
  KID_SUND_ACCESS_V1.STEDKODE_NAVN
From KID_SUND_ACCESS_V1
Where KID_SUND_ACCESS_V1.ER_STUDENT = 'J' AND KID_SUND_ACCESS_V1.ER_ANSAT = 'N' AND KID_SUND_ACCESS_V1.NYESTE_KORT = 'J'"

# AND KID_SUND_ACCESS_V1.STUDIERETN_KODE
# $cred = Get-Credential
# $foenix = $cred.getnetworkcredential().password

# if running sceduled task use this
# $cred = Get-Content '.\oracle-KID_SUND-ps2008schedule.credential' | ConvertTo-SecureString
# $credential = New-Object System.Management.Automation.PSCredential "KID_SUND",$cred
# $foenix = $credential.GetNetworkCredential().Password

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
		Write-Output $StringBuilder.ToString() | Out-File ".\DATA\$dato-kid-sund-access-v1-stud.csv" -Append
	}
	#Close the Connection
	$recordset.Close()
	$connection.Close();
}


$QueryString = "Select Distinct KID_SUND_ACCESS_V1.USERNAME,
  KID_SUND_ACCESS_V1.PERSON_ID,
  KID_SUND_ACCESS_V1.IDKORT_PERSONNR,
  KID_SUND_ACCESS_V1.FORNAVN,
  KID_SUND_ACCESS_V1.EFTERNAVN,
  KID_SUND_ACCESS_V1.ER_STUDENT,
  KID_SUND_ACCESS_V1.ER_ANSAT,
  KID_SUND_ACCESS_V1.NYESTE_KORT,
  KID_SUND_ACCESS_V1.MAIL,
  KID_SUND_ACCESS_V1.SPOR2_KODE,
  KID_SUND_ACCESS_V1.KORTTYPE_ID,
  KID_SUND_ACCESS_V1.KORTTYPE_TX,
  KID_SUND_ACCESS_V1.KORT_ID,
  KID_SUND_ACCESS_V1.PINKODE,
  KID_SUND_ACCESS_V1.STUDIERETN_KODE,
  KID_SUND_ACCESS_V1.STEDKODE,
  KID_SUND_ACCESS_V1.STEDKODE_NAVN
From KID_SUND_ACCESS_V1
Where KID_SUND_ACCESS_V1.ER_ANSAT = 'J' AND KID_SUND_ACCESS_V1.NYESTE_KORT = 'J'"

# $cred = Get-Credential
# $foenix = $cred.getnetworkcredential().password

# if running sceduled task use this
# $cred = Get-Content '.\oracle-KID_SUND-ps2008schedule.credential' | ConvertTo-SecureString
# $credential = New-Object System.Management.Automation.PSCredential "KID_SUND",$cred
# $foenix = $credential.GetNetworkCredential().Password

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
		Write-Output $StringBuilder.ToString() | Out-File ".\DATA\$dato-kid-sund-access-v1-ansat.csv" -Append
	}
	#Close the Connection
	$recordset.Close()
	$connection.Close();
}



