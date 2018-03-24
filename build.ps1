<#
	.NOTES

	 Created with: 	VSCode
	 Created on:   	4/23/2017
     Edited on:     4/23/2017
	 Created by:   	Mark Kraus
	 Organization:
	 Filename:     	build.ps1

	.DESCRIPTION
		Build Initialization
#>
param ($Task = 'Default')

Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

$PSDefaultParameterValues['Install-Module:Scope'] = 'CurrentUser'

@(
    @{Name = 'Psake'; MaximumVersion = '4.7.0'}
    @{Name = 'PSDeploy'; MaximumVersion = '0.2.3'}
    @{Name = 'BuildHelpers'; MaximumVersion = '1.0.1'}
    @{Name = 'PSScriptAnalyzer'; MaximumVersion = '1.0.1'}
) | Foreach-Object {
    $Params = $_
    Install-Module -Force @Params
    Import-Module -Global -Force @Params
}

Set-BuildEnvironment -ErrorAction SilentlyContinue

Invoke-psake -buildFile .\psake.ps1 -taskList $Task -nologo
exit ([int](-not $psake.build_success))
