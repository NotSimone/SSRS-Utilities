# SSRS Subscriptions Export
# https://docs.microsoft.com/en-us/dotnet/api/reportservice2005.reportingservice2005
# Simon 23/06/20

$ReportServerUri = "";
$Credentials = Get-Credential;
$Proxy = New-WebServiceProxy -Uri $ReportServerUri -Namespace SSRS.ReportingService2005 -Credential $Credentials;

$reports = $Proxy.ListSubscriptions($null, $null) | Sort-Object -Property "Path";

Start-Transcript -Path .\Subscriptions.txt;

foreach ($item in $reports) {
    # Subscriptions seem to be emails or fileshares - I have not seen anything else
    if ($item.DeliverySettings.Extension -eq "Report Server FileShare") {
        Write-Host "Report: $($item.Path)";
        Write-Host "Target: $($item.DeliverySettings.ParameterValues[0].Value)\$($item.DeliverySettings.ParameterValues[1].Value)";
    } elseif ($item.DeliverySettings.Extension -eq "Report Server Email") {
        Write-Host "Report: $($item.Path)";
        Write-Host "Target: $($item.DeliverySettings.ParameterValues[0].Value)";
        if ($item.DeliverySettings.ParameterValues[1].Name -eq "CC") {
            Write-Host "CC:     $($item.DeliverySettings.ParameterValues[1].Value)";
        }
    } else {
        Write-Host "Error $($item.DeliverySettings.Extension)";
    }
    Write-Host "";
}

Stop-Transcript;
