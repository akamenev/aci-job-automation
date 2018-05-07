Import-Module Azure
Import-Module AzureRm.ContainerRegistry
Import-Module AzureRm.ContainerInstance

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

$cred = Get-AzureRmContainerRegistryCredential -ResourceGroupName "aci-job" -Name "mediumacijob"
$secPassword = ConvertTo-SecureString $cred.Password -AsPlainText -Force
$acrCred = New-Object System.Management.Automation.PSCredential("mediumacijob", $secPassword)

New-AzureRmContainerGroup -ResourceGroupName aci-job -Name worker -Image mediumacijob.azurecr.io/worker:v0.1 -OsType Linux -RegistryCredential $acrCred -RestartPolicy Never

Start-Sleep 120

while($true) {
    if ( (Get-AzureRmContainerInstanceLog -ResourceGroupName aci-job -ContainerGroupName worker) -eq "Uploading to blob`n") {
        Remove-AzureRmContainerGroup -ResourceGroupName aci-job -Name worker
        echo "Container removed"
    }
    Start-Sleep 10
}