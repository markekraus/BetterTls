---
external help file: BetterTls-help.xml
Module Name: BetterTls
online version:
schema: 2.0.0
---

# Get-Tls

## SYNOPSIS

Gets the current TLS configuration.

## SYNTAX

```
Get-Tls [<CommonParameters>]
```

## DESCRIPTION

Retrieves the current setting of `[System.Net.ServicePointManager]::SecurityProtocol`.

These TLS Settings are used by `Invoke-WebRequest` and `Invoke-RestMethod` when connecting to remote end points.
These settings may also be used by other .NET APIs.
Caution should be used when changing this as you may decrease your security settings
or break access to previously working endpoints.

## EXAMPLES

### Example 1

```powershell
Get-Tls
```

Retrieve the current TLS settings.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Net.SecurityProtocolType

## NOTES

## RELATED LINKS

[https://github.com/markekraus/BetterTls/blob/master/Docs/Get-Tls.md](https://github.com/markekraus/BetterTls/blob/master/Docs/Get-Tls.md)
[Disable-Tls](https://github.com/markekraus/BetterTls/blob/master/Docs/Disable-Tls.md)
[Enable-Tls](https://github.com/markekraus/BetterTls/blob/master/Docs/Enable-Tls.md)
[Set-Tls](https://github.com/markekraus/BetterTls/blob/master/Docs/Set-Tls.md)
