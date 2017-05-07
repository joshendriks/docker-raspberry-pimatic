$PSScriptRoot
$template = Join-Path $PSScriptRoot "Dockerfile.template"
$configfile = Join-Path $PSScriptRoot "build.json"
$config = (Get-Content $configfile) -join "`n" | ConvertFrom-Json

foreach ($image in $config.images) {
	$imagebasename = $image.image
	foreach ($tag in $image.tags) {
	   Write-Host "Writing Dockerfile.$imagebasename.$tag"
	   (Get-Content $template).replace("{{baseimage}}", $image.baseimage).replace("{{tag}}", $tag) | Set-Content "Dockerfile.$imagebasename.$tag"
	}

	foreach ($tag in $image.tags) {
	   $imagename = $image.image + ":" + $tag
	   $maintainer = $config.maintainer
	   Write-Host "Creating $maintainer/$imagename"
	   docker build -t $maintainer/$imagename -f (Join-Path $PSScriptRoot "Dockerfile.$imagebasename.$tag") .
	   docker push $maintainer/$imagename
	}
}