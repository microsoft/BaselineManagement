# convertgpotodsc.exe

Convertgpotodsc.exe is an executable desktop program for converting a Group Policy Object backup to Desired State Configuration through the Baseline Management module. The program is based on the PowerShell script included as convertgpotodsc.ps1 in the supplementary directory. 

## Installation

Download the convertgpotodsc.exe fill included with the git repository.

## Usage

To use the convertgpotodsc.exe, you need run the executable as administrator. First, the program will prompt for the Group Policy Object backup directory location. Next, the program will prompt for the Desired State Configuration output location. Finally, the program will prompt for the new name for the DSC PowerShell script. On successful execution, a DSC PowerShell script with the input name will be available at the entered output location. This DSC will have the equivalent content as the GPO backup selected initially.

## Testing

A sample Group Policy Object backup directory titled {3657C7A2-3FF3-4C21-9439-8FDF549F1D68} is included for testing purposes. This GPO is part of the Windows 2019 Server Baseline. Note, that only GPO Conversions for Group Policies affecting Computer Settings are currently supported through Baseline Management. Not all GPO's are convertible through Baseline Management module.
