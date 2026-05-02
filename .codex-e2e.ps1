npm run test:e2e -- --reporter=line *> .codex-e2e.log
$code = $LASTEXITCODE
Set-Content -LiteralPath .codex-e2e.exit -Value $code
exit $code
