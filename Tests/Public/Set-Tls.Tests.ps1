$ModulePath = "$PSScriptRoot\..\..\BetterTls\BetterTls.psd1"
Import-Module $ModulePath -Force

Describe "Set-Tls" {
    BeforeAll {
        $Original = [System.Net.ServicePointManager]::SecurityProtocol
        $OriginalPreference = $ConfirmPreference
        $Global:ConfirmPreference = 'None'
    }

    BeforeEach {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::SystemDefault
    }

    It "Sets TLS via switch <Expected>" -TestCases @(
        @{params = @{Tls = $True}; Expected = [System.Net.SecurityProtocolType]'Tls' }
        @{params = @{Tls11 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls11' }
        @{params = @{Tls12 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls12' }
        @{params = @{Tls = $True; Tls11 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls, Tls11' }
        @{params = @{Tls = $True; Tls12 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls, Tls12' }
        @{params = @{Tls11 = $True; Tls12 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls11, Tls12' }
        @{params = @{Tls = $True; Tls11 = $True; Tls12 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls, Tls11, Tls12' }
    ) {
        Param($params, $Expected)
        Set-Tls @params
        Get-Tls | Should -Be $Expected
    }

    It "Supports PassThru for Switches" {
        Set-Tls -Tls12 -PassThru | Should -Be ([System.Net.SecurityProtocolType]'Tls12')
    }

    It "Supports Settings TLS via SecurityProtocolType <Type>" -TestCases @(
        @{Type = [System.Net.SecurityProtocolType]'Tls'}
        @{Type = [System.Net.SecurityProtocolType]'Tls11'}
        @{Type = [System.Net.SecurityProtocolType]'Tls12'}
        @{Type = [System.Net.SecurityProtocolType]'Tls, Tls11'}
        @{Type = [System.Net.SecurityProtocolType]'Tls, Tls12'}
        @{Type = [System.Net.SecurityProtocolType]'Tls11, Tls12'}
        @{Type = [System.Net.SecurityProtocolType]'Tls, Tls11, Tls12'}
    ) {
        param($Type)
        Set-Tls -SecurityProtocol $Type
        Get-Tls | Should -Be $Type
    }

    It "Supports PassThru on SecurityProtocolType" {
        $Tls12 = [System.Net.SecurityProtocolType]'Tls12'
        Set-Tls -SecurityProtocol $Tls12 -PassThru | Should -Be $Tls12
        Get-Tls | Should -Be $Tls12
    }

    It "Supports WhatIf on Switches" {
        $Before = Get-Tls
        Set-Tls -Tls12 -WhatIf
        Get-Tls | Should -Be $Before
    }

    It "Supports WhatIf on SecurityProtocolType" {
        $Before = Get-Tls
        $Tls12 = [System.Net.SecurityProtocolType]'Tls12'
        Set-Tls -SecurityProtocol $Tls12 -WhatIf
        Get-Tls | Should -Be $Before
    }

    AfterAll {
        [System.Net.ServicePointManager]::SecurityProtocol = $Original
        $Global:ConfirmPreference = $OriginalPreference
    }
}
