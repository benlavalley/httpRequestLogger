
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Input parameters from Rewst
$user_filter = "*"
$site_name = ""

# Create Object for POST Back to Rewst Later
$PS_Results = New-Object -TypeName psobject

# Get Users
$PS_Results | Add-Member -MemberType NoteProperty -Name "Filter" -Value $user_filter
try {
    if ($null -eq $site_name) {
        $Users = @(Get-ADUser -Filter "DisplayName -like '*$site_name*' -and Enabled -eq 'False'")
        $PS_Results | Add-Member -MemberType NoteProperty -Name "Users" -Value $Users
        $PS_Results | Add-Member -MemberType NoteProperty -Name "Match-Count" -Value $Users.Count
        $PS_Results | Add-Member -MemberType NoteProperty -Name "success" -Value $true
    }
    else {
        $Users = @(Get-ADUser -Filter $user_filter)
        $PS_Results | Add-Member -MemberType NoteProperty -Name "Users" -Value $Users
        $PS_Results | Add-Member -MemberType NoteProperty -Name "Match-Count" -Value $Users.Count
        $PS_Results | Add-Member -MemberType NoteProperty -Name "success" -Value $true
    }
}
catch {
    $PS_Results | Add-Member -MemberType NoteProperty -Name "Error" -Value "failed to list users with supplied filter"
    $PS_Results | Add-Member -MemberType NoteProperty -Name "success" -Value $false
}


$postData = $PS_Results | ConvertTo-Json

# If you want to have a Powershell send it's payload directly to a file (e.g. to replicate on another server, send to Rewst support...)
#$postData | Out-File c:\windows\temp\listusers.txt

# If you want the Powershell to use a POST payload from a file (e.g. trying to replicate on another system) and override the above results...
#$postData = Get-Content -Path "C:\Users\Administrator\Desktop\listusers-bad.txt"

# For reference, the line below was ultimately the fix I came up with for the particular issue I was having -- a 2008 domain controller's utf16-le encoded result was causing problems with the Rewst backend, returning 500 errors.
# I believe this may be making it into the production Powershells as different Powershell cmdlets may use different character set encodings for their results (it isnt just an old PS version issue).
#$postData = [System.Text.Encoding]::UTF8.GetBytes($postData)

# This code is needed to support self-signed certificates in situations where you're sending payloads to the NodeJS app request logger that you want to use HTTPS on.
add-type @"
   using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
           ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# Send data to your own server or send it to Rewst or both...
Invoke-RestMethod -Method 'Post' -Uri 'https://192.168.0.20' -Body $postData -ContentType 'application/json; charset=utf-8'
Invoke-RestMethod -Method 'Post' -Uri 'https://engine.rewst.io/webhooks/custom/action/9deASDDS_r0/06572cea-eASDASD004b1296' -Body $postData -ContentType 'application/json; charset=utf-8'


