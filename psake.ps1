# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
    $ProjectRoot = (Resolve-Path $ENV:BHProjectPath\..\).Path
    if (-not $ProjectRoot) {
        $ProjectRoot = $PSScriptRoot
    }
    $ModuleFolder = $ENV:BHModulePath
    $ModuleName = $ENV:BHProjectName
    $DestinationManifest = Join-Path $ENV:BHBuildOutput "$ModuleName.psd1"
    $SourceModuleRoot = Join-Path $ENV:BHModulePath "$ModuleName.psm1"
    $DestinationRootModule = Join-Path $ENV:BHBuildOutput "$ModuleName.psm1"
    $DestinationFolder = $ENV:BHBuildOutput
    If (-not $ModuleName) {
        $ModuleName = Split-Path -Path $ModuleFolder -Leaf
    }
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $lines = '----------------------------------------------------------------------'
    $Verbose = @{ }
    if ($ENV:BHCommitMessage -match "!verbose") {
        $Verbose = @{ Verbose = $True }
    }
    $CurrentVersion = [version](Get-Metadata -Path $env:BHPSModuleManifest)
    $BuildVersion = [version]::New($CurrentVersion.Major, $CurrentVersion.Minor, $CurrentVersion.Build, ($CurrentVersion.Revision + 1))
    if ($ENV:BHBranchName -eq "master") {
        $BuildVersion = [version]::New($CurrentVersion.Major, $CurrentVersion.Minor, ($CurrentVersion.Build + 1), 0)
    }
    If ($ENV:BHBranchName -eq "master" -and $ENV:BHCommitMessage -match '!deploy') {
        $GalleryVersion = Get-NextPSGalleryVersion -Name $ModuleName
        $BuildVersion = [version]::New($CurrentVersion.Major, ($CurrentVersion.Minor + 1), 0, 0)
        if (
            $CurrentVersion.Minor -eq 0 -and
            $CurrentVersion.Build -eq 0 -and
            $CurrentVersion.Revision -eq 0
        ) {
            #This is a major version release, don't molest the the version
            $BuildVersion = $CurrentVersion
        }
        If ($GalleryVersion -gt $BuildVersion) {
            $BuildVersion = $GalleryVersion
        }
    }
    $BuildDate = Get-Date -uFormat '%Y-%m-%d'
    $CodeCoverageExclude = @()
    $DocsFolder = Join-Path $ProjectRoot "Docs"
    $TestsFolder = Join-Path $ProjectRoot "Tests"
}

Task Default -Depends Init, Build, Test, BuildDocs, TestDocs, Deploy

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH* | Format-Table -aut | Out-String
    "Current Version: $CurrentVersion`n"
    "Build Version: $BuildVersion`n"
}

Task Build -Depends Init {
    $lines
    New-Item -ItemType Directory -Path $DestinationFolder -Force -ErrorAction SilentlyContinue
    Copy-Item $ENV:BHPSModuleManifest $DestinationManifest -Force

    # Bump the module version
    "Updating Module version to $BuildVersion"
    Update-Metadata -Path $DestinationManifest -PropertyName ModuleVersion -Value $BuildVersion

    if (Test-Path "$ModuleFolder\Public\") {
        "Populating AliasesToExport and FunctionsToExport"
        $FunctionFiles = Get-ChildItem "$ModuleFolder\Public\" -Filter '*.ps1' -Recurse |
            Where-Object { $_.Name -notmatch '\.tests{0,1}\.ps1' }
        $ExportFunctions = [System.Collections.Generic.List[String]]::new()
        $ExportAliases = [System.Collections.Generic.List[String]]::new()
        foreach ($FunctionFile in $FunctionFiles) {
            "- Processing $($FunctionFile.FullName)"
            $AST = [System.Management.Automation.Language.Parser]::ParseFile($FunctionFile.FullName, [ref]$null, [ref]$null)
            $Functions = $AST.FindAll( {
                    $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]
                }, $true)
            if ($Functions.Name) {
                $ExportFunctions.Add($Functions.Name)
            }
            $Aliases = $AST.FindAll( {
                    $args[0] -is [System.Management.Automation.Language.AttributeAst] -and
                    $args[0].parent -is [System.Management.Automation.Language.ParamBlockAst] -and
                    $args[0].TypeName.FullName -eq 'alias'
                }, $true)
            if ($Aliases.PositionalArguments.value) {
                $ExportAliases.Add($Aliases.PositionalArguments.value)
            }
        }
        "- Running Update-MetaData -Path $DestinationManifest -PropertyName FunctionsToExport -Value : `r`n  - {0}" -f ($ExportFunctions -Join "`r`n  - ")
        Update-MetaData -Path $DestinationManifest -PropertyName FunctionsToExport -Value $ExportFunctions
        "- Update-Metadata -Path $DestinationManifest -PropertyName AliasesToExport -Value : `r`n  - {0}" -f ($ExportAliases -Join "`r`n  - ")
        Update-Metadata -Path $DestinationManifest -PropertyName AliasesToExport -Value $ExportAliases
    } Else {
        "$ModuleFolder\Public\ not found. No public functions to import"
    }

    "Populating $DestinationRootModule"
    # Scan the Enums, Classes,Public, and Private folders and add
    # all files  contents to $DestinationRootModule
    $Params = @{
        Path        = @(
            "$ModuleFolder\Enums\"
            "$ModuleFolder\Classes\"
            "$ModuleFolder\Public\"
            "$ModuleFolder\Private\"
        )
        Filter      = '*.ps1'
        Recurse     = $true
        ErrorAction = 'SilentlyContinue'
    }
    Get-ChildItem @Params |
        Where-Object { $_.Name -notmatch '\.tests{0,1}\.ps1' } |
        Get-Content |
        Set-Content -Path $DestinationRootModule -Encoding UTF8
    # Add Content of src psm1 to the end of the destination psm1
    Get-Content $SourceModuleRoot | Add-Content -Path $DestinationRootModule -Encoding UTF8
}

Task Test -depends Init {
    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"
    # Gather test results. Store them in a variable and file
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $Params = @{
        Script       = "$ProjectRoot\Tests"
        PassThru     = $true
        OutputFormat = 'NUnitXml'
        OutputFile   = "$ProjectRoot\bin\$TestFile"
        Tag          = 'Unit'
        Show         = 'Fails'
        CodeCoverage = $DestinationRootModule
    }
    $TestResults = Invoke-Pester @Params

    # In Appveyor?  Upload our tests! #Abstract this into a function?
    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        "Uploading $ProjectRoot\bin\$TestFile to AppVeyor"
        "JobID: $env:APPVEYOR_JOB_ID"
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path "$ProjectRoot\bin\$TestFile"))
    }
    Remove-Item "$ProjectRoot\bin\$TestFile" -Force -ErrorAction SilentlyContinue

    " "
}

Task BuildDocs -depends Init, Build {
    $lines
    Import-Module $DestinationManifest -Force -Global

    $Params = @{
        Module                = $ModuleName
        ErrorAction           = 'SilentlyContinue'
        AlphabeticParamsOrder = $true
        WithModulePage        = $true
        OutputFolder          = $DocsFolder
    }
    New-MarkdownHelp @Params

    $Params = @{
        Path                  = $DocsFolder
        RefreshModulePage     = $true
        AlphabeticParamsOrder = $true
    }
    Update-MarkdownHelpModule @Params

    $Params = @{
        Path       = $DocsFolder
        Force      = $true
        OutputPath = $DestinationFolder
    }
    New-ExternalHelp @Params
    "`n"
}

Task TestDocs -depends Init {
    $lines
    "Running Documentation tests`n"
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $Params = @{
        Script       = "$ProjectRoot\Tests"
        PassThru     = $true
        Tag          = 'Documentation'
        OutputFormat = 'NUnitXml'
        OutputFile   = "$ProjectRoot\bin\$TestFile"
        Show         = 'Fails'
    }
    $TestResults = Invoke-Pester @Params
    " "
    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        "Uploading $ProjectRoot\bin\$TestFile to AppVeyor"
        "JobID: $env:APPVEYOR_JOB_ID"
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path "$ProjectRoot\bin\$TestFile"))
    }
    Remove-Item "$ProjectRoot\bin\$TestFile" -Force -ErrorAction SilentlyContinue
    " "
}

Task Deploy -depends Init {
    $lines

    # Gate deployment
    if (
        $ENV:BHBuildSystem -ne 'Unknown' -and
        $ENV:BHBranchName -eq "master" -and
        $ENV:BHCommitMessage -match '!deploy'
    ) {
        Import-Module -Force -Global $DestinationFolder
        $Params = @{
            Path  = $ProjectRoot
            Force = $true
        }

        Invoke-PSDeploy @Verbose @Params
    } else {
        "Skipping deployment: To deploy, ensure that...`n" +
        "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" +
        "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" +
        "`t* Your commit message includes !deploy (Current: $ENV:BHCommitMessage)"
    }
    "`n"
}
