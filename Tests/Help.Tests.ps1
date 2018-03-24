Describe "Help tests for $ENV:BHProjectName" -Tags Documentation {
    BeforeAll {
        $ModuleName = $ENV:BHProjectName
        $ProjectRoot = (Resolve-Path $ENV:BHProjectPath\..\).Path
        $ModulePath = "$ENV:BHBuildOutput\$ENV:BHProjectName.psd1"
        Import-Module $ModulePath -Force -Global
        $DocsFolder = Join-Path $ProjectRoot "Docs"
        $BaseURL = 'https://github.com/markekraus/BetterTls/tree/master/Docs'
        $functions = Get-Command -Module $ModuleName -CommandType Function
        $PublicHelpFiles = Get-ChildItem -Path $DocsFolder -Filter '*.md' -ErrorAction SilentlyContinue
        $DefaultParams = @(
            'Verbose'
            'Debug'
            'ErrorAction'
            'WarningAction'
            'InformationAction'
            'ErrorVariable'
            'WarningVariable'
            'InformationVariable'
            'OutVariable'
            'OutBuffer'
            'PipelineVariable'
            'WhatIf'
            'Confirm'
        )
    }
    # Public Functions
    foreach ($Function in $Functions) {
        $help = Get-Help $Function.name -Full -ErrorAction SilentlyContinue
        $helpText = $help | Out-String
        $helpDoc = $PublicHelpFiles | Where-Object { $_.BaseName -eq $Function.name}
        Context "$($Function.name) Public Function" {
            it "Has a Valid HelpUri" {
                $Function.HelpUri | Should Not BeNullOrEmpty
                $Pattern = [regex]::Escape("$ModuleBaseURL/$($Function.name)")
                $Function.HelpUri | should Match $Pattern
            }
            It "Has related Links" {
                $help.relatedLinks.navigationLink.uri.count | Should BeGreaterThan 0
            }
            it "Has a description" {
                $help.description | Should Not BeNullOrEmpty
            }
            it "Has an example" {
                $help.examples | Should Not BeNullOrEmpty
            }
            it "Does not have Template artifacts" {
                $helpDoc.FullName | should not Contain '{{.*}}'
            }
            foreach ($parameter in $help.parameters.parameter) {
                if ($parameter -notin $DefaultParams) {
                    it "Has a Parameter description for '$($parameter.name)'" {
                        $parameter.Description.text -join '' | Should Not BeNullOrEmpty
                    }
                }
            }
        }
    }
}
