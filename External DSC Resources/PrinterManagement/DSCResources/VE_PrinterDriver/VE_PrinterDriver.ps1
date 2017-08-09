Import-LocalizedData -BindingVariable localizedData -FileName VE_Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Printer driver name
        [Parameter(Mandatory)]
        [System.String] $DriverName,
        
        ## Specifies the path to the printer driver INF file in the driver store. INF files contain information about the printer and the printer driver.
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $InfPath,
        
        ## Specifies the printer driver environment.
        [Parameter()] [ValidateSet('x86','x64')]
        [System.String] $Environment = 'x64',
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        Import-Module -Name PrintManagement -Verbose:$false;
        $printerEnvironment = if ($Environment -eq 'x64') { 'Windows x64' } else { 'Windows NT x86' };
        $printerDriver = Get-PrinterDriver -Name $DriverName -PrinterEnvironment $printerEnvironment -ErrorAction SilentlyContinue;
        $targetResource = @{
            DriverName = $DriverName;
            InfPath = $printerDriver.InfPath;
            Environment = if ($printerDriver.PrinterEnvironment -eq 'Windows x64') { 'x64' } else { 'x86' };
            Ensure = if ($printerDriver) { 'Present' } else { 'Absent' };
        }
        return $targetResource;
    } #end process
} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Printer driver name
        [Parameter(Mandatory)]
        [System.String] $DriverName,
        
        ## Specifies the path to the printer driver INF file in the driver store. INF files contain information about the printer and the printer driver.
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $InfPath,
        
        ## Specifies the printer driver environment.
        [Parameter()] [ValidateSet('x86','x64')]
        [System.String] $Environment = 'x64',
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        $PSBoundParameters['Ensure'] = $Ensure;
        $PSBoundParameters['Environment'] = $Environment;
        $targetResource = Get-TargetResource @PSBoundParameters;
        $inDesiredState = $true;
        foreach ($propertyName in 'DriverName','InfPath','Environement','Ensure') {
            if ($PSBoundParameters.ContainsKey($propertyName)) {
                $propertyValue = (Get-Variable -Name $propertyName).Value;
                if ($propertyValue -ne $targetResource.$propertyName) {
                    Write-Verbose ($localizedData.IncorrectPropertyState -f $propertyName, $propertyValue, $targetResource.$propertyName);
                    $inDesiredState = $false;
                }
            }
        }
        if ($inDesiredState) {
            Write-Verbose ($localizedData.ResourceInDesiredState -f $DriverName);
            return $true;
        }
        else {
            Write-Verbose ($localizedData.ResourceNotInDesiredState -f $DriverName);
            return $false;
        }
    } #end process
} #end function Test-TargetResource

function Set-TargetResource {
    [CmdletBinding()]
    param (
        ## Printer driver name
        [Parameter(Mandatory)]
        [System.String] $DriverName,
        
        ## Specifies the path to the printer driver INF file in the driver store. INF files contain information about the printer and the printer driver.
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $InfPath,
        
        ## Specifies the printer driver environment.
        [Parameter()] [ValidateSet('x86','x64')]
        [System.String] $Environment = 'x64',
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        Import-Module -Name PrintManagement -Verbose:$false;
        $printerDriverParams = @{
            Name = $DriverName;
            PrinterEnvironment = if ($Environment -eq 'x64') { 'Windows x64' } else { 'Windows NT x86' };
        }
        if ($Ensure -eq 'Present') {
            if ($PSBoundParameters.ContainsKey('InfPath')) {
                $printerDriverParams['InfPath'] = $InfPath;
            }
            Write-Verbose ($localizedData.AddPrinterDriver -f $DriverName);
            [ref] $null = Add-PrinterDriver @printerDriverParams;
        }
        elseif ($Ensure -eq 'Absent') {
            Write-Verbose ($localizedData.RemovingPrinterDriver -f $DriverName);
            [ref] $null = Get-PrinterDriver @printerDriverParams | Remove-PrinterDriver;
        }
    } #end process
} #end function Set-TargetResource
