#$args
param(
   [Parameter(Mandatory=$true)]
   $Test
)
#
#Write-Host $args["Test"]

$ScriptPath = "./"
$aFiles = @(Get-ChildItem -Path $ScriptPath -Force -Name -Include *.ps1)

$aFiles | ConvertTo-Json -depth 1