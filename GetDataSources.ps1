# SSRS Data Sources Export
# https://docs.microsoft.com/en-us/dotnet/api/reportservice2005.reportingservice2005
# Simon 02/06/20

$ReportServerUri = "";
$Credentials = Get-Credential
$Proxy = New-WebServiceProxy -Uri $ReportServerUri -Namespace SSRS.ReportingService2005 -Credential $Credentials;

# Second parameter means recursive
$items = $Proxy.ListChildren("/", $true) | `
    Select-Object Type, Path, ID, Name | `
    Where-Object { $_.type -eq "DataSource" };

Start-Transcript -Path .\DataSources.txt

foreach ($item in $items) {
    $dataSourceDefinition = $Proxy.GetDataSourceContents($item.Path);
    Write-Host Report: $item.Path;
    Write-Host ConnectString: $dataSourceDefinition.ConnectString;
    Write-Host Username: $dataSourceDefinition.UserName;
    Write-Host;
}

Stop-Transcript
