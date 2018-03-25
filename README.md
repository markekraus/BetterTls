# BetterTls

## Module Information

BetterTls is a PowerShell Module to manage TLS settings for `Invoke-WebRequest` and `Invoke-RestMethod` in Windows PowerShell 5.1 and older.

In Windows PowerShell 5.1 and older, only SSL 3.0 and TLS 1.0 are enabled by default.
Many modern APIs, including GitHub, have begun moving to support only TLS 1.2.
If you attempt to use those APIs with `Invoke-WebRequest` and/or `Invoke-RestMethod` you will received the following error:

```none
Invoke-RestMethod : The request was aborted: Could not create SSL/TLS secure channel.
At line:1 char:1
+ Invoke-RestMethod https://api.github.com/repositories/49609581/issues ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (System.Net.HttpWebRequest:HttpWebRequest) [Invoke-RestMethod], WebException
    + FullyQualifiedErrorId : WebCmdletWebResponseException,Microsoft.PowerShell.Commands.InvokeRestMethodCommand

Invoke-WebRequest : The request was aborted: Could not create SSL/TLS secure channel.
At line:1 char:1
+ Invoke-WebRequest https://api.github.com/repositories/49609581/issues ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (System.Net.HttpWebRequest:HttpWebRequest) [Invoke-WebRequest], WebException
    + FullyQualifiedErrorId : WebCmdletWebResponseException,Microsoft.PowerShell.Commands.InvokeWebRequestCommand
```

This module provides best practice ways to enable and disable TLS protocols.
Many module and script authors are setting these directly without prompting for user consent.
That practice is dangerous as it may decrease the user's security or break access to previously working APIs.
These settings affect .NET APIs beyond just `Invoke-WebRequest` and `Invoke-RestMethod`.
Additionally, the settings persist for the duration of the user's PowerShell Session at the AppDomain level.
These authors mean well, but may not fully understand all the implications of their actions.

The functions in this module require user consent before making changes to the TLS settings,
but only when settings are actually required.
If the user's settings already include the code authors desired settings,
then the user is not prompted and no changes are made.

The confirmation prompts can be suppressed for automation jobs.
However, when working with user facing and interactive code, the prompts should not be suppressed.
This allows the user to be made aware of the changes being made to their session.

PowerShell Core 6.0.0 and later do not require this module.
`Invoke-WebRequest` and `Invoke-RestMethod` are not affected by settings made to `System.Net.ServicePointManager` in PowerShell Core.
TLS 1.0, 1.1, and 1.2 are enabled by default in PowerShell Core.
For more information on this and other differences please [see my blog](https://get-powershellblog.blogspot.com/2017/11/powershell-core-web-cmdlets-in-depth.html).

## Installation

BetterTls is available on the PowerShell Gallery. To install to the following:

```powershell
Install-Module -Scope CurrentUser -Name BetterTls
```

## Including in Your Module

To include BetterTls in your PowerShell Gallery module, add the following to your `.psd1`

```powershell
RequiredModules = @('BetterTls')
```

To enable TLS 1.2 for your module code, include the following in your `.psm1`:

```powershell
Enable-Tls -Tls12
```

That's it!
The user will be prompted to enable TLS 1.2 upon module load.
You can also include this before any code that accesses an endpoint that requires TLS 1.2.
If the user already has TLS 1.2 enabled, they will not be prompted and no changes will be made.
If the user has disabled TLS 1.2 since module load then they would be prompted again to enable it.

## Documentation

You can find documentation [here](https://github.com/markekraus/BetterTls/blob/master/Docs/BetterTls.md) or by running the following in PowerShell:

```powershell
Get-Help Enable-Tls
Get-Help Disable-Tls
Get-Help Set-Tls
Get-Help Get-Tls
```

## Support

For support, please open an [issue](https://github.com/markekraus/BetterTls/issues/new).
