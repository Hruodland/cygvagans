echo off
echo galaxy

set SH=c:\tools\cygwin\bin\bash.exe

"%SH%" -c "/cygdrive/c/cygwin64/opt/ansible/bin/ansible-galaxy %*"


@echo off
