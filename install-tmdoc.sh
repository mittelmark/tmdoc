#!/bin/sh

function installBinary() {    
    BASEURL=$1
    APP=$2
    #echo ${BASEURL}
    RELEASE=`curl -isS $BASEURL/$APP/releases/latest/ | grep -i ^location:`
    VERSION=`echo "$RELEASE" | sed -E 's/.+v([.0-9]+).+/\\1/'`
    URL="https://github.com/mittelmark/$APP/releases/download/v${VERSION}/$APP-${VERSION}.bin"
    curl -fsSL $URL --output ~/.local/bin/$APP
    chmod 755 ~/.local/bin/$APP
    ~/.local/bin/$APP --version
    echo "installed $APP"
}

if [[ ! -d ~/.local/bin ]]; then
    mkdir ~/.local/bin
fi

installBinary https://github.com/mittelmark/ tmdoc
installBinary https://github.com/mittelmark/ mndoc  
    
