# Failed Login Statistics

This repo is for performing some interesting statistics on the information found in the typical /var/log/btmp file containing failed login attempts.
The plan is to have a series of python/bash scripts that take in some data from the contents, and present this data either in text output, or maybe a graphical image.

Current scripts:

- usernameStats.sh
- ipStats.py

## Requirements

- Bash
- head
- awk
- sort
- uniq
- getopts
- paste
- bc
- lastb
- wc
- printf
- Python 3.6+ (3.6 features are in use)
- GeoLite2-City database
- geoip2 python module

# Scripts

## usernameStats.sh

Lets you know how many times a username failed a login.
Prints the number of failed logins per user in reverse order.

## ipStats.py

Some stats based on the IPs of failed login attempts.
Prints the country code and number of attempted logins in reverse order.

## genIpList.sh

Creates a list of IPs based on the supplied btmp style file.
