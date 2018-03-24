---
external help file: BetterTls-help.xml
Module Name: BetterTls
online version:
schema: 2.0.0
---

# Enable-Tls

## SYNOPSIS

Enables one or more supplied TLS versions without affecting other settings.

## SYNTAX

```
Enable-Tls [-Tls12] [-Tls11] [-Tls] [-Ssl3] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Enables one or more supplied TLS versions.
Other versions will not be affected.
For example, it `-Tls` is supplied and `Tls11` is currently configured, the result will be `Tls, Tls11`.

These TLS Settings are used by `Invoke-WebRequest` and `Invoke-RestMethod` when connecting to remote end points.
These settings may also be used by other .NET APIs.
Caution should be used when changing this as you may decrease your security settings
or break access to previously working endpoints.

## EXAMPLES

### Example 1

```powershell
# Enable TLS 1.2
Disable-Tls -Tls12
```

The above example will enable TLS 1.2.

## PARAMETERS

### -PassThru

By default, this cmdlet does not supply any output.
Supplying `-PassThru` will cause the cmdlet to return the current TLS configuration.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Ssl3

If supplied, SSL 3.0 will be enabled.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tls

If supplied, TLS 1.0 will be enabled.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tls11

If supplied, TLS 1.1 will be enabled.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tls12

If supplied, TLS 1.2 will be enabled.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Net.SecurityProtocolType

## NOTES

This function calls `Set-Tls`.

## RELATED LINKS

[https://github.com/markekraus/BetterTls/blob/master/Docs/Enable-Tls.md](https://github.com/markekraus/BetterTls/blob/master/Docs/Enable-Tls.md)
[Disable-Tls](https://github.com/markekraus/BetterTls/blob/master/Docs/Disable-Tls.md)
[Get-Tls](https://github.com/markekraus/BetterTls/blob/master/Docs/Get-Tls.md)
[Set-Tls](https://github.com/markekraus/BetterTls/blob/master/Docs/Set-Tls.md)
