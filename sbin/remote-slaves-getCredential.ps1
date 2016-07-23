param($master_host,$spark_home)

function Export-Credential
{
   param
   (
     [Parameter(Mandatory=$true)]
     $Path,
	 [Parameter(Mandatory=$true)]
     $Credential
   )  
  $CredentialCopy = $Credential | Select-Object *   
  $CredentialCopy.Password = $CredentialCopy.Password | ConvertFrom-SecureString   
  $CredentialCopy | Export-Clixml $Path
}

#connect to master node
set-item wsman:localhost\Shell\MaxMemoryPerShellMB 3072
$cred = $host.ui.PromptForCredential("Need credentials", "Please log in master node", "", "NetBiosUserName")
$session1 = new-pssession -computer $master_host -Credential $cred

#after connected, create slaves_credential path
if ( -not (Test-Path $spark_home\conf\slaves_credential)) {
	md $spark_home\conf\slaves_credential
}

#get the credential of localhost
$Credential = $host.ui.PromptForCredential("Need credentials", "Please enter your user name and password ,then we will export the credential to master.", "", "NetBiosUserName") 

#export the credential to the specified path
Export-Credential -Path $spark_home\conf\slaves_credential\$env:COMPUTERNAME -Credential $Credential

#get the credential of master node 
if ($master_host -eq $env:COMPUTERNAME) {
	Export-Credential -Path $spark_home\conf\slaves_credential\localhost -Credential $Credential
}
exit