function Get-TlsOptionCache {
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
