#!/bin/bash

print_usage() {
    echo "Usage: $0 login <username>"
    exit 1
}

# Validate args
if (( $# != 2 )); then
    print_usage
fi

if [[ "$1" != "login" ]]; then
    print_usage
fi

nontri_username="$2"

# Get IPv4 & IPv6
if [ -x "$(command -v ip)" ]; then

    ipv4=$(ip -4 a | grep -o '158\.108\.[0-9]\+\.[0-9]\+' | head -n 1)
    ipv6=$(ip -6 a | grep -o '2406:3100:[0-9a-f]\+:[0-9a-f]\+::[0-9a-f]\+' | head -n 1)

elif [ -x "$(command -v ifconfig)" ]; then

    ipv4=$(ifconfig | grep -o '158\.108\.[0-9]\+\.[0-9]\+' | head -n 1)
    ipv6=$(ifconfig | grep -o '2406:3100:[0-9a-f]\+:[0-9a-f]\+::[0-9a-f]\+' | head -n 1)

else
    echo "Error: 'ip' and 'ifconfig' command not found on this machine."
    exit 1
fi

if [ -z "$ipv4" -o "$ipv4" == "\n" ]; then
    if [ -z "$ipv6" -o "$ipv6" == "\n" ]; then
        echo 'Error: Cannot find IPv4 and IPv6 of the Nontri network.'
        exit 1
    fi

    echo 'Error: Cannot find IPv4 of the Nontri network. (It should be 158.108.x.x)'
    exit 1
fi

echo
echo "IPv4 ... found! ($ipv4)"

if [ -z "$ipv6" -o "$ipv6" == "\n" ]; then
    echo "IPv6 ... not found"
else
    echo "IPv6 ... found! ($ipv6)"
fi

echo

# Password prompt
echo -n 'Enter Nontri Password: '
read -s nontri_password

echo
echo
echo '> Logging in...'

# Login request
curl -s -m 8 -X POST 'https://login1.ku.ac.th/index.jsp?action=login' \
-H 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode "username=$nontri_username" \
--data-urlencode "password=$nontri_password" \
--data-urlencode "ipv4=$ipv4" \
--data-urlencode "ipv6=$ipv6" \
--data-urlencode 'loginType=advance' \
--data-urlencode 'loginMethod=ldap'

curl_result=$?

if [ $curl_result -eq 0 ]; then
  echo '> Login requested.'
  echo '> You can check the login result by trying this command: ping google.com'
  echo
  exit 0
fi

if [ $curl_result -eq 28 ]; then
  echo '> Login failed. (Connection timed out)'
  echo
  exit 1
fi

echo '> Login failed.'
echo
exit 1
