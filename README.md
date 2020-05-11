# Failed Login Statistics

This repo is for performing some interesting statistics on the information found in the typical /var/log/btmp file containing failed login attempts.
The plan is to have a series of python/bash scripts that take in some data from the contents, and present this data either in text output, or maybe a graphical image.

Current scripts:

- usernameStats.sh

## Requirements

- Bash
- head
- awk
- sort
- uniq
- getopts

# Scripts

## usernameStats.sh

Lets you know how many times a username failed a login.
Prints the number of failed logins per user in reverse order.
