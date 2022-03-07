$wslpath = 'C:\WSL'
$wslpath_pref = '\distro'
$wslpath_full = $wslpath+$wslpath_pref
$node = 2
###+++++++ Install WSL +++++++###

###+++++++ Install Debian +++++++###

wsl --install -d Debian
wsl -d Debian -u root "./scripts/setDebianDistro.sh"

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


wsl --import deb-node $wslpath'\node-'$node $wslpath_full'\dockerondebian.tar' 
wsl -d deb-node -u root exit
wsl -d deb-node -u root service --status-all
Start-Sleep -Seconds 15

"#!/bin/bash`n"+$swarm_token[4].Trim() | Out-File -FilePath '.\scripts\swarmJoin.sh' -Encoding utf8
wsl -d deb-node -u root "./scripts/swarmJoin.sh"
wsl -d deb-node -u root docker swarm join --token SWMTKN-1-45z62uzpv33tuc4qq5vdo3fpvktzs7umgat8tdfylsv4dg2m0g-evsse8h0oq8tnyo7uhdel377u 172.24.245.193:2377