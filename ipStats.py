#! /bin/python3

# Assumes it takes in a file argument which has one IP per line
# I made mine with lastb -f <file> -a | head -n -2 | awk '{print $3}' > <newFile>

import argparse
import geoip2.database
import socket

# create our parser, add options for getting the list of IPs and the DB file location
argParser = argparse.ArgumentParser()
argParser.add_argument('-f', '--ipList', required=True, help="The file with the list of IPs")
argParser.add_argument('-d', '--database', required=True, help="GeoLite2-City Database file")
args = argParser.parse_args()

# create reader object for the database
dbReader = geoip2.database.Reader(args.database)

# Create our dictionary to keep track of how many times each country attempted to login
cunts = {} # named for people who try to get in
# Lets process the file
invalidIPs = 0
with open(args.ipList, 'r') as ipFile:
    for ip in ipFile:
        try:
            # In case we have extra whitespace or anything in our string this should strip it out
            ip = socket.inet_ntoa(socket.inet_aton(ip))
            response = dbReader.city(ip)
            country = response.country.iso_code
            if country == None:
                country = "None"
            cunts[country] = cunts.get(country, 0) + 1
        except OSError:
            invalidIPs += 1
print("Country\tAttempts")
# Sort the dictionary based on value, descending order
sortedCunts = {k : v for k, v in sorted(cunts.items(), key = lambda item: item[1], reverse=True)}
for key, value in sortedCunts.items():
    print(key, ": ", value)
print("There were {} invalid IPs in the file".format(invalidIPs))
