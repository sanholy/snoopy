#!/bin/bash



### Description
#
# Run build for travis.
#
# Three modes of operation, separated by first argument:
# - 'build':   build and run test suite
# - 'install-script-local':  test local install script
# - 'install-script-remote': test public install script, used in public production
#



### Configure shell first
#
set -e
set -u



### Check arguments, determine operation mode
#
ALL_ARGS="$@"
MODE=${1:-unknown}
case $MODE in

    'build')
        CONFIGURE_FLAGS=`echo "$ALL_ARGS" | sed -e 's/^build//'`
        ;;

    'install-script-local')
        INSTALL_WHAT="$2"
        ;;

    'install-script-remote')
        INSTALL_WHAT="$2"
        ;;

    *)
        echo "ERROR: Invalid run mode: $MODE"
        exit 1
        ;;
esac



### Run in 'build' mode
#
if [ "$MODE" == "build" ]; then

    ./configure $CONFIGURE_FLAGS
    make -j16
    make -j16 check
    exit 0

fi



### Run in 'install-script-local' mode
#
if [ "$MODE" == "install-script-local" ]; then

    if [ "$INSTALL_WHAT" == "release-latest-stable" ]; then
        ./doc/install/bin/snoopy-install.sh stable
        exit 0
    fi

    if [ "$INSTALL_WHAT" == "local" ]; then
        ./configure --enable-everything
        make -j16
        make -j16 check
        make dist
        ./doc/install/bin/snoopy-install.sh snoopy-*.tar.gz
        exit 0
    fi


    echo "ERROR: Invalid run submode: $INSTALL_WHAT"
    exit 1
fi



### Run in 'install-script-remote' mode
#
if [ "$MODE" == "install-script-remote" ]; then

    if [ "$INSTALL_WHAT" == "release-latest-stable" ]; then
        rm -f snoopy-install.sh &&
        wget -q -O snoopy-install.sh https://github.com/a2o/snoopy/raw/install/doc/install/bin/snoopy-install.sh &&
        chmod 755 snoopy-install.sh &&
        ./snoopy-install.sh stable
        exit 0
    fi

    if [ "$INSTALL_WHAT" == "git-master" ]; then
        rm -f snoopy-install.sh &&
        wget -q -O snoopy-install.sh https://github.com/a2o/snoopy/raw/install/doc/install/bin/snoopy-install.sh &&
        chmod 755 snoopy-install.sh &&
        ./snoopy-install.sh git-master
        exit 0
    fi


    echo "ERROR: Invalid run submode: $INSTALL_WHAT"
    exit 1
fi



### Too far, error:)
#
echo "ERROR: Reached unreachable code point, mode: $MODE"
exit 1