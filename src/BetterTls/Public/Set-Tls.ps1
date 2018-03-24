function Set-Tls {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "TLS is singular.")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Switch')]
    [OutputType([System.Net.SecurityProtocolType])]
    param (
        [Parameter(ParameterSetName = 'Switch')]
        [Switch]$Tls12,
        [Parameter(ParameterSetName = 'Switch')]
        [Switch]$Tls11,
        [Parameter(ParameterSetName = 'Switch')]
        [Switch]$Tls,
        [Parameter(ParameterSetName = 'Switch')]
        [Switch]$Ssl3,

        [Parameter(ParameterSetName = 'SecurityProtocol', Mandatory)]
        [System.Net.SecurityProtocolType]
        $SecurityProtocol,

        [Parameter(ParameterSetName = 'Switch')]
        [Parameter(ParameterSetName = 'SecurityProtocol')]
        [switch]$PassThru,

        [Parameter(DontShow, ParameterSetName = 'Switch')]
        [Parameter(DontShow, ParameterSetName = 'SecurityProtocol')]
        [System.Management.Automation.PSCmdlet]
        $Caller
    )
    process {
        if (-not $Caller) {
            $Caller = $PSCmdlet
        }
        $Options = Get-TlsOptionCache
        $TlsSettings = Get-Tls
        if ( $PSCmdlet.ParameterSetName -eq 'Switch') {
            switch ($True) {
                $Tls12.IsPresent { $TlsSettings = $TlsSettings -bor $Options.Tls12 }
                $Tls11.IsPresent { $TlsSettings = $TlsSettings -bor $Options.Tls11 }
                $Tls.IsPresent   { $TlsSettings = $TlsSettings -bor $Options.Tls   }
                $Ssl3.IsPresent  { $TlsSettings = $TlsSettings -bor $Options.Ssl3  }
            }
            switch ($False) {
                $Tls12.IsPresent { $TlsSettings = $TlsSettings -band -bnot $Options.Tls12 }
                $Tls11.IsPresent { $TlsSettings = $TlsSettings -band -bnot $Options.Tls11 }
                $Tls.IsPresent   { $TlsSettings = $TlsSettings -band -bnot $Options.Tls   }
                $Ssl3.IsPresent  { $TlsSettings = $TlsSettings -band -bnot $Options.Ssl3  }
            }
            Set-Tls -SecurityProtocol $TlsSettings -PassThru:($PassThru.IsPresent) -Caller $Caller
        }
        if ( $PSCmdlet.ParameterSetName -eq 'SecurityProtocol' ) {
            if ($TlsSettings -eq $SecurityProtocol) {
                Write-Verbose "TLS Settings unchanged."
            } elseif ($Caller.ShouldProcess("Changing [System.Net.ServicePointManager]::SecurityProtocol from '$TlsSettings' to '$SecurityProtocol'")) {
                [System.Net.ServicePointManager]::SecurityProtocol = $SecurityProtocol
            }
            if ($PassThru.IsPresent) {
                Get-Tls
            }
        }
    }
}
