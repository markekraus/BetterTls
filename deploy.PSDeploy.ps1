if ($ENV:ModuleName -and $ENV:ModuleName.Count -eq 1) {
    Deploy Module {
        By PSGalleryModule {
            FromSource $ENV:BHBuildOutput
            To PSGallery
            WithOptions @{
                ApiKey = $ENV:NugetApiKey
            }
        }
    }
}
