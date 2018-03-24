<#
	.NOTES

	 Created with: 	VSCode
	 Created on:   	4/23/2017
     Edited on::    5/11/2017
	 Created by:   	Mark Kraus
	 Organization:
	 Filename:     	psake.ps1

	.DESCRIPTION
		psake Build Automation
#>
# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
    $ProjectRoot = $ENV:BHProjectPath
    if (-not $ProjectRoot) {
        $ProjectRoot = (Resolve-Path ..\).Path
    }
    $ModuleFolder = Split-Path -Path $ENV:BHPSModuleManifest -Parent
    # Configured in appveyor.yml
    $ModuleName = $ENV:ModuleName
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
        if(
            $CurrentVersion.Minor    -eq 0 -and
            $CurrentVersion.Build    -eq 0 -and
            $CurrentVersion.Revision -eq 0
         ){
             #This is a major version release, don't molest the the version
             $BuildVersion = $CurrentVersion
        }
        If ($GalleryVersion -gt $BuildVersion) {
            $BuildVersion = $GalleryVersion
        }
    }
    $BuildDate = Get-Date -uFormat '%Y-%m-%d'
    $ReleaseNotes = "$ProjectRoot\RELEASE.md"
    $ChangeLog = "$ProjectRoot\docs\ChangeLog.md"
    $MkdcosYmlHeader = "$ProjectRoot\Config\header-mkdocs.yml"
    $CodeCoverageExclude = @()
    $Environment = Get-EnvironmentInformation
    $DotnetCLIChannel = "release"
    $DotnetCLIRequiredVersion = "2.0.0"
}

Task Default -Depends Init, Build, Test, BuildDocs, TestDocs, Deploy, PostDeploy

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH* | Format-List
    "`n"
    "Current Version: $CurrentVersion`n"
    "Build Version: $BuildVersion`n"
    "Environment:"
    $Environment
    Find-Dotnet
}

Task Build -Depends Init {
    $lines
    if (Test-Path "$ModuleFolder\Public\") {
        "Populating AliasesToExport and FunctionsToExport"
        # Load the module, read the exported functions and aliases, update the psd1
        $FunctionFiles = Get-ChildItem "$ModuleFolder\Public\" -Filter '*.ps1' -Recurse |
            Where-Object { $_.Name -notmatch '\.tests{0,1}\.ps1' }
        $ExportFunctions = @()
        $ExportAliases = @()
        foreach ($FunctionFile in $FunctionFiles) {
            "- Processing $($FunctionFile.FullName)"
            $AST = [System.Management.Automation.Language.Parser]::ParseFile($FunctionFile.FullName, [ref]$null, [ref]$null)
            $Functions = $AST.FindAll( {
                    $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]
                }, $true)
            if ($Functions.Name) {
                $ExportFunctions += $Functions.Name
            }
            $Aliases = $AST.FindAll( {
                    $args[0] -is [System.Management.Automation.Language.AttributeAst] -and
                    $args[0].parent -is [System.Management.Automation.Language.ParamBlockAst] -and
                    $args[0].TypeName.FullName -eq 'alias'
                }, $true)
            if ($Aliases.PositionalArguments.value) {
                $ExportAliases += $Aliases.PositionalArguments.value
            }
        }
        "- Running Update-MetaData -Path $env:BHPSModuleManifest -PropertyName FunctionsToExport -Value : `r`n  - {0}" -f ($ExportFunctions -Join "`r`n  - ")
        Update-MetaData -Path $env:BHPSModuleManifest -PropertyName FunctionsToExport -Value $ExportFunctions
        "- Update-Metadata -Path $env:BHPSModuleManifest -PropertyName AliasesToExport -Value : `r`n  - {0}" -f ($ExportAliases -Join "`r`n  - ")
        Update-Metadata -Path $env:BHPSModuleManifest -PropertyName AliasesToExport -Value $ExportAliases
    }
    Else {
        "$ModuleFolder\Public\ not found. No public functions to import"
    }

    "Populating ScriptsToProcess"
    # Scan the Enums and Classes folders and add all Files to ScriptsToProcess
    # These scripts will be loaded in the Global Scope upon module import
    # This is an unfortunate requirement for v5 classes and Enums
    $Parameters = @{
        Path        = @(
            "$ModuleFolder\Enums\"
            "$ModuleFolder\Classes\"
        )
        Filter      = '*.ps1'
        Recurse     = $true
        ErrorAction = 'SilentlyContinue'
    }
    $ExportScripts = Get-ChildItem @Parameters |
        Where-Object { $_.Name -notmatch '\.tests{0,1}\.ps1' } |
        ForEach-Object { $_.fullname.replace("$ModuleFolder\", "") }
    if ($ExportScripts) {
        "- Running Update-Metadata: `r`n  - {0}" -f ( $ExportScripts -Join "`r`n  - ")
        Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ScriptsToProcess -Value $ExportScripts
    }
    else {
        "No scripts found to add to ScriptsToProcess"
    }

    # Bump the module version
    "Updating Module version to $BuildVersion"
    Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -Value $BuildVersion

    # Update release notes with Version info and set the PSD1 release notes
    $parameters = @{
        Path        = $ReleaseNotes
        ErrorAction = 'SilentlyContinue'
    }
    $ReleaseText = (Get-Content @parameters | Where-Object {$_ -notmatch '^# Version '}) -join "`r`n"
    if (-not $ReleaseText) {
        "Skipping release notes`n"
        "Consider adding a RELEASE.md to your project.`n"
        return
    }
    $Header = "# Version {0} ({1})`r`n" -f $BuildVersion, $BuildDate
    $ReleaseText = $Header + $ReleaseText
    $ReleaseText | Set-Content $ReleaseNotes
    Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ReleaseNotes -Value $ReleaseText

    # Update the ChangeLog with the current release notes
    $ReleaseParameters = @{
        Path        = $ReleaseNotes
        ErrorAction = 'SilentlyContinue'
    }
    $ChangeParameters = @{
        Path        = $ChangeLog
        ErrorAction = 'SilentlyContinue'
    }
    (Get-Content @ReleaseParameters), "`r`n`r`n", (Get-Content @ChangeParameters) | Set-Content $ChangeLog
    "`n"
}

Task Test -depends Init {
    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"
    # Gather test results. Store them in a variable and file
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $Params = @{
        path    = $ModuleFolder
        Include = '*.ps1', '*.psm1'
        Recurse = $True
        Exclude = $CodeCoverageExclude
    }
    $CodeCoverageFiles = Get-ChildItem @Params
    $Params = @{
        Script       = "$ProjectRoot\Tests"
        PassThru     = $true
        OutputFormat = 'NUnitXml'
        OutputFile   = "$ProjectRoot\$TestFile"
        Tag          = 'Unit'
        Show         = 'Fails'
        CodeCoverage = $CodeCoverageFiles
    }
    $TestResults = Start-PSRAWPester @Params
    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        $Params = @{
            CodeCoverage = $TestResults.CodeCoverage
            RepoRoot     = $ProjectRoot
        }
        $CodeCovJsonPath = Export-CodeCovIoJson @Params
        Invoke-UploadCoveCoveIoReport -Path $CodeCovJsonPath
    }
    # In Appveyor?  Upload our tests! #Abstract this into a function?
    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        "Uploading $ProjectRoot\$TestFile to AppVeyor"
        "JobID: $env:APPVEYOR_JOB_ID"
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path "$ProjectRoot\$TestFile"))
    }
    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue
    # Run the remaining Non-Unit Build tests
    " "
    $lines
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $Params = @{
        Script       = "$ProjectRoot\Tests"
        PassThru     = $true
        OutputFormat = 'NUnitXml'
        OutputFile   = "$ProjectRoot\$TestFile"
        Tag          = 'Build'
        ExcludeTag   = 'Unit'
        Show         = 'Fails'
    }
    $TestResults = Start-PSRAWPester @Params
    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        "Uploading $ProjectRoot\$TestFile to AppVeyor"
        "JobID: $env:APPVEYOR_JOB_ID"
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path "$ProjectRoot\$TestFile"))
    }
    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue
    " "
}

Task BuildDocs -depends Init {
    $lines
    Start-Job -FilePath "$ProjectRoot\BuildTools\BuildDocs.ps1" -ArgumentList @(
        $env:BHPSModuleManifest
        $ModuleName
        $MkdcosYmlHeader
        $ChangeLog
        $ProjectRoot
        $ModuleFolder
        $ReleaseNotes
        $true
        $true
        $true
    ) | Wait-Job | Receive-Job
    "`n"
}

Task TestDocs -depends Init {
    $lines
    if (
        $ENV:BHBranchName -like 'develop' -or
        $ENV:BHBranchName -like 'CoreRefactor'
    ) {
        'Skipping develop branch'
        return
    }
    "Running Documentation tests`n"
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $Parameters = @{
        Script       = "$ProjectRoot\Tests"
        PassThru     = $true
        Tag          = 'Documentation'
        OutputFormat = 'NUnitXml'
        OutputFile   = "$ProjectRoot\$TestFile"
        Show         = 'Fails'
    }
    $TestResults = Start-PSRAWPester @Parameters
    " "
    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        "Uploading $ProjectRoot\$TestFile to AppVeyor"
        "JobID: $env:APPVEYOR_JOB_ID"
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path "$ProjectRoot\$TestFile"))
    }
    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue
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
        $Params = @{
            Path  = $ProjectRoot
            Force = $true
        }

        Invoke-PSDeploy @Verbose @Params
    }
    else {
        "Skipping deployment: To deploy, ensure that...`n" +
        "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" +
        "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" +
        "`t* Your commit message includes !deploy (Current: $ENV:BHCommitMessage)"
    }
    "`n"
}

Task PostDeploy -depends Init {
    $lines
    if ($ENV:APPVEYOR_REPO_PROVIDER -notlike 'github') {
        "Repo provider '$ENV:APPVEYOR_REPO_PROVIDER'. Skipping PostDeploy"
        return
    }
    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        "git config --global credential.helper store"
        cmd /c "git config --global credential.helper store 2>&1"

        Add-Content "$env:USERPROFILE\.git-credentials" "https://$($env:access_token):x-oauth-basic@github.com`n"

        "git config --global user.email"
        cmd /c "git config --global user.email ""$($ModuleName)-$($ENV:BHBranchName)-$($ENV:BHBuildSystem)@markekraus.com"" 2>&1"

        "git config --global user.name"
        cmd /c "git config --global user.name ""AppVeyor"" 2>&1"

        "git config --global core.autocrlf true"
        cmd /c "git config --global core.autocrlf true 2>&1"
    }

    "git checkout $ENV:BHBranchName"
    cmd /c "git checkout $ENV:BHBranchName 2>&1"

    "git add -A"
    cmd /c "git add -A 2>&1"

    "git commit -m"
    cmd /c "git commit -m ""AppVeyor post-build commit[ci skip]"" 2>&1"

    "git status"
    cmd /c "git status 2>&1"
    # Do not recommit to staging so that clean pull request can be performed
    if (
        $ENV:BHCommitMessage -notmatch '!skiprecommit' -and
        (
            $ENV:BHCommitMessage -match '!forcerecommit' -or
            (
                $ENV:BHBranchName -notlike "staging" -and
                $ENV:BHBranchName -notlike "develop"

            )
        )
    ) {
        "git push origin $ENV:BHBranchName"
        cmd /c "git push origin $ENV:BHBranchName 2>&1"
    }
    # if this is a !deploy on master, create GitHub release
    if (
        $ENV:BHBuildSystem -ne 'Unknown' -and
        $ENV:BHBranchName -eq "master" -and
        $ENV:BHCommitMessage -match '!deploy'
    ) {
        "Publishing Release 'v$BuildVersion' to Github"
        $parameters = @{
            Path        = $ReleaseNotes
            ErrorAction = 'SilentlyContinue'
        }
        $ReleaseText = (Get-Content @parameters) -join "`r`n"
        if (-not $ReleaseText) {
            $ReleaseText = "Release version $BuildVersion ($BuildDate)"
        }
        $Body = @{
            "tag_name"         = "v$BuildVersion"
            "target_commitish" = "master"
            "name"             = "v$BuildVersion"
            "body"             = $ReleaseText
            "draft"            = $false
            "prerelease"       = $false
        } | ConvertTo-Json
        $releaseParams = @{
            Uri         = "https://api.github.com/repos/{0}/releases" -f $ENV:APPVEYOR_REPO_NAME
            Method      = 'POST'
            Headers     = @{
                Authorization = 'Basic ' + [Convert]::ToBase64String(
                    [Text.Encoding]::ASCII.GetBytes($env:access_token + ":x-oauth-basic"));
            }
            ContentType = 'application/json'
            Body        = $Body
        }
        $Response = Invoke-RestMethod @releaseParams
        $Response | Format-List *
    }
    "`n"
}