#!/bin/bash

ioex_start ()
{
    if [ -e ioex.pid ]; then
        pid=`cat ioex.pid`
        if [ -e /proc/$pid -a /proc/$pid/exe ]; then
            echo "ioeX Node already started!"
            return 1  
        fi
    fi

    if [ ! -f config.json ]; then
        config
    fi

    echo "Start ioeX Node..."
    ./ioex >/dev/null 2>&1 & echo $! > ioex.pid

    pid=`cat ioex.pid`

    if [ -e /proc/$pid -a /proc/$pid/exe ]; then
        echo "Start ioeX Node Success!"
        return 0
    fi

    return 1
}

ioex_stop ()
{
    if [ -e ioex.pid ]; then
        pid=`cat ioex.pid`
        if [ -e /proc/$pid -a /proc/$pid/exe ]; then
            echo "Stop ioeX Node"
            kill $pid
            return 0
        fi
    fi

    return 1
}

ioex_restart ()
{
    pid=`cat ioex.pid`

    echo "Stop ioeX Node..."
    kill $pid

    if [ ! -f config.json ]; then
        config
    fi

    echo "Start ioeX Node..."
    ./ioex >/dev/null 2>&1 & echo $! > ioex.pid

    pid=`cat ioex.pid`

    if [ -e /proc/$pid -a /proc/$pid/exe ]; then
        echo "Restart ioeX Node Success!"
        return 0
    fi

    return 1
}

regx_singleSignAddress='^[E]{1}[a-km-zA-HJ-NP-Z0-9]{33}'
regx_multiSignAddress='^[8]{1}[a-km-zA-HJ-NP-Z0-9]{33}'

invalid_address ()
{
    if [[ "$1" =~ $regx_singleSignAddress ]]; then
        return 0
    elif [[ "$1" =~ $regx_multiSignAddress ]]; then
        return 0
    else
        return 1
    fi
}

config ()
{
    if [ -f config.json ]; then
        cp -df config.json config.json.bak
        config_file="config.json.bak"
    elif [ -f config.json.sample ]; then
        config_file="config.json.sample"
    else
        echo "config fail!"
        return 1
    fi

    read -n 30 -p "Input your Miner name(30 characters): " miner
    read -p "input your IOEX address: " addr

    if [ $(invalid_address $addr) ]; then
        echo "Invalid Address"
        return
    fi

    cat $config_file | sed "/MinerInfo/ c\      \"MinerInfo\": \"$miner\"," | sed "/PayToAddr/ c\      \"PayToAddr\": \"$addr\"," > config.json
    echo "config successed!"

    return 0
}

help ()
{
    return 0
}

case "$1" in
    start)
        ioex_start
        ;;
    stop)
        ioex_stop
        ;;
    restart)
        ioex_restart
        ;;
    config)
        config
        ;;
    *)
        echo "help"
        ;;
esac
exit 0
