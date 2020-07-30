# convertgpotodsc.exe

Convertgpotodsc.exe is an executable desktop program for converting a Group Policy Object backup to Desired State Configuration through the Baseline Management module. The program is based on the PowerShell script included as convertgpotodsc.ps in the supplementary directory. 

## Installation

Download the convertgpotodsc.exe fill included with the git repository.

## Usage

To use the convertgpotodsc.exe, you need run the executable as administrator. First, the program will prompt for the Group Policy Object backup directory location. Next, the interface will prompt for the Desired State Configuration output location. Finally, the program will prompt for the new name for the DSC PowerShell script. 

## Testing

A sample Group Policy Object backup directory titled {3657C7A2-3FF3-4C21-9439-8FDF549F1D68} is included for testing. 