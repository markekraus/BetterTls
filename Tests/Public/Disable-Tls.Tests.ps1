$ModulePath = "$ENV:BHBuildOutput\$ENV:BHProjectName.psd1"
Import-Module $ModulePath -Force

Describe 'Disable-Tls' -Tag 'Unit' {
    BeforeAll {
        $Original = [System.Net.ServicePointManager]::SecurityProtocol
        $OriginalPreference = $ConfirmPreference
        $Global:ConfirmPreference = 'None'
    }

    BeforeEach {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls, Tls11, Tls12'
    }

    It "It Disables <T>" -TestCases @(
        @{T = 'Tls'; params = @{Tls = $True}; Expected = [System.Net.SecurityProtocolType]'Tls11, Tls12' }
        @{T = 'Tls11'; params = @{Tls11 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls, Tls12' }
        @{T = 'Tls12'; params = @{Tls12 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls, Tls11' }
        @{T = 'Tls, Tls11'; params = @{Tls = $True; Tls11 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls12' }
        @{T = 'Tls, Tls12'; params = @{Tls = $True; Tls12 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls11' }
        @{T = 'Tls11, Tls12'; params = @{Tls11 = $True; Tls12 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls' }
        @{T = 'Tls, Tls11, Tls12'; params = @{Tls = $True; Tls11 = $True; Tls12 = $True}; Expected = [System.Net.SecurityProtocolType]::SystemDefault }
    ) {
        Param($params, $Expected)
        Disable-Tls @params
        Get-Tls | Should -Be $Expected
    }

    It "Supports PassThru" {
        Disable-Tls -Tls -PassThru | Should -Be ([System.Net.SecurityProtocolType]'Tls11, Tls12')
    }

    It "Supports WhatIf" {
        $Before = Get-Tls
        Disable-Tls -Tls12 -WhatIf
        Get-Tls | Should -Be $Before
    }

    AfterAll {
        [System.Net.ServicePointManager]::SecurityProtocol = $Original
        $Global:ConfirmPreference = $OriginalPreference
    }
}
