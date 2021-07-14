# This script will list the permissions structure of a vCenter Server
# It includes the user or group, entity that the permission is set, 
# the role given, and if its set to propogate to child objects.
# NOTE: GLOBAL PERMISSIONS NOT INCLUDED

#Setup authentication to the vCenter
$vCenter = read-host "vCenter FQDN or IP"
$defaultUser = "administrator@vsphere.local"
$VC_user = Read-Host "Enter vCenter username or press enter for default [$($defaultUser)]"
$VC_user = ($defaultUser,$VC_user)[[bool]$VC_user]
$VC_pass = read-host "administrator@vsphere.local password" -assecurestring
$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($VC_pass))

#Disconnect from any currently vCenter Servers
Try {
    $DisconnectVC1 = Disconnect-VIServer * -Force -Confirm:$false
    Write-Host "Disconnecting from previous VIServer....." $global:DefaultVIServers ; ""
}
Catch {
    Write-Host "No vCenter connected - Connecting to:" $vCenter  ; ""
}

#Connect to supplied vCenter Server    
Write-Host "Connecting to" $vCenter ; ""
$ConnectVC = Connect-VIServer $vCenter -User $VC_user -Password $password
If ($global:DefaultVIServer -ne $null) {
    Write-Host "Connected!`n"
}

#List permissions of the connected vCenter
$si = Get-View ServiceInstance -Server $global:DefaultVIServer
$authMgr = Get-View -Id $si.Content.AuthorizationManager-Server $global:DefaultVIServer
$authMgr.RetrieveAllPermissions() |

Select @{N='Entity';E={Get-View -Id $_.Entity -Property Name -Server $global:DefaultVIServer | select -ExpandProperty Name}},
    @{N='Entity Type';E={$_.Entity.Type}},
    Principal,
    Propagate,
    @{N='Role';E={$perm = $_; ($authMgr.RoleList | where{$_.RoleId -eq $perm.RoleId}).Info.Label}} |
    Format-Table -AutoSize 
