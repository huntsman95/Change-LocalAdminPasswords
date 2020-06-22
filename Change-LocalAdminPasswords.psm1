#generate password function
$randObj = New-Object System.Random
function Generate-Password {
[cmdletbinding()]
    param(
    [parameter(Mandatory = $false)]$len = 16
    )
$pass = ""

    for ($i = 0; $i -lt $len; $i++) {
        $pass += $([char]($randObj.Next(33,126)))
    }
    $pass
}


#attempt password change function
function Change-LocalPassADSI {
[cmdletbinding()]
    param(
    [parameter(Mandatory = $true)]$Computer,
    [parameter(Mandatory = $true)]$Password
    )
try {
   $account = [ADSI]("WinNT://$Computer/Administrator,user")
   $account.psbase.invoke("setpassword",$Password)
   New-Object -TypeName pscustomobject -Property @{'ComputerName'=$Computer;'LocalAdminPassword'=$Password;'Status'='Success'}
}
catch {
   New-Object -TypeName pscustomobject -Property @{'ComputerName'=$Computer;'LocalAdminPassword'=$Password;'Status'="Failed: $_"}
}
}
#store result in psobject array


#export as CSV
function Test-ComputerConnectivity {
[cmdletbinding()]
    param(
    [parameter(Mandatory = $true)]$DNSHostName
    )

    if ($DNSHostName -ne $null -and $DNSHostName -ne ""){
       New-Object -TypeName pscustomobject -Property @{'dnshostname'=($_.DNSHostName);'reachable'=(Start-FastPingTest ($_.DNSHostName))} -ErrorAction SilentlyContinue
    }

}

function Start-FastPingTest {
[cmdletbinding()]
    param(
    [parameter(Mandatory = $true)]$DNSHostName
    )

    $Ping = New-Object System.Net.NetworkInformation.Ping
    try{$status = $Ping.Send($DNSHostName, 5)}catch{return $false}
    if($status.Status -eq "Success")
        {
            return $true
        }
    else
        {
            return $false
        }
}

function Change-LocalAdminPasswords {
  <#
          .SYNOPSIS
          Changes the Local Administrator password on remote machines in the domain

          .DESCRIPTION
          Changes the Local Administrator password on remote machines in the domain
          Takes output from Get-ADComputer (RSAT)

          .PARAMETER ADComputers
          Pipeline input from Get-ADComputer

          .PARAMETER PasswordLength
          Length of the randomly generated password (defaults to 16 characters)

          .INPUTS
          ADComputers (Pipeline input from Get-ADComputer)

          .OUTPUTS
          System.PSCustomObject

          .EXAMPLE
          C:\PS> Get-ADComputer -Filter * | Change-LocalAdminPasswords
          Status                                                         ComputerName                                                   LocalAdminPassword
          ------                                                         ------------                                                   ------------------
          Success                                                        SRV-HORIZON.testdomain.local                                   H&;tKpHwXaAHePYb

          .EXAMPLE
          C:\PS> Get-ADComputer SRV-HORIZON | Change-LocalAdminPasswords -PasswordLength 8
          Status                                                         ComputerName                                                   LocalAdminPassword
          ------                                                         ------------                                                   ------------------
          Success                                                        SRV-HORIZON.testdomain.local                                   H&;tKpHw

      #>

[cmdletbinding()]
param(
    [parameter(Mandatory = $true, ValueFromPipeline = $true)]$ADComputers,
    [parameter(Mandatory = $false)]$PasswordLength = 16
    )
    Begin{$conCheck = @()}

    Process {

        $ADComputers | % {
                $conCheck += Test-ComputerConnectivity ($_.DNSHostName)
            };
        }


    End {
     $passwords = $conCheck | Where-Object {$_.reachable -eq $true} | % {New-Object -TypeName pscustomobject -Property @{'ComputerName'=($_.DNSHostName); 'LocalAdminPassword'=(Generate-Password -len $PasswordLength)}}
     $ADSIResults = $passwords | % {Change-LocalPassADSI -Computer ($_.ComputerName) -Password ($_.LocalAdminPassword)}

     $ADSIResults += $conCheck | Where-Object {$_.reachable -eq $false} | % {New-Object -TypeName pscustomobject -Property @{'ComputerName'=($_.DNSHostname);'LocalAdminPassword'='FAILED PING TEST';'Status'="Failed Ping Test"}}
     return $ADSIResults
    }
}

Export-ModuleMember Change-LocalAdminPasswords
