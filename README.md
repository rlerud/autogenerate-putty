autogenerate-putty
==================


The purpose of this script is to allow VIPs that cannot connect to the VPN a way to RDP to their windows box. 
The script must be run by the user in a unix environment and passed the username and Fully Qualified Domain 
Name of their windows box as arguments. It generates an open ssh key pair. The script only allows RDP tunneling 
through the key pair connection to a specified host by adding some bits to the private key. An email, via mutt, 
containing a zip of Putty portable, putty configuration file, public key, customized .rdp file, and a windows .cmd 
file are then automatically sent to the user. The user must unpack the zip and then double click the .cmd found 
in the top level of the folder. This windows script will call all of the appropriated files and automagically RDP 
through the ssh tunnel. The user will be prompted with a similar RDP logon screen as if they were on the VPN.


System Level Dependencies:
mutt, bash, sed,

