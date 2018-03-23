$ModulePath = "$PSScriptRoot\..\BetterTls\BetterTls.psd1"
Import-Module $ModulePath

Describe "Get-Tls" {
    It "Retrieves the current TLS Settings" {
        Get-Tls | Should -Be ([System.Net.ServicePointManager]::SecurityProtocol)
    }
}

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
    }

    AfterAll {
        [System.Net.ServicePointManager]::SecurityProtocol = $Original
        $Global:ConfirmPreference = $OriginalPreference
    }
}

Describe 'Enable-Tls' {
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

    AfterAll {
        [System.Net.ServicePointManager]::SecurityProtocol = $Original
        $Global:ConfirmPreference = $OriginalPreference
    }
}

Describe 'Disable-Tls' {
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

    AfterAll {
        [System.Net.ServicePointManager]::SecurityProtocol = $Original
        $Global:ConfirmPreference = $OriginalPreference
    }
}