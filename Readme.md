# Change-LocalAdminPasswords

Changes the Local Administrator password on remote machines in the domain

## Installation

Use the git client to clone this repository to your local machine. Either place the local repository in your `$env:USERPROFILE\WindowsPowerShell\Modules` directory or somewhere else and use `Import-Module` to load the script into your current PowerShell window.

Alternatively, download the script from the GitHub page as a `.zip` file and put it in your `$Home\[My ]Documents\WindowsPowerShell\Modules` directory or an alternate location.

Installation example:
```powershell
cd $env:USERPROFILE\WindowsPowerShell\Modules
git clone https://github.com/huntsman95/Change-LocalAdminPasswords.git
```

## Usage
Example 1

    Get-ADComputer -Filter * | Change-LocalAdminPasswords
    Status                                                         ComputerName                                                   LocalAdminPassword
    ------                                                         ------------                                                   ------------------
    Success                                                        SRV-HORIZON.testdomain.local                                   H&;tKpHwXaAHePYb

Example 2

    Get-ADComputer SRV-HORIZON | Change-LocalAdminPasswords -PasswordLength 8
    Status                                                         ComputerName                                                   LocalAdminPassword
    ------                                                         ------------                                                   ------------------
    Success                                                        SRV-HORIZON.testdomain.local                                   H&;tKpHw


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html)