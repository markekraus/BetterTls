Describe "PSScriptAnalyzer Tests" -Tags Build {
    BeforeAll {
        $ModulePath = "$PSScriptRoot\..\BetterTls\BetterTls.psd1"
        $ModuleRoot = Resolve-Path (Split-Path -Parent $ModulePath)
        Import-Module $ModulePath
        $Params = @{
            Path          = $ModuleRoot
            Severity      = @('Error', 'Warning')
            Recurse       = $true
            Verbose       = $false
            ErrorVariable = 'ErrorVariable'
            ErrorAction   = 'SilentlyContinue'
        }
        $ScriptWarnings = Invoke-ScriptAnalyzer @Params
        $scripts = Get-ChildItem $ModuleRoot -Include *.ps1, *.psm1 -Recurse
    }
    foreach ($Script in $scripts) {
        $RelPath = $Script.FullName.Replace($ModuleRoot, '') -replace '^\\', ''
        Context "$RelPath" {
            $Rules = $ScriptWarnings |
                Where-Object {$_.ScriptPath -like $Script.FullName} |
                Select-Object -ExpandProperty RuleName -Unique
            foreach ($rule in $Rules) {
                It "Passes $rule" {
                    $BadLines = $ScriptWarnings |
                        Where-Object {$_.ScriptPath -like $Script.FullName -and $_.RuleName -like $rule} |
                        Select-Object -ExpandProperty Line
                    $BadLines | should be $null
                }
            }
            $Exceptions = $ErrorVariable.Exception.Message |
                Where-Object {$_ -match [regex]::Escape($Script.FullName)}
            foreach ($Exception in $Exceptions) {
                it 'Has no parse errors' {
                    $Exception | should be $null
                }
                break
            }
        }
    }
}
