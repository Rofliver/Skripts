Param ($sites)
### Istället för en input parameter kan hemsidorna hårdkodas
### $sites = "https://www.google.com", "https://www.bt.se"
$minCertAge = 5
$timeoutMs = 10000
### Disable certificate validation
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    foreach ($site in $sites)
    {
        Write-Host Check $site -f Green
        $req = [Net.HttpWebRequest]::Create($site)
        $req.Timeout = $timeoutMs
            try 
            {
                $req.GetResponse() |Out-Null
            } 
            catch 
            {
                Write-Host URL check error, use following format https://www.XXX.com $site`: $_ -f Red
                Exit 1
            }
        $expDate = $req.ServicePoint.Certificate.GetExpirationDateString()
        ### Formaterar $expDate till rätt datumangivelse, problem pga svensk datetime
        $expDate = Get-date $expDate -Format "dd-MM-yyy HH:mm:ss"
        $certExpDate = [datetime]::ParseExact($expDate, "dd-MM-yyyy HH:mm:ss", $null)
        [int]$certExpiresIn = ($certExpDate - $(get-date)).Days
        $certName = $req.ServicePoint.Certificate.GetName()
        $certThumbprint = $req.ServicePoint.Certificate.GetCertHashString()
        $certEffectiveDate = $req.ServicePoint.Certificate.GetEffectiveDateString()
        $certIssuer = $req.ServicePoint.Certificate.GetIssuerName()
            if ($certExpiresIn -gt $minCertAge)
                {
                    Write-Host The $site certificate expires in $certExpiresIn days [$certExpDate] -f Green
                    Exit 0
                }
            else
                {
                    $message= "The $site certificate expires in $certExpiresIn days"        
                    Write-Host $message [$certExpDate]. Details:`n`nCert name: $certName`Cert thumbprint: $certThumbprint`nCert effective date: $certEffectiveDate`nCert issuer: $certIssuer -f Red
                    Exit 1
                }
    write-host "________________" `n
    }