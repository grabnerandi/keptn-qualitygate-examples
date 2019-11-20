#!/bin/bash

echo "============================================================="
echo "About to install Keptn 0.6.0.beta on your kubernetes cluster!"
echo "============================================================="
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

# TODO: make sure we download v06 once released
wget https://storage.googleapis.com/keptn-cli/0.6.0.beta-20191120.1455/keptn-linux.tar.gz
tar -xvf keptn-linux.tar.gz
chmod +x keptn 
mv keptn ~
rm keptn-linux.tar.gz

# TODO: Validate Release Name
~/keptn install -p=kubernetes --keptn-version=release-0.6.0.beta --use-case=quality-gates --verbose