function Get-TlsOptions {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param ()
    end {
        if (-Not $Script:options) {
            Write-Verbose 'Generating TLS Options Cache.'
            $Script:Options = @{}
            Foreach ($Name in [System.Enum]::GetNames([System.Net.SecurityProtocolType])) {
                $Script:Options[$Name] = [System.Net.SecurityProtocolType]::$Name
                Write-Verbose "Added '$Name'."
            }
        }
        Write-Verbose "Retrieving TLS Option Cache."
        $Script:Options
    }
}

function Clear-TlsOptions {
    [CmdletBinding()]
    [OutputType()]
    param ()
    end {
        Write-Verbose 'Clearing TLS Options Cache.'
        $Script:Options = $null
    }
}

function Get-Tls {
    [CmdletBinding()]
    [OutputType([System.Net.SecurityProtocolType])]
    param ()
    end {
        Write-Verbose "Retrieving current TLS Settings."
        $Current = [System.Net.ServicePointManager]::SecurityProtocol
        Write-Verbose "Current TLS Settings: $Current"
        $Current
    }
}

function Enable-Tls {
    [CmdletBinding()]
    [OutputType([System.Net.SecurityProtocolType])]
    param (
        [Switch]$Tls12,
        [Switch]$Tls11,
        [Switch]$Tls,
        [Switch]$Ssl3,
        [switch]$PassThru
    )
    process {
        $Options = Get-TlsOptions
        $NewSettings = Get-Tls
        switch ($True) {
            $Tls12.IsPresent { $NewSettings = $NewSettings -bor $Options.Tls12 }
            $Tls11.IsPresent { $NewSettings = $NewSettings -bor $Options.Tls11 }
            $Tls.IsPresent   { $NewSettings = $NewSettings -bor $Options.Tls   }
            $Ssl3.IsPresent  { $NewSettings = $NewSettings -bor $Options.Ssl3  }
        }
        Set-Tls -SecurityProtocol $NewSettings -PassThru:($PassThru.IsPresent)
    }
}

function Disable-Tls {
    [CmdletBinding()]
    [OutputType([System.Net.SecurityProtocolType])]
    param (
        [Switch]$Tls12,
        [Switch]$Tls11,
        [Switch]$Tls,
        [Switch]$Ssl3,
        [switch]$PassThru
    )
    process {
        $Options = Get-TlsOptions
        $NewSettings = Get-Tls
        switch ($True) {
            $Tls12.IsPresent { $NewSettings = $NewSettings -band -bnot $Options.Tls12 }
            $Tls11.IsPresent { $NewSettings = $NewSettings -band -bnot $Options.Tls11 }
            $Tls.IsPresent   { $NewSettings = $NewSettings -band -bnot $Options.Tls   }
            $Ssl3.IsPresent  { $NewSettings = $NewSettings -band -bnot $Options.Ssl3  }
        }
        Set-Tls -SecurityProtocol $NewSettings -PassThru:($PassThru.IsPresent)
    }
}

function Set-Tls {
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
        [switch]$PassThru
    )
    process {
        $Options = Get-TlsOptions
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
            Set-Tls -SecurityProtocol $TlsSettings -PassThru:($PassThru.IsPresent)
        }
        if ( $PSCmdlet.ParameterSetName -eq 'SecurityProtocol' ) {
            if ($TlsSettings -eq $SecurityProtocol) {
                Write-Verbose "TLS Settings unchanged."
            } elseif ($PSCmdlet.ShouldProcess("Changing [System.Net.ServicePointManager] from '$TlsSettings' to '$SecurityProtocol'")) {
                [System.Net.ServicePointManager]::SecurityProtocol = $SecurityProtocol
            }
            if ($PassThru.IsPresent) {
                Get-Tls
            }
        }
    }
}
