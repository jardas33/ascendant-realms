param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0243BarrosanBuildValidationRoleShellsTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0243"
if ($LASTEXITCODE -ne 0) { throw "v0.243 validation failed." }
Write-Output "PASS_V0243_BARROSAN_BUILD_VALIDATION_ROLE_SHELLS_VALIDATION"
