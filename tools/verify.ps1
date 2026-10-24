$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$reportDirectory = Join-Path $projectRoot 'docs\verification'
New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding($false)
$report = [ordered]@{
    generatedAtUtc = [DateTime]::UtcNow.ToString('o')
    platform = 'Windows host; Flutter widget tests'
    status = 'running'
    projects = @()
}

try {
    foreach ($projectName in @('atelier1', 'profil_etudiant')) {
        Push-Location (Join-Path $projectRoot $projectName)
        try {
            & flutter pub get
            if ($LASTEXITCODE -ne 0) { throw "pub get failed for $projectName" }
            $analysis = & flutter analyze --no-pub 2>&1
            $analysis | Write-Output
            if ($LASTEXITCODE -ne 0) { throw "Analysis failed for $projectName" }
            $tests = & flutter test --no-pub --reporter expanded 2>&1
            $tests | Write-Output
            if ($LASTEXITCODE -ne 0) { throw "Tests failed for $projectName" }
            $testText = $tests -join "`n"
            $testCount = [regex]::Match($testText, '\+(\d+): All tests passed!')
            if (-not $testCount.Success) { throw "Missing passing test summary for $projectName" }
            $report.projects += [ordered]@{
                name = $projectName
                analyze = 'No issues found'
                testsPassed = [int]$testCount.Groups[1].Value
                status = 'passed'
            }
            if ($projectName -eq 'atelier1') {
                $overflow = [regex]::Match($testText, 'EXPECTED_OVERFLOW: (A RenderFlex overflowed by [^\r\n]+)')
                if (-not $overflow.Success) { throw 'The intentional overflow diagnostic was not captured.' }
                $diagnostic = "Captured from the deliberate teaching target at 390 x 844 logical pixels.`n" +
                    "The normal exercise targets are verified separately without overflow.`n`n" +
                    $overflow.Groups[1].Value + "`n"
                [IO.File]::WriteAllText((Join-Path $reportDirectory 'overflow.txt'), $diagnostic, $utf8)
            }
        } finally {
            Pop-Location
        }
    }
    $report.status = 'passed'
} catch {
    $report.status = 'failed'
    $report.error = $_.Exception.Message
    throw
} finally {
    [IO.File]::WriteAllText((Join-Path $reportDirectory 'results.json'), ($report | ConvertTo-Json -Depth 6) + "`n", $utf8)
}
