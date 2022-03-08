$installWSL = $false
$wslpath = 'C:\WSL'
$wslpath_pref = '\distro'
$wslpath_full = $wslpath+$wslpath_pref
$node = 2

###+++++++ Enable WSL and Install WSL2+++++++###
if($installWSL){
    $requieredFeautures = 'Microsoft-Windows-Subsystem-Linux','VirtualMachinePlatform'
    $match = 'State : Enabled'

    foreach ($feauture in $requieredFeautures){
        $test = dism.exe /online /Get-FeatureInfo /FeatureName:$feauture
    
        if($test -like "*$match*"){
            Write-Host "Feauture $feauture is enabled"
        }
        else{
            dism.exe /online /enable-feature /featurename:$feauture /all /norestart
        }
    }
    Invoke-WebRequest https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile wsl_update_x64.msi
    ./wsl_update_x64.msi /quiet
    Remove-Item wsl_update_x64.msi
    wsl --set-default-version 2
    Write-Host "Default WSL version set: 2"
    
}
else{
    Write-Host 'Windows-Subsystem-Linux Installation was skipped...'
}

###+++++++ Install Debian +++++++###

wsl --install -d Debian

try{
    wsl -d Debian -u root "./scripts/setDebianDistro.sh"
}
catch{
    
}

###+++++++ Install Docker +++++++###

wsl -d Debian -u root "./scripts/addDocker2Debian.sh"

###+++++++ Export Debian +++++++###

if (Test-Path -Path $wslpath){
    Remove-Item -Path $wslpath -Recurse -Force
}

if(-not(Test-Path -Path $wslpath)){
    New-Item -Path $wslpath_full -ItemType 'directory'
}

wsl --export Debian $wslpath_full'\dockerondebian.tar'
wsl --unregister Debian

###+++++++ Import Debian deb-main +++++++###

wsl --import deb-master $wslpath'\master\' $wslpath_full'\dockerondebian.tar'
wsl -d deb-master -u root exit
wsl -d deb-master -u root service --status-all
Start-Sleep -Seconds 15
[System.Collections.ArrayList]$swarm_token = wsl -d deb-master -u root "./scripts/swarmInit.sh"
"#!/bin/bash`n"+$swarm_token[4].Trim()+"`n" | Out-File -FilePath '.\scripts\swarmJoin.sh' -Encoding utf8


###+++++++ Import Debian deb-nodes +++++++###

While($node -gt 0){
    wsl --import deb-node-$node $wslpath'\node-'$node $wslpath_full'\dockerondebian.tar' 
    wsl -d deb-node-$node -u root exit
    wsl -d deb-node-$node -u root service --status-all
    Start-Sleep -Seconds 15
    wsl -d deb-node-$node -u root "./scripts/swarmJoin.sh"
    $node--
    }