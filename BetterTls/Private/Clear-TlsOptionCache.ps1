function Clear-TlsOptionCache {
    [CmdletBinding()]
    [OutputType()]
    param ()
    end {
        Write-Verbose 'Clearing TLS Options Cache.'
        $Script:Options = $null
    }
}
