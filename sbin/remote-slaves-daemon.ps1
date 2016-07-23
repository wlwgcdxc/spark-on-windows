param($slave_host,$spark_home,$master,$option)

function Import-Credential
{
   param
   (
     [Parameter(Mandatory=$true)]
     $Path
   )
 
  $CredentialCopy = Import-Clixml $path   
  $CredentialCopy.password = $CredentialCopy.Password | ConvertTo-SecureString   
  New-Object system.Management.Automation.PSCredential($CredentialCopy.username, $CredentialCopy.password)
}

#set mem of jvm
set-item wsman:localhost\Shell\MaxMemoryPerShellMB 3072

#get the credential of slave_host
$credential = Import-Credential  -Path $spark_home\conf\slaves_credential\$slave_host
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $credential.UserName,$credential.Password

#log in the slave_host
$session1 = new-pssession -computer $slave_host -Credential $cred
cd $spark_home\sbin

#exec the command
$sub = Invoke-Command -Session $session1 -ScriptBlock{
	param ($MasterURL,$mode)
	if ($mode -eq "start-slave.cmd") {
		start-slave.cmd $MasterURL
	} else {
		stop-slave.cmd $MasterURL
	}
} -argumentlist $master,$option 
exit