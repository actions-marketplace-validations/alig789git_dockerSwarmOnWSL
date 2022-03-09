# dockerSwarmOnWSL
Create docker Swarm cluster on Windows WSL

How to use (by default):

  1. Run Powershell with admins permissions (click Run as Administrator)
  2.  PS > Push-Location 'Path to localy repository copy'/dockerSwarmOnWSL
  3.  PS > .\install.ps1
  4.  Enter quantity of nodes

Parmeters:
  -IsInstallWSL [bool] $installWSL=$false - necessary install WSL2, FALSE by default
  -CreateDistibution [bool] $createDistro=$true - necessary create the prototype WSL VM with Docker Engine, by default TRUE
  -IsDeployMaster [bool] $deployMaster=$true - necessary deploy Master, Swarm manager, by default TRUE
  -IsDeployNodes [bool] $deployNodes = $true - necessary deploy Nodes, by default TRUE
  -QuantityNodes [int] $node - request, quantity nodes
  -WSLDeployPath $wslpath='C:\WSL' - path to WSL deploy, by default C:\WSL, C:\WSL\distro\ - path to prototype

Examples:

  1. Install WSL, Create prototype, Deploy Master, Deploy 2 nodes
    PS > .\install.ps1 -IsInstallWSL $true -QuantityNodes 2
    
  2. Don't install WSL, Create prototype, Deploy Master, Deploy 2 nodes
    PS > .\install.ps1 -QuantityNodes 2
    
  3. Add 1 node to deploy (require ./scripts/swarmJoin.sh with join token)
    PS > .\install.ps1 -CreateDistibution $false -IsDeployMaster $false -QuantityNodes 1
