$ModulePath = "$PSScriptRoot\..\..\BetterTls\BetterTls.psd1"
Import-Module $ModulePath -Force

Describe "Get-Tls" {
    It "Retrieves the current TLS Settings" {
        Get-Tls | Should -Be ([System.Net.ServicePointManager]::SecurityProtocol)
    }
}