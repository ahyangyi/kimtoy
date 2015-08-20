#!/bin/sh

APP=kimtoy
MODULE=extragear-utils
KDESVNROOT=svn://anonsvn.kde.org/home/kde

mkdir po
for lang in $(svn cat $KDESVNROOT/trunk/l10n-kde4/subdirs); do
    # skip x-test
    [ "$lang" == "x-test" ] && continue
    # check out po
    echo -n "-- $lang.po -- "
    svn cat $KDESVNROOT/trunk/l10n-kde4/$lang/messages/$MODULE/$APP.po > po/$lang.po 2> /dev/null
    # remove the failed
    if [ "$?" != "0" ]; then
        echo "not found"; rm po/$lang.po; continue
    fi
    echo "ok"
done
