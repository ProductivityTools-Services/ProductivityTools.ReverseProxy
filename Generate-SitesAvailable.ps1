$uri = "https://script.google.com/macros/s/AKfycbyMXkh3v12rqFIkeDG3dzK6WRta9TKilVJ3IOUqt-1599PnwrP5KP_-wPUyOXDbW44Z/exec"
$targetDir = Join-Path $PSScriptRoot "sites-available"
# 1. Remove all files from the sites-available directory
if (Test-Path $targetDir) {
    Write-Host "Clearing directory: $targetDir"
    Remove-Item -Path "$targetDir\*" -Force -Recurse
} else {
    Write-Host "Creating directory: $targetDir"
    New-Item -ItemType Directory -Path $targetDir -Force
}

# 2. Fetch data from the endpoint
Write-Host "Fetching data from $uri"
try {
    $response = Invoke-RestMethod -Uri $uri -Method Get
    if ($response -is [string]) {
        # Some PowerShell versions fail to parse JSON with empty property names ("": "value")
        # We replace them with a dummy name before parsing.
        $response = $response -replace '"":', '"EmptyName":'
        $response = $response | ConvertFrom-Json
    }
    $data = $response.data
} catch {
    Write-Error "Failed to fetch data: $_"
    exit
}

# 3. Generate files
foreach ($item in $data) {
    if (-not $item.Address -or -not $item.Ip -or -not $item.Port -or $item.Address -eq "#REF!" -or $item.Address -eq ".productivitytools.top") {
        Write-Verbose "Skipping incomplete or invalid item: $($item | ConvertTo-Json -Compress)"
        continue
    }

    $port = $item.Port
    $fileName = $item.Address
    $filePath = Join-Path $targetDir $fileName

    $config = @"
server {
        listen 80;
        listen [::]:80;

        server_name $($item.Address);

        location / {
                proxy_pass http://$($item.Ip):$port;
        }
}
"@

    Write-Host "Generating file: $fileName"
    $config | Out-File -FilePath $filePath -Encoding utf8 -NoNewline
}

Write-Host "Generation complete."
