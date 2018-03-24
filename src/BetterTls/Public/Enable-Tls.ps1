function Enable-Tls {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "TLS is singular.")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([System.Net.SecurityProtocolType])]
    param (
        [Switch]$Tls12,
        [Switch]$Tls11,
        [Switch]$Tls,
        [Switch]$Ssl3,
        [switch]$PassThru
    )
    process {
        $Options = Get-TlsOptionCache
        $NewSettings = Get-Tls
        switch ($True) {
            $Tls12.IsPresent { $NewSettings = $NewSettings -bor $Options.Tls12 }
            $Tls11.IsPresent { $NewSettings = $NewSettings -bor $Options.Tls11 }
            $Tls.IsPresent   { $NewSettings = $NewSettings -bor $Options.Tls   }
            $Ssl3.IsPresent  { $NewSettings = $NewSettings -bor $Options.Ssl3  }
        }
        Set-Tls -SecurityProtocol $NewSettings -PassThru:($PassThru.IsPresent) -Caller $PSCmdlet
    }
}
