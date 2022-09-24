#!/system/bin/sh
echo "[auto-naco] start"

STORE="/data/auto_naco_original"

isGlass() {
    ## if this returns 0, then we are running on glass 
    dji_mb_ctrl -g 28 -t 1 -s 0 -c FF -o 10 &> /dev/null
    return $?
}

prerm() {
    echo "[auto-naco] prerm";
    if isGlass;  # if equal to 0, then we are running on glass
        then 
            ## We're on glass
            setprop persist.dji.sdr.power_level $(cat $STORE) &> /dev/null;
            rm $STORE;
        else
            ## We're on Air
            dji_mb_ctrl -g 1 -t 1 -s 0 -c 63 $(cat $STORE | hexdump -v -e '/1 "%02x"') &> /dev/null;
            rm $STORE;
    fi
}

postinst() {
    echo "[auto-naco] postinst";
    if isGlass;
        then 
            getprop persist.dji.sdr.power_level > $STORE;
        else
            cat /data/dji/wireless_country_code > $STORE;
    fi
}

boot() {
    echo "[auto-naco] boot";
    if isGlass;
        then 
            setprop persist.dji.sdr.power_level 6 &> /dev/null;
        else
            dji_mb_ctrl -g 1 -t 1 -s 0 -c 63 5553 &> /dev/null;
    fi
}

case $1 in
    prerm) prerm;;
    postinst) postinst;;
    boot) boot;;
esac

echo "[auto-naco] complete";