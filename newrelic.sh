#!/bin/ash
licensekey="insert your license key"
host="insert your hostname"
version="1.0.1"

SendMetrics () {
  curl -sk -o /dev/null https://platform-api.newrelic.com/platform/v1/metrics \
    -H "X-License-Key: $licensekey" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -X POST -d '{
      "agent": {
        "host" : "'$host'",
        "version" : "'$version'"
      },
      "components": [
        {
          "name": "'$host'",
          "guid": "net.zyclonite.newrelic.openwrt",
          "duration" : 60,
          "metrics" : {
            "Component/System/Load[load]": '$1',
            "Component/Cpu/User[percent]": '$2',
            "Component/Cpu/System[percent]": '$3',
            "Component/Cpu/IOWait[percent]": '$4',
            "Component/Memory/Used[bytes]": '$5',
            "Component/Memory/Swap[bytes]": '$6',
            "Component/Memory/Free[percent]": '$7'
          }
        }
      ]
    }'
}

GetCpuStats () {
    for c in 1 2 3
    do
      read -r CPU </proc/stat
      CPU=$( echo $CPU | cut -d " " -f2- )
      TOTAL=0
      for t in $CPU
      do
        TOTAL=$(($TOTAL+$t))
      done
      DIFF_TOTAL=$(($TOTAL-${PREV_TOTAL:-0}))
      i=0
      for number in $CPU
      do
		PREV=$( echo $PREV_STAT | cut -d " " -f$(($i+1)) )
        OUT_INT=$((1000*($number-${PREV:-0})/$DIFF_TOTAL))
        eval OUT$(($i*2))="'$(($OUT_INT/10))'"
        eval OUT$(($i*2+1))="'$(($OUT_INT%10))'"
        i=$(($i+1))
      done
      PREV_STAT="$CPU"
      PREV_TOTAL="$TOTAL"
      if [ $c -lt 3 ]
      then
        sleep 1
      fi
    done

    user=$(printf '%3d.%1d ' "$OUT0" "$OUT1")
    system=$(printf '%3d.%1d ' "$OUT4" "$OUT5")
    iowait=$(printf '%3d.%1d ' "$OUT8" "$OUT9")
}

GetMemoryStats () {
    free=0
    total=0
    buffer=0
    cached=0
    swapfree=0
    swaptotal=0

    while IFS=":" read -r a b
    do
      case "$a" in
       MemTotal*) total=$( echo $b | cut -d " " -f1 )
         ;;
       MemFree*) free=$( echo $b | cut -d " " -f1 )
         ;;
       Buffers*) buffers=$( echo $b | cut -d " " -f1 )
         ;;
       SwapTotal*) swaptotal=$( echo $b | cut -d " " -f1 )
         ;;
       SwapFree*) swapfree=$( echo $b | cut -d " " -f1 )
         ;;
       Cached*) cached=$( echo $b | cut -d " " -f1 )
      esac
    done <"/proc/meminfo"

    realfree=$(($free+$buffers+$cached))
    realused=$(($total-$realfree))
    swapused=$(($swaptotal-$swapfree))
    FREE_INT=$((1000*$realfree/$total))
    FREE0=$(($FREE_INT/10))
    FREE1=$(($FREE_INT%10))
    freepercent=$(printf '%3d.%1d ' "$FREE0" "$FREE1")
}

GetLoadStats () {
    load=$( cat /proc/loadavg | cut -d " " -f1 )
}

GetLoadStats
GetCpuStats
GetMemoryStats

SendMetrics $load $user $system $iowait $(($realused*1024)) $(($swapused*1024)) $freepercent
