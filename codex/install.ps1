[CmdletBinding()]
param(
    [string]$HomeDirectory = $HOME
)

$ErrorActionPreference = 'Stop'
$codexRoot = $PSScriptRoot
if (-not [IO.Path]::IsPathFullyQualified($HomeDirectory) -or
    -not (Test-Path -LiteralPath $HomeDirectory -PathType Container)) {
    throw 'HomeDirectoryには、存在するディレクトリの絶対パスを指定してください。'
}
$targetHome = (Get-Item -LiteralPath $HomeDirectory -Force).FullName
$entries = @(
    [pscustomobject]@{
        Source = Join-Path $codexRoot 'AGENTS.md'
        Target = Join-Path $targetHome '.codex/AGENTS.md'
        Type = 'SymbolicLink'
    }
)
foreach ($skill in Get-ChildItem -LiteralPath (Join-Path $codexRoot 'skills') -Directory | Sort-Object Name) {
    if (-not (Test-Path -LiteralPath (Join-Path $skill.FullName 'SKILL.md') -PathType Leaf)) {
        throw "SKILL.mdがありません: $($skill.FullName)"
    }
    $entries += [pscustomobject]@{
        Source = $skill.FullName
        Target = Join-Path $targetHome ".agents/skills/$($skill.Name)"
        Type = 'Junction'
    }
}

function Get-ExistingItem([string]$Path) {
    # 切れたリンクも取得し、既存の配置として扱う。
    Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
}

function Test-SameLink($Item, [string]$Source) {
    if ($Item.LinkType -notin @('SymbolicLink', 'Junction')) { return $false }
    $linkTarget = @($Item.Target)[0]
    if (-not $linkTarget) { return $false }
    if (-not [IO.Path]::IsPathFullyQualified($linkTarget)) {
        $linkTarget = Join-Path (Split-Path -Parent $Item.FullName) $linkTarget
    }
    return [IO.Path]::GetFullPath($linkTarget).TrimEnd('\', '/') -ieq
        [IO.Path]::GetFullPath($Source).TrimEnd('\', '/')
}

foreach ($entry in $entries) {
    if (-not (Test-Path -LiteralPath $entry.Source)) {
        throw "原本がありません: $($entry.Source)"
    }
    $existing = Get-ExistingItem $entry.Target
    if ($existing) {
        if (Test-SameLink $existing $entry.Source) { continue }
        throw "配置先が既に存在します。変更せず停止します: $($entry.Target)"
    }
    $parent = Split-Path -Parent $entry.Target
    while ($parent) {
        $parentItem = Get-ExistingItem $parent
        if ($parentItem) {
            if (-not $parentItem.PSIsContainer -or -not (Test-Path -LiteralPath $parent -PathType Container)) {
                throw "親ディレクトリとして使えません: $parent"
            }
            break
        }
        $parent = Split-Path -Parent $parent
    }
}

foreach ($entry in $entries) {
    if (Get-ExistingItem $entry.Target) {
        Write-Output "変更なし: $($entry.Target)"
        continue
    }
    $parent = Split-Path -Parent $entry.Target
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    try {
        New-Item -ItemType $entry.Type -Path $entry.Target -Target $entry.Source | Out-Null
    } catch {
        if ($entry.Type -eq 'SymbolicLink') {
            throw "シンボリックリンクを作成できません: $($entry.Target)。Windowsの開発者モード、または管理者権限が必要な場合があります。設定は自動変更しません。詳細: $_"
        }
        throw
    }
    Write-Output "リンク作成: $($entry.Target)"
}
