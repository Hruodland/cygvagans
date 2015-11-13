# cygvagans
Powershell script to install cygwin+ansible+vagrant on a  windows desktop.
The scripts uses chocolatey to install cygwin and  vagrant packages.
Ansible is installed using python pip.
Virtualbox is  not installed.

It is not intended as a silent installation. (questions will be asked, setups will be shown.)
See the comments in the script for more details.



Usage:

First set execution policy from a powershell prompt:  Set-ExecutionPolicy RemoteSigned.
(If not done , you have to do ths once).

Then run the install script:
Powershell -F cygwin_ansible.ps1

Do not use other programs during setup.


Using behind a corporate proxy:
Try to use cntlm , a version with ntlm  session autentication can be found in:
https://github.com/Evengard/cntlm (Compile in cygwin).


Manual actions:<br>
1 Create a directory c:\tools. (Manual because you may have to use administrator)<br>
2 Add to ~/.bash_profile (cygwin ssh has ssh multiplexing issues):
  ```
  export ANSIBLE_SSH_ARGS='-o ControlMaster=no'
  ```
