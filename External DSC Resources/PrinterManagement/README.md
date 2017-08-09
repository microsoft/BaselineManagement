Included Resources
==================
* PrinterDriver
* Printer

PrinterDriver
===========
Install a printer driver.
###Syntax
```
PrinterDriver [string]
{
    DriverName = [string]
    [InfPath = [string]]
    [Environment = [string]] { x86 | x64 }
    [Ensure = [string]] { Present | Absent }
}
```
###Properties
* **DriverName**: Specifies the printer driver name.
* **InfPath**: Specifies the path to the printer driver INF file in the driver store. INF files contain information about the printer and the printer driver.
* **Environment**: Specifies the printer driver environment.
 * Supported values are 'x64' or 'x86'.
 * If not specified, it defaults to 'x64'.
* **Ensure**: Whether the role is to be installed or not.
 * Supported values are Present or Absent.
 * If not specified, it defaults to Present.

###Configuration
```
Configuration PrinterDriverExample {
    Import-DscResource -ModuleName PrinterManagement
    PrinterDriver PrinterDriverExample {
       DriverName = 'Microsoft XPS Class Driver'
       Environment = 'x64'
       Ensure = 'Present'
    }
}
```

Printer
=======
Creates and shares a local printer.

###Syntax
```
Printer [string]
{
    Name = [string]
    DriverName = [string]
    PortName = [string]
    [Comment = [string]]
    [Location = [string]]
    [Published = [bool]]
    [ShareName = [string]]
    [Ensure = [string]] { Present | Absent }
}
```
###Properties
* **Name**: Specifies the name of the printer.
* **DriverName**: Specifies the name of the printer driver for the printer.
* **PortName**: Specifies the name of the port used or created for the printer.
* **Comment**: Specifies the text to add to the Comment field for the specified printer.
* **Location**: Specifies the location of the printer
* **Published**: Specifies whether or not the printer is published in the network directory service.
 * If not specified, it defaults to $false.
* **ShareName**: Specifies the name by which to share the printer on the network.
* **Ensure**: Whether the role is to be installed or not.
 * Supported values are Present or Absent.
 * If not specified, it defaults to Present.

###Configuration
```
Configuration PrinterExample {
    Import-DscResource -ModuleName PrinterManagement
    Printer SharedExamplePrinter {
        Name = 'Example Printer'
        DriverName = 'Microsoft XPS Class Driver'
        PortName = 'PORTPROMPT:'
        ShareName = 'Shared Printer'
        Published = $true
        Ensure = 'Present'
    }
}
```
