# cygvagans
Powershell script to install cygwin+ansible+vagrant on a  windows desktop.
The scripts uses chocolatey to install cygwin and  vagrant.
Ansible is installed using python pip.
Virtualbox is  not installed.

It is not intended as a silent installation. (questions will be asked, setups will be shown.)

See the comments in the script for more details.

Usage:
Powershell -F cygwin_ansible.ps1

Do not use other programs during setup.


Manual actions:<br>
1 Create a directory c:\tools. (Manual because you may have to use administrator)<br>
2 Add to .bashrc or .bash-profile (cygwin ssh has ssh multiplexing issues):
  ```
  export ANSIBLE_SSH_ARGS='-o ControlMaster=no'
  ```
