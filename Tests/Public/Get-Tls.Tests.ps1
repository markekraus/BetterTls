$ModulePath = "$ENV:BHBuildOutput\$ENV:BHProjectName.psd1"
Import-Module $ModulePath -Force

Describe "Get-Tls" -Tag 'Unit' {
    It "Retrieves the current TLS Settings" {
        Get-Tls | Should -Be ([System.Net.ServicePointManager]::SecurityProtocol)
    }
}