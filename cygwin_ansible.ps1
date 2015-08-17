# *******************************************************************
# cygwin_ansible
# Version: 1.0 2015/08/14
#
# *******************************************************************

#REQUIRES -Version 2.0

<#
.SYNOPSIS
    Script to install cygwin+ansible+vagrant on a windows (desktop) pc.
.DESCRIPTION
    The scripts uses chocolatey to install cygwin.
	Then uses cyg-get to install additional cygwin packages.
	It adds required python packages using the python package manager.
	 (Warning: there may be conflicts with existing python installations ).

	It is not intended as a silent installation! (questions will be asked, setups will be shown.
	Intializes the bash shell and setup vagrant (which is a windows installation).
	
	Possible isuses to avoid:
	You can run into problems when %HOME% is set to eg. a network drive instead of the default (unset).
	Avoid having another python installation.
	
.NOTES
    File Name        : cygwin_ansible.ps1
    Author           : Roland van Veen
    Prerequisite     : PowerShell
	Execution policy : Set-ExecutionPolicy RemoteSigned
    Copyright        :
	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
.LINK
	http://www.ansible.com/home
	https://chocolatey.org/
	https://www.vagrantup.com/
	http://www.cygwin.com
	http://cntlm.sourceforge.net/
.EXAMPLE
	1 Create a directory c:\tools (Manual may require Admin rights).

	2 Execute from windows CMD shell:
      powershell -File cygwin_ansible.ps1

	3 Download and install Vagrant
	
	
	Using behind a corp proxy.(NTLM):
	1 Download cntlm. (Portable version works ok)
	2 Set it up (ini file on windows) (cntlm.exe -c cntlm.ini -H to generate password hashes)
	3 cntlm.exe -s -I -c cntlm.ini   (Starts in background)
	4 Use script ntlm_install.cmd instead of directly executing powershell -File cygwin_ansible.ps1
	
.TODO
	*Logging using a log file.
#>
Write-Output 'Starting installation'

#Variables
$choco_exe ='c:\ProgramData\chocolatey\bin\choco.exe'
$date      = get-date –format "MMddyyyyHHMMss"
$logfile   = "Script" + $date + ".log"


#Arrays
$cyg_packages=@(    
"bash-completion           ",
"python                    ",
"pip                       ",
"python-setuptools         ",
"csih                      ",
"gcc-core                  ",
"curl                      ",
"cygutils                  ",
"cygwin                    ",
"diffutils                 ",
"getent                    ",
"git                       ",
"git-completion            ",
"git-email                 ",
"make                      ",
"openssh                   ",
"openssl                   ",
"python-crypto             ",
"python-paramiko           ",
"python-six                ",
"rsync                     ",
"wget                      ",
"which                     ",
"windows-default-manifest  "
)

$pip_packages=@(
 "ecdsa"
,"httplib2"
,"isodate"
,"Jinja2"
,"MarkupSafe"
,"pyaml"
,"pywinrm"
,"PyYAML"
,"Runner"
,"setuptools"
,"six"
,"xmltodict"
,"ansible"
)

#Functions
function Run-Elevated ($scriptblock)
{
  $sh = new-object -com 'Shell.Application'
  $sh.ShellExecute('powershell', "-NoExit -Command $scriptblock", '', 'runas')
}

Function Choco-Download {
	Try {
		 Write-Host 'Install choco'
		 iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
	}
	catch {
		throw "Error downloading chocolatey returns: $?"
	}
}

Function Choco-Install { Param($name)
	Try {
		Write-Host "Install $name"
		$ccmd="install $name --yes --force " 
		#Write-Output "$choco_exe" "$ccmd"`'
		#'Close quote to keep notepad++ happy
		Start-Process -FilePath $choco_exe -ArgumentList "$ccmd" -Wait -NoNewWindow
		#Invoke-Expression -Command "$choco_exe install $name -y"  |  Write-Output
	}
	catch {
		throw "Error installing choco package $name returns: $?"
	}
}


Function  Python-PipInstall { Param($name)
	Try {
    Write-Host "/bin/pip install --upgrade $name"
		C:\tools\cygwin\bin\bash.exe --login -c "/bin/pip install --upgrade $name"
	}
	catch {
		throw "Error installing python package $name returns: $?"
	}
}


Function  Bash-Init {
	Try {
		Write-Host 'Setup bash'
		C:\tools\cygwin\bin\bash.exe -c '/bin/ls'
	}
	catch {
		throw "Error initialising bash returns: $?"
	}
}


# ----------------------------------------------------
# MAIN
# ----------------------------------------------------
if  (-Not(Test-Path $choco_exe)) {
    Choco-Download
}

#Cygwin Setup
Choco-Install($name='cyg-get --force' ) 

Write-Output 'Cygwin base'
Write-Output 'NOTICE: Do not open or click windows while the cygwin installer runs!'
$PROXY=$env:HTTP_PROXY

if ($PROXY){
	Choco-Install($name="cygwin  --ia=`"--quiet-mode --no-admin -p $PROXY`"")
}
Else
{
	Choco-Install($name="cygwin  --ia=`"--quiet-mode --no-admin`"")
}

Write-Output 'Setup extra packages'
Invoke-Expression -Command "powershell -File C:\ProgramData\chocolatey\lib\cyg-get\tools\cyg-get.ps1  $cyg_packages -noadmin" |   Write-Output


#Test and init bash and $HOME
Bash-Init  | Out-Null

# ----------------------------------------------------
# PIP
# ----------------------------------------------------
& C:\tools\cygwin\bin\bash.exe -c "/bin/python -m ensurepip" | Out-Null

Write-Output 'Setup Python packages'
Python-PipInstall([String]::Join(' ',$pip_packages))

#vagrant windows installer
# ----------------------------------------------------
Run-Elevated("c:\ProgramData\chocolatey\bin\choco.exe install -y vagrant")

# ----------------------------------------------------
# POST
# ----------------------------------------------------
#Place ansible cmd file wrapppers in vagrants bin.
Copy-Item ansible-galaxy.cmd C:\HashiCorp\Vagrant\bin -Force
Copy-Item ansible-playbook.cmd C:\HashiCorp\Vagrant\bin -Force

#Setup VAGRANT_HOME ,Use this if you have issues like huge roaming profiles.
#[Environment]::SetEnvironmentVariable("VAGRANT_HOME", "c:\tools\vagrant.d", "User")

#end
