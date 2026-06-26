$apiUrl = "https://api.github.com/repos/TheShuiLan/kpm_hide_selinux/releases/tags/v1.0.0"
Write-Output "检查 Release 状态..."
try {
    $release = Invoke-RestMethod -Uri $apiUrl -Method Get
    Write-Output ("Release ID: " + $release.id)
    Write-Output ("Release 已存在，需要上传资产")
    
    # 上传资产
    $uploadUrl = $release.upload_url -replace "{?name,label}", "?name=hide_selinux.kpm"
    $kpmPath = "D:\WorkShip\selux\EXP\kpm_hide_selinux\hide_selinux.kpm"
    
    if (Test-Path $kpmPath) {
        $fileBytes = [System.IO.File]::ReadAllBytes($kpmPath)
        $fileEnc = [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetString($fileBytes)
        
        $headers = @{
            "Content-Type" = "application/octet-stream"
            "Accept" = "application/vnd.github.v3+json"
        }
        
        Write-Output "正在上传 hide_selinux.kpm ..."
        
        # 从 git credential 获取 token
        $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("token:$env:GITHUB_TOKEN"))
        if ($env:GITHUB_TOKEN) {
            $headers["Authorization"] = "Bearer $env:GITHUB_TOKEN"
        }
        
        try {
            $uploadResult = Invoke-RestMethod -Uri $uploadUrl -Method Post -Headers $headers -Body $fileEnc -ContentType "application/octet-stream"
            Write-Output ("上传成功! Asset ID: " + $uploadResult.id)
            Write-Output ("下载 URL: " + $uploadResult.browser_download_url)
        } catch {
            Write-Output ("上传失败: " + $_.Exception.Message)
            Write-Output ("请手动创建 Release 并上传文件")
        }
    } else {
        Write-Output "错误: 找不到 hide_selinux.kpm"
    }
} catch {
    Write-Output "错误: " + $_.Exception.Message
    Write-Output "请手动创建 Release"
}