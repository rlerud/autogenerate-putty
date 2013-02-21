::==rdp.bat
@echo off
start PuttyPortable\PuttyPortable.exe -load "rdp_no_vpn"

sleep 5

start PuttyPortable\default.rdp
