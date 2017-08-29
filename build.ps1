$PSScriptRoot
$template = Join-Path $PSScriptRoot "Dockerfile.template"
$configfile = Join-Path $PSScriptRoot "build.json"
$config = (Get-Content $configfile) -join "`n" | ConvertFrom-Json

foreach ($image in $config.images) {
	$imagebasename = $image.image
	foreach ($tag in $image.tags) {
	   $target = $tag.target
	   $source = $tag.source
	   Write-Host "Writing Dockerfile.$imagebasename.$target"
	   (Get-Content $template).replace("{{baseimage}}", $image.baseimage).replace("{{tag}}", $source) | Set-Content "Dockerfile.$imagebasename.$target"
	   $imagename = $image.image + ":" + $target
	   $maintainer = $config.maintainer
	   Write-Host "Creating $maintainer/$imagename"
	   docker build --no-cache -t $maintainer/$imagename -f (Join-Path $PSScriptRoot "Dockerfile.$imagebasename.$target") .
	   docker push $maintainer/$imagename
	}
}