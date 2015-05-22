#!/bin/sh
set -e

# This script generates the required configs for dynamicEndpoints.py
# Designed to be called from Upstart and systemd configs, but can be run alone

if [ "$(id -u)" != "0" ]; then
    echo "This script needs to be run as root."
    exit 1
fi

( # start a subshell so we can avoid side effects of umask later on

if ! test -e /etc/cjdns-dynamic.conf; then
    umask 077 # to create the file with 600 permissions without races
    echo '# Example config file for dynamicEndpoints.py
# Make a section for each node, named by the cjdns public key.
# In each section, define "hostname", "port", and "password".
# You may want to define other fields for convenience (like ipv6)

# Uncomment and adapt one of the blocks below:

#[lhjs0njqtvh1z4p2922bbyp2mksmyzf5lb63kvs3ppy78y1dj130.k]
#hostname: verge.info.tm
#port: 6324
#password: ns6vn00hw0buhrtc4wbk8sv230

#[bkfy8ynwdwunt1dp1n54s700c85wtwsztf19u5f4wkxfl4lum030.k]
#hostname: hyperboria.net
#port: 1234
#password: blahblahblah
'
    echo 'WARNING: A new /etc/cjdns-dynamic.conf file has been generated.'
fi

if (! test -e /etc/cjdns-dynamic.cjdnsadmin); then
    if test -x /usr/lib/cjdns/cjdnsadminmaker.py; then
        # Make a cjdnsadmin file from the cjdroute.conf. 
        # We're not using /root/.cjdnsadmin because that would be silly.
        /usr/lib/cjdns/cjdnsadminmaker.py /etc/cjdns-dynamic.cjdnsadmin

        echo 'WARNING: Permanently opened cjdns admin port.
Credentials are stored at /etc/cjdns-dynamic.cjdnsadmin'
    else
        # Probably not running from init script.
        echo "Skipping generating cjdns admin credentials because 
/usr/lib/cjdns/cjdnsadminmaker.py was not found."
    fi
fi

) # exit subshell; umask no longer applies
