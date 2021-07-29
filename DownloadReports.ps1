# Downloads all SQL Reports from SSRS Server (2008 R2)
# From https://sqlbelle.wordpress.com/2011/03/28/how-to-download-all-your-ssrs-report-definitions-rdl-files-using-powershell/

# note this is tested on PowerShell v2 and SSRS 2008 R2
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Xml.XmlDocument");
[void][System.Reflection.Assembly]::LoadWithPartialName("System.IO");

$ReportServerUri = "";
$Credentials = Get-Credential
$Proxy = New-WebServiceProxy -Uri $ReportServerUri -Namespace SSRS.ReportingService2005 -Credential $Credentials;

# second parameter means recursive
$items = $Proxy.ListChildren("/", $true) | `
        Select-Object Type, Path, ID, Name | `
         Where-Object {$_.type -eq "Report"};

$fullFolderName = $(Get-Location).Path + "\SQL Reports";
[System.IO.Directory]::CreateDirectory($fullFolderName) | out-null

foreach($item in $items)
{
    #need to figure out if it has a folder name
    $subfolderName = split-path $item.Path;
    $fullSubfolderName = $fullFolderName + $subfolderName;
    if(-not(Test-Path $fullSubfolderName))
    {
        #note this will create the full folder hierarchy
        [System.IO.Directory]::CreateDirectory($fullSubfolderName) | out-null
    }
    
    $rdlFile = New-Object System.Xml.XmlDocument;
    [byte[]] $reportDefinition = $null;
    $reportDefinition = $Proxy.GetReportDefinition($item.Path);
    
    # note here we're forcing the actual definition to be 
    # stored as a byte array
    # if you take out the @() from the MemoryStream constructor, you'll 
    #get an error
    [System.IO.MemoryStream] $memStream = New-Object System.IO.MemoryStream(@(,$reportDefinition));
    $rdlFile.Load($memStream);
    
    $fullReportFileName = $fullSubfolderName + "\" + $item.Name +  ".rdl";
    # Write-Host $fullReportFileName;
    $rdlFile.Save( $fullReportFileName);

}