NewRelic OpenWrt Plugin
=======================
Monitor your OpenWrt installation with a simple shell script

Prerequisites
-------------

  - A New Relic account. Signup for a free account at http://newrelic.com
  - A server running Memcached v1.4 or greater. Download the latest version of Memcached for free here.
  - cURL package

    To install cURL:

        ipkg update
        ipkg install curl

Running the Agent
----------------------------------

 1. Copy the newrelic.sh file to a directory of your choice
 2. At the top of the newrelic.sh script, fill in:
     - Router hostname
     - Router name*
     - Your New Relic license key
     
     *Name is the value that will be displayed in the New Relic UI.

          #!/bin/ash
          licensekey="insert your license key"
          host="insert router hostname"
          name="insert router name"

3. Make the file executable: `chmod +x ./newrelic.sh`
4. Create a cron job that executes the script every minute: `*/1 * * * * /<directory>/newrelic.sh`

After a few minutes, you should see a new menu called OpenWrt in your NewRelic web-console

## Source

The project's source code is hosted at:

https://github.com/zyclonite/newrelic-openwrt-plugin
