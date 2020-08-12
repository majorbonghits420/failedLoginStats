#! /bin/python3

import argparse
import geoip2.database
import maxminddb
import socket
import sys

# create our parser, add options for getting the list of IPs and the DB file location
argParser = argparse.ArgumentParser()
argParser.add_argument('-f', '--ipList', required=True, help="The file with the list of IPs", type=str)
argParser.add_argument('-d', '--database', required=True, help="GeoLite2-City Database file", type=str)
argParser.add_argument('-p', '--percentage', required=False, help="Print country percentage of false logins", action="store_true")
argParser.add_argument('-n', '--lines', required=False, help="Print first NUM lines of output", type=int)
argParser.add_argument('-t', '--total', required=False, help="Prints total percentage printed entries account for", action="store_true")
args = argParser.parse_args()

# create reader object for the database
try:
    dbReader = geoip2.database.Reader(args.database)
except maxminddb.errors.InvalidDatabaseError:
    print("{} is not a valid database file".format(args.database))
    sys.exit(1)
# Create our dictionary to keep track of how many times each country attempted to login
cunts = {} # named for people who try to get in
# Lets process the file
invalidIPs = 0
totalAttempts = 0
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
            totalAttempts += 1
        except OSError:
            invalidIPs += 1

# Sort the dictionary based on value, descending order
sortedCunts = {k : v for k, v in sorted(cunts.items(), key = lambda item: item[1], reverse=True)}
linesToPrint=len(sortedCunts)
if args.lines is not None:
    if args.lines < 0:
        print("Lines to print cannot be less than zero")
        sys.exit(1)
    linesToPrint=min(args.lines, linesToPrint)
printedAttempts=0
printedLines = linesToPrint # save for displaying later
print("Country Attempts Percentage")
for key, value in sortedCunts.items():
    if args.percentage:
        print("{:<4} : {:>5} ({:>.2f}%) ".format(key, value, value / totalAttempts * 100))
    else:
        print("{:<4} : {:>5}".format(key, value, value / totalAttempts * 100))
    printedAttempts += value
    linesToPrint -= 1
    if linesToPrint <= 0:
        break;

if args.total:
    print("The top {} countries produced {:.2f}% of all failed attempts".format(printedLines, printedAttempts / totalAttempts * 100))
print("There were {} invalid IPs in the file".format(invalidIPs))
