$ModulePath = "$ENV:BHBuildOutput\$ENV:BHProjectName.psd1"
Import-Module $ModulePath -Force

Describe 'Enable-Tls' -Tag 'Unit' {
    BeforeAll {
        $Original = [System.Net.ServicePointManager]::SecurityProtocol
        $OriginalPreference = $ConfirmPreference
        $Global:ConfirmPreference = 'None'
    }

    BeforeEach {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::SystemDefault
    }

    It "It Enables <Expected>" -TestCases @(
        @{params = @{Tls = $True}; Expected = [System.Net.SecurityProtocolType]'Tls' }
        @{params = @{Tls11 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls11' }
        @{params = @{Tls12 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls12' }
        @{params = @{Tls = $True; Tls11 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls, Tls11' }
        @{params = @{Tls = $True; Tls12 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls, Tls12' }
        @{params = @{Tls11 = $True; Tls12 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls11, Tls12' }
        @{params = @{Tls = $True; Tls11 = $True; Tls12 = $True}; Expected = [System.Net.SecurityProtocolType]'Tls, Tls11, Tls12' }
    ) {
        Param($params, $Expected)
        Enable-Tls @params
        Get-Tls | Should -Be $Expected
    }

    It "Supports PassThru" {
        Enable-Tls -Tls12 -PassThru | Should -Be ([System.Net.SecurityProtocolType]'Tls12')
    }

    It "Supports WhatIf" {
        $Before = Get-Tls
        Enable-Tls -Tls12 -WhatIf
        Get-Tls | Should -Be $Before
    }

    AfterAll {
        [System.Net.ServicePointManager]::SecurityProtocol = $Original
        $Global:ConfirmPreference = $OriginalPreference
    }
}
