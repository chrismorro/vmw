# Setup authentication to the vCenter
$vCenter = read-host "vCenter FQDN or IP"
$defaultUser = "administrator@vsphere.local"
$VC_user = Read-Host "Enter vCenter username or press enter for default [$($defaultUser)]"
$VC_user = ($defaultUser,$VC_user)[[bool]$VC_user]
$VC_pass = read-host "administrator@vsphere.local password" -assecurestring
$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($VC_pass))

# Disconnect from any currently vCenter Servers
Try {
    $DisconnectVC1 = Disconnect-VIServer * -Force -Confirm:$false
    Write-Host "Disconnecting from previous VIServer....." $global:DefaultVIServers ; ""
}
Catch {
    Write-Host "No vCenter connected - Connecting to:" $vCenter  ; ""
}

# Connect to supplied vCenter Server    
Write-Host "Connecting to" $vCenter ; ""
$ConnectVC = Connect-VIServer $vCenter -User $VC_user -Password $password
If ($global:DefaultVIServer -ne $null) {
    Write-Host "Connected!`n"
}

# Get all connect ESXi hosts in VC, then print the hostname and the last section of the uuid ONLY if it is NOT UNIQUE to all other hosts
Write-Host "Searching for duplicate values in host UUID strings..."
Get-VMHost | where {$_.ConnectionState -eq "Connected"} | select Name, @{N="UUID MAC";E={((Get-EsxCli -VMHost $_ -v2).system.uuid.get.Invoke().Split("-")[-1])}} | group "UUID MAC" | Where{$_.Count -gt 1} | Select -Expand Group
Write-Host ; "`nDone!"
Read-Host -Prompt "Press Enter to exit"
