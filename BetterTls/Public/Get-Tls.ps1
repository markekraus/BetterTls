function Get-Tls {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "TLS is singular.")]
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
