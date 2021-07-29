# SSRS Export Data Sources for Reports
# https://docs.microsoft.com/en-us/dotnet/api/reportservice2005.reportingservice2005
# Simon 26/06/20

$ReportServerUri = "";
$Credentials = Get-Credential
$Proxy = New-WebServiceProxy -Uri $ReportServerUri -Namespace SSRS.ReportingService2005 -Credential $Credentials;

# Get all reports
$items = $Proxy.ListChildren("/", $true) | `
    Select-Object Type, Path, ID, Name | `
    Where-Object { $_.type -eq "Report" };

Start-Transcript -Path .\ReportDataSources.txt

foreach ($item in $items) {
    $path = $item.Path;
    $datasources = $Proxy.GetItemDataSources($path);
    Write-Host Report: $item.path;
    # Print each data source path
    foreach ($datasource in $datasources) {
        Write-Host $datasource.Item.Reference
    }
    Write-Host "";
}

Stop-Transcript
