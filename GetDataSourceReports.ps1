# SSRS Export Reports Using each Data Source
# https://docs.microsoft.com/en-us/dotnet/api/reportservice2005.reportingservice2005
# Simon 26/06/20

$ReportServerUri = "";
$Credentials = Get-Credential
$Proxy = New-WebServiceProxy -Uri $ReportServerUri -Namespace SSRS.ReportingService2005 -Credential $Credentials;

# Get all data sources
$items = $Proxy.ListChildren("/", $true) | `
    Select-Object Type, Path, ID, Name | `
    Where-Object { $_.type -eq "DataSource" };

Start-Transcript -Path .\DataSourceReports.txt

foreach ($item in $items) {
    $path = $item.Path;
    $reports = $Proxy.ListDependentItems($path) | Where-Object { $_.type -eq "Report" };
    Write-Host Data Source: $item.path;
    # Print each report path
    foreach ($report in $reports) {
        Write-Host $report.Path
    }
    Write-Host "";
}

Stop-Transcript
