#!/bin/bash

function installBinary() {
    BASEURL=$1
    APP=$2
    BINDIR="${HOME}/.local/bin"
    mkdir -p "$BINDIR"
    #echo ${BASEURL}
    RELEASE=`curl -isS $BASEURL/$APP/releases/latest/ | grep -i ^location:`
    VERSION=`echo "$RELEASE" | sed -E 's/.+v([.0-9]+).+/\\1/'`
    if [ -x "$BINDIR/$APP" ]; then
        CVERSION=`"$BINDIR/$APP" --version`
    else
        CVERSION="0.0.0"
    fi
    echo "$APP installed version='$CVERSION' Github version='$VERSION'"
    if [ "$VERSION" \> "$CVERSION" ] ; then
        echo "Current $APP version: $CVERSION!"
        echo "New Github Version $VERSION will be installed!"
        URL="https://github.com/mittelmark/$APP/releases/download/v${VERSION}/$APP-${VERSION}.bin"
        curl -fsSL "$URL" --output "$BINDIR/$APP" || { echo "Error: failed to download $URL"; exit 1; }
        chmod 755 "$BINDIR/$APP"
        NV=`"$BINDIR/$APP" --version`
        echo "Success: installed $APP ${NV}!"
        if [ "$APP" == "tmdoc" ]; then
            URL="https://github.com/mittelmark/$APP/releases/download/v${VERSION}/install-tmdoc.sh"
            curl -fsSL "$URL" --output "$BINDIR/tmdoc-update" || { echo "Error: failed to download $URL"; exit 1; }
            chmod 755 "$BINDIR/tmdoc-update"
            echo -e "Success: Installed as well 'tmdoc-update'!\n Run it in the future to update your installation!"
        fi
        echo "Note: $BINDIR may not be in your PATH. Add it if needed, e.g.:"
        echo "  echo \$PATH | grep -q \"/.local/bin\" || export PATH=\$HOME/.local/bin:\$PATH"
    else
        echo "Version of $APP on Github is the same as the local version: $VERSION!"
        echo "No update is needed!"
    fi
}


installBinary https://github.com/mittelmark/ tmdoc
installBinary https://github.com/mittelmark/ mndoc
