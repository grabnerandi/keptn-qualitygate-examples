#!/bin/bash

# TODO: make sure we download v06 once released
wget https://storage.googleapis.com/keptn-cli/latest/keptn-linux.tar.gz
tar -xvf keptn-linux.tar.gz
chmod +x keptn 
mv keptn /usr/local/bin

# TODO: remove keptn-version
keptn install -p=kubernetes --keptn-version=bugfix/1128/nginx-ingress --use-case=quality-gates --verbose

