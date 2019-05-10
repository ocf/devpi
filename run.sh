#!/bin/bash
set -ex

# from https://github.com/scrapinghub/docker-devpi

export DEVPISERVER_SERVERDIR=/mnt
export DEVPI_CLIENTDIR=/tmp/devpi-client
[[ -f $DEVPISERVER_SERVERDIR/.serverversion ]] || init=yes

kill_devpi() {
    test -n "$DEVPI_PID" && kill $DEVPI_PID
}
trap kill_devpi EXIT

# For some reason, killing tail during EXIT trap function triggers an
# "uninitialized stack frame" bug in glibc, so kill tail when handling INT or
# TERM signal.
kill_tail() {
    test -n "$TAIL_PID" && kill $TAIL_PID
}
trap kill_tail INT
trap kill_tail TERM

if [[ $init = yes ]]; then
    devpi-server --init -c /devpi.conf
fi

devpi-server --host 0.0.0.0 -c /devpi.conf || \
    { [ -f "$LOG_FILE" ] && cat "$LOG_FILE"; exit 1; }
DEVPI_PID="$(cat $DEVPISERVER_SERVERDIR/.xproc/devpi-server/xprocess.PID)"

# We cannot simply execute tail, because otherwise bash won't propagate
# incoming TERM signals to tail and will hang indefinitely.  Instead, we wait
# on tail PID and then "wait" command will interrupt on TERM (or any other)
# signal and the script will proceed to kill_* functions which will gracefully
# terminate child processes.
tail -f /etc/fstab & #"$LOG_FILE" &
TAIL_PID=$!
wait $TAIL_PID
