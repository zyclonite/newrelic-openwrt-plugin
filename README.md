NewRelic OpenWrt Plugin
=======================
monitor your openwrt installtion with a simple shell script


## Installation

requirements: curl package

    ipkg update
    ipkg install curl

copy the newrelic.sh file to a directory of your choice
fill in your hostname and license key at the top of the newrelic.sh script

    #!/bin/ash
    licensekey="insert your license key"
    host="insert your hostname"

make the file executable

    $ chmod +x ./newrelic.sh

create a cron job that executes the script every minute

    */1 * * * * /<directory>/newrelic.sh

after some minutes you should see a new menu called OpenWrt in your NewRelic web-console

## Source

The project's source code is hosted at:

https://github.com/zyclonite/newrelic-openwrt-plugin
