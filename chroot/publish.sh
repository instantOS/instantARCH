#!/bin/bash

# make some iroot settings accessible by normal users

mkdir /etc/iroot


publishsetting() {
    if iroot "$1"
    then
        iroot "$1" > /etc/iroot/"$1"
    fi
}

publishsetting countrycode
publishsetting isvm

echo "finished setting up config permissions"
