#!/bin/sh

# Check that the input exists and set vars. Exits if input does not contain 
# two arguments. If it fails it prints a help statement.

# The program expects 2 arguments 
# $1 is the username 
# $2 is the rdp box fqdn 

if [ $# != 2 ]; then
    echo "Usage: $0 <username> <fqdn>"
    exit 0;
fi

user=$1
fqdn=$2

tmp="/tmp/rdesk.$$"
mkdir $tmp

# makes opensshkey with comment of the fqdn 
ssh-keygen -C "$fqdn" -t rsa -b 2048 -f $tmp/tunnelonly


#This line adds magic voodoo to the public key limiting its function
echo "permitopen=\"$fqdn:3389\",command=\"/bin/sh -c 'echo -n You are now connected. Please wait for the remote desktop connection to be made. Closing this window will cause the remote desktop connection to be broken.; while true; do sleep 3600; done'\",no-pty,no-agent-forwarding,no-X11-forwarding " >> $tmp/${user}_tunnelonly.pub

cat $tmp/tunnelonly.pub >> $tmp/${user}_tunnelonly.pub


# Logic for appending the key to the users auth key files or /tmp
if [ "$user" = "$USER" ] ; then
    
    echo "\nThe public key has been appened to your authorizedkeys2 file\n"
    cat $tmp/${user}_tunnelonly.pub >> ~/.ssh/authorized_keys2
else
    cp $tmp/${user}_tunnelonly.pub /tmp/${user}_tunnelonly.pub.$$
    echo "\na copy of the public key has been left in /tmp/${user}_tunnelonly.pub.$$. It needs to added to $user's authorized_keys2 file\n"
fi


# Puts a copy of the remote_desktop folder in /tmp to me modify and emailed.
cp -r /pkgs/cat/autoPortablePutty/remote_desktop $tmp/rdp

# This line converts the private openssh key to the putty standard
eval '/pkgs/putty/puttygen' $tmp/tunnelonly \
    -o $tmp/rdp/PuttyPortable/keys/${user}_tunnelonly.ppk

mv $tmp/${user}_tunnelonly.pub \
    $tmp/rdp/PuttyPortable/keys/${user}_tunnelonly.pub

# copy's default reg settings to putty.reg
cat /pkgs/cat/autoPortablePutty/remote_desktop/PuttyPortable/Data/settings/masterreg \
    >> $tmp/rdp/PuttyPortable/Data/settings/putty.reg

#this section changes the regkey file that stores port putty settings
sed -i "s/_username_/$user/" \
    $tmp/rdp/PuttyPortable/Data/settings/putty.reg 

sed -i "s/_rdpbox_/$fqdn/" \
    $tmp/rdp/PuttyPortable/Data/settings/putty.reg 

sed -i "s/_keypath_/${user}_tunnelonly.ppk/" \
    $tmp/rdp/PuttyPortable/Data/settings/putty.reg

# copies the windows batch script from the parent folder
# and renames it to include the box fqdn
mv $tmp/rdp/PuttyPortable/rdp.bat \
    $tmp/rdp/rdp_to_$fqdn.bat

# compress the entire portable putty directory
(
cd $tmp
zip -qr  rdp.zip rdp
)

# email the user a copy of the zip
echo "To remote desktop to $fqdn, please download and unzip the attached zipfile. Then double click on rdp_to_$fqdn.bat" \
    | mutt -s "How to remote desktop into $fqdn without VPN Connetion" -c johnj@cat.pdx.edu -a $tmp/rdp.zip -- $user@cecs.pdx.edu 

# postrun removes the modified remote_desktop and the .zip in /tmp
rm -rf $tmp
 
