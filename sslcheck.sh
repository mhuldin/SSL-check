#!/bin/bash/
THRESHOLD_IN_DAYS="30"

url="google.se:443"

for i in $url
do
CURRENT=`date +%s`
        THRESHOLD=$(($CURRENT + ($THRESHOLD_IN_DAYS*24*60*60)))
        if [ $THRESHOLD -le $CURRENT ]; then
                echo "[ERROR] Invalid date."
                exit 1
        fi
        echo "Looking for certificates inside the keystore $i expiring in $THRESHOLD_IN_DAYS day(s)..."


        openssl s_client -connect $i 2>/dev/null|openssl x509 -noout -text | grep "Subject: CN=" | awk '{print $2}' |  while read NAME
        do
                #Iterate through all the certificate alias
                EXPIRACY=`openssl s_client -connect "$i" 2>/dev/null|openssl x509 -noout -dates | grep notAfter`
                UNTIL=`openssl s_client -connect "$i" 2>/dev/null|openssl x509 -noout -dates | grep notAfter| perl -ne 'if(/notAfter=(.*?)\n/) { print "$1\n"; }'`
                UNTIL_SECONDS=`date -d "$UNTIL" +%s`
                REMAINING_DAYS=$(( ($UNTIL_SECONDS -  $(date +%s)) / 60 / 60 / 24 ))
                if [ $THRESHOLD -le $UNTIL_SECONDS ]; then
                        echo "[OK]      Certificate $NAME expires in '$UNTIL' ($REMAINING_DAYS day(s) remaining)."
                else
                        echo "[WARNING] Certificate $NAME expires in '$UNTIL' ($REMAINING_DAYS day(s) remaining)."
                        RET=1
                fi

        done
        done
exit
