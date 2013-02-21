autogenerate-putty
==================

shell script to autogenerate portable putty with an openssh key, to allow users to ssh tunnel their rdp session.

1. generates a keypairs
2. uses sed to configure the putty registry
3. modifies a windows bash script for easy of use 
4. pulles it all together into a zip
5. mails the user a copy via mutt
