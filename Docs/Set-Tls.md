---
external help file: BetterTls-help.xml
Module Name: BetterTls
online version:
schema: 2.0.0
---

# Set-Tls

## SYNOPSIS

Sets the TLS settings with only those supplied.

## SYNTAX

### Switch (Default)

```
Set-Tls [-Tls12] [-Tls11] [-Tls] [-Ssl3] [-PassThru] [-Caller <PSCmdlet>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### SecurityProtocol

```
Set-Tls -SecurityProtocol <SecurityProtocolType> [-PassThru] [-Caller <PSCmdlet>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

Sets the TLS settings with only those supplied.
Settings not supplied will be disabled.
For example, if `Ssl3, Tls` is currently set and `-Tls -Tls11 -Tls12` is supplied
the result will be `Tls, Tls11, Tls12`.

If the requested settings and the current settings are the same, no action will be taken.

These TLS Settings are used by `Invoke-WebRequest` and `Invoke-RestMethod` when connecting to remote end points.
These settings may also be used by other .NET APIs.
Caution should be used when changing this as you may decrease your security settings
or break access to previously working endpoints.

## EXAMPLES

### Example 1

```powershell
Set-Tls -Tls -Tls11 -Tls12
```

This example enables TLS 1.0, 1.1, and 1.2 and disables all other settings.

### Example 2

```powershell
$Setting = [System.Net.SecurityProtocolType]'Tls11, Tls12'
Set-Tls -SecurityProtocol $Setting
```

This example enables TLS 1.1, and 1.2 and disables all other settings.

## PARAMETERS

### -Caller

This parameter is for internal use only.

```yaml
Type: PSCmdlet
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

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

### -SecurityProtocol

A `System.Net.SecurityProtocolType` to overwrite the current TLS settings with.

```yaml
Type: SecurityProtocolType
Parameter Sets: SecurityProtocol
Aliases:
Accepted values: SystemDefault, Ssl3, Tls, Tls11, Tls12

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Ssl3

If supplied, SSL 3.0 will be enabled.
If not supplied it will be disabled.
If no other settings are supplied, only this setting will be applied.
If other settings are supplied, this setting will be enabled along with the other settings.

```yaml
Type: SwitchParameter
Parameter Sets: Switch
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tls

If supplied, TLS 1.0 will be enabled.
If not supplied it will be disabled.
If no other settings are supplied, only this setting will be applied.
If other settings are supplied, this setting will be enabled along with the other settings.

```yaml
Type: SwitchParameter
Parameter Sets: Switch
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tls11

If supplied, TLS 1.1 will be enabled.
If not supplied it will be disabled.
If no other settings are supplied, only this setting will be applied.
If other settings are supplied, this setting will be enabled along with the other settings.

```yaml
Type: SwitchParameter
Parameter Sets: Switch
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tls12

If supplied, TLS 1.2 will be enabled.
If not supplied it will be disabled.
If no other settings are supplied, only this setting will be applied.
If other settings are supplied, this setting will be enabled along with the other settings.

```yaml
Type: SwitchParameter
Parameter Sets: Switch
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

This function is called by `Enable-Tls` and `Disable-Tls`.

## RELATED LINKS

[https://github.com/markekraus/BetterTls/blob/master/Docs/Set-Tls.md](https://github.com/markekraus/BetterTls/blob/master/Docs/Set-Tls.md)
[Disable-Tls](https://github.com/markekraus/BetterTls/blob/master/Docs/Disable-Tls.md)
[Enable-Tls](https://github.com/markekraus/BetterTls/blob/master/Docs/Enable-Tls.md)
[Get-Tls](https://github.com/markekraus/BetterTls/blob/master/Docs/Get-Tls.md)
