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
    New-Item -Path $wslpath+$wslpath_pref -ItemType 'directory'
}

wsl --export Debian $wslpath+$wslpath_pref dockerondebian.tar
wsl --unregister Debian

###+++++++ Import Debian deb-main +++++++###

wsl --import deb-master $wslpath'\master\' $wslpath_full'\dockerondebian.tar' 
wsl --import deb-node $wslpath'\node-'$node $wslpath_full'\dockerondebian.tar' 