REM echo off

set HOME=%PWD%

REM You can switch this to work with bash with %CYGWIN%\bin\bash.exe
set SH=c:\tools\cygwin\bin\bash.exe


REM vagrant working directory cd to current script dir:   cd  %~dp0 
echo %VAGRANT_CWD%

"%SH%" -c "export ANSIBLE_SSH_ARGS='-o ControlMaster=no' && cd ${VAGRANT_CWD} && export HOME=%HOME% && export PATH=/usr/bin:$PATH && /bin/ansible-playbook `echo %* | sed -E 's#(.*\-\-private-key=)[^ ]*(.*)#\1~/private_key\2#'`"

@echo off
