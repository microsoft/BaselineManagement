Import-LocalizedData -BindingVariable localizedData -FileName VE_Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Specifies the name of the printer
        [Parameter(Mandatory)]
        [System.String] $Name,
        
        ## Specifies the name of the printer driver for the printer
        [Parameter(Mandatory)]
        [System.String] $DriverName,
        
        ## Specifies the name of the port used or created for the printer.
        [Parameter(Mandatory)]
        [System.String] $PortName,
        
        ## Specifies the text to add to the Comment field for the specified printer
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Comment,
        
        ## Specifies the location of the printer
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Location,
        
        ## Specifies whether or not the printer is published in the network directory service
        [Parameter()]
        [System.Boolean] $Published,
        
        ## Specifies the share name of the printer
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ShareName,
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        Import-Module -Name PrintManagement -Verbose:$false;
        $printer = Get-Printer -Name $Name -ErrorAction SilentlyContinue;
        $targetResource = @{
            PrinterName = $Name;
            DriverName = $printer.DriverName;
            PortName = $printer.PortName;
            Comment = $printer.Comment;
            Location = $printer.Location;
            Published = $printer.Published;
            ShareName = $printer.ShareName;
            Ensure = if ($printer) { 'Present' } else { 'Absent' };
        }
        return $targetResource;
    } #end process
} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)]
        [System.String] $Name,
        
        ## Specifies the name of the printer driver for the printer
        [Parameter(Mandatory)]
        [System.String] $DriverName,
        
        ## Specifies the name of the port used or created for the printer.
        [Parameter(Mandatory)]
        [System.String] $PortName,
        
        ## Specifies the text to add to the Comment field for the specified printer
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Comment,
        
        ## Specifies the location of the printer
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Location,
        
        ## Specifies whether or not the printer is published in the network directory service
        [Parameter()]
        [System.Boolean] $Published,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ShareName,
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        $PSBoundParameters['Ensure'] = $Ensure;
        $targetResource = Get-TargetResource @PSBoundParameters;
        $inDesiredState = $true;
        foreach ($propertyName in 'DriverName','PortName','Comment','Location','Published','ShareName','Ensure') {
            if ($PSBoundParameters.ContainsKey($propertyName)) {
                $propertyValue = (Get-Variable -Name $propertyName).Value;
                if ($propertyValue -ne $targetResource.$propertyName) {
                    Write-Verbose ($localizedData.IncorrectPropertyState -f $propertyName, $propertyValue, $targetResource.$propertyName);
                    $inDesiredState = $false;
                }
            }
        }
        if ($inDesiredState) {
            Write-Verbose ($localizedData.ResourceInDesiredState -f $Name);
            return $true;
        }
        else {
            Write-Verbose ($localizedData.ResourceNotInDesiredState -f $Name);
            return $false;
        }
    } #end process
} #end function Test-TargetResource

function Set-TargetResource {
    [CmdletBinding()]
    param (
        ## Specifies the name of the printer
        [Parameter(Mandatory)]
        [System.String] $Name,
        
        ## Specifies the name of the printer driver for the printer
        [Parameter(Mandatory)]
        [System.String] $DriverName,
        
        ## Specifies the name of the port used or created for the printer.
        [Parameter(Mandatory)]
        [System.String] $PortName,
        
        ## Specifies the text to add to the Comment field for the specified printer
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Comment,
        
        ## Specifies the location of the printer
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Location,
        
        ## Specifies whether or not the printer is published in the network directory service
        [Parameter()]
        [System.Boolean] $Published,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ShareName,
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        Import-Module -Name PrintManagement -Verbose:$false;
        $printer = Get-Printer -Name $Name -ErrorAction SilentlyContinue;
        if ($Ensure -eq 'Present') {
            $printerParams = @{
                Name = $Name;
                DriverName = $DriverName;
                PortName = $PortName;
            }
            if ($PSBoundParameters.ContainsKey('Comment')) {
                $printerParams['Comment'] = $Comment;
            }
            if ($PSBoundParameters.ContainsKey('Location')) {
                $printerParams['Location'] = $Location;
            }
            if ($PSBoundParameters.ContainsKey('ShareName')) {
                $printerParams['Shared'] = $true;
                $printerParams['ShareName'] = $ShareName;
                $printerParams['Published'] = $Published;
            }  
            if ($printer) {
                Write-Verbose ($localizedData.UpdatingPrinter -f $Name);
                [ref] $null = Set-Printer @printerParams;
            }
            else {
                Write-Verbose ($localizedData.AddingPrinter -f $Name);
                [ref] $null = Add-Printer @printerParams;
            }
        }
        elseif ($Ensure -eq 'Absent') {
            Write-Verbose ($localizedData.RemovingPrinter -f $Name);
            [ref] $null = $printer | Remove-Printer -Confirm:$false;
        }
    } #end process
} #end function Test-TargetResource
