param (
    [string]$distDir="./dist",
    [string]$archiveName="redscript-collections.zip"
)

if (not (Test-Path "./target/release/redscript_collections.dll")) {
    Write-Error "Build the project first (cargo build --release)"
    exit 1
}

if (Test-Path $distDir) {
    Remove-Item -Recurse -Force $distDir
}

$workingDir = (Get-Location).Path
$scriptsDir = "$distDir/r6/scripts/"
$pluginsDir = "$distDir/red4ext/plugins/"

New-Item -ItemType Directory -Path "$scriptsDir/Collections/"
New-Item -ItemType Directory -Path $pluginsDir

Copy-Item -Path "./assets/reds/*" -Destination "$scriptsDir/Collections" -Recurse -Force
Copy-Item -Path "./target/release/redscript_collections.dll" -Destination $pluginsDir

cd $distDir
Compress-Archive -Path "./*" -DestinationPath "$workingDir/$archiveName" -Force
cd $workingDir
