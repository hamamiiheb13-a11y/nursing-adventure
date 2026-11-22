# Lightweight static HTTP server for testing build/web
param([int]$port = 8080)

$prefix = "http://localhost:$port/"
$root = (Resolve-Path "build\web").Path

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Host "Serving Gastro Quest at $prefix from $root"

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".js"   = "application/javascript"
    ".json" = "application/json"
    ".css"  = "text/css"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".wasm" = "application/wasm"
    ".ttf"  = "font/ttf"
    ".otf"  = "font/otf"
}

try {
    while ($listener.IsListening) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response

            $path = $request.Url.LocalPath.TrimStart('/')
            if ($path -like "nursing-adventure/*") {
                $path = $path.Substring(18)
            } elseif ($path -eq "nursing-adventure") {
                $path = "index.html"
            }
            if ([string]::IsNullOrWhiteSpace($path) -or $path -eq '/') {
                $path = "index.html"
            }

            $filePath = Join-Path $root $path
            if (Test-Path $filePath -PathType Leaf) {
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                $mime = $mimeTypes[$ext]
                if ($null -eq $mime) { $mime = "application/octet-stream" }
                $response.ContentType = $mime

                $bytes = [System.IO.File]::ReadAllBytes($filePath)
                $response.ContentLength64 = $bytes.Length

                if ($request.HttpMethod -ne "HEAD") {
                    $response.OutputStream.Write($bytes, 0, $bytes.Length)
                }
            } else {
                $response.StatusCode = 404
                $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
                $response.ContentLength64 = $msg.Length
                if ($request.HttpMethod -ne "HEAD") {
                    $response.OutputStream.Write($msg, 0, $msg.Length)
                }
            }
            $response.Close()
        } catch {
            # Ignore client disconnects or minor I/O glitches so server stays alive
        }
    }
} finally {
    $listener.Stop()
}
