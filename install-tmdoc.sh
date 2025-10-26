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
    if [[ "`echo $PATH | grep /.local/bin`" == "" ]]; then 
        echo "~/.local/bin is not in your PATH"
        echo "add the following line to your .bashrc or .zshrc file"
        echo "echo \$PATH | grep -q /.local/bin || export PATH=~/.local/bin:\$PATH"
        yes_or_no "Do you like to add this PATH adaptation to your .bashrc file?" && add_local_bin_path
    else 
        echo "~/.local/bin is already in your PATH"
    fi 

}

function add_local_bin_path {
    echo "echo \$PATH | grep -q /.local/bin || export PATH=~/.local/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc    
    echo "Path was updated in .bashrc"
}
function yes_or_no {
   while true; do
       read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

if [[ ! -d ~/.local/bin ]]; then
    mkdir ~/.local/bin
fi

installBinary https://github.com/mittelmark/ tmdoc
installBinary https://github.com/mittelmark/ mndoc  
    
