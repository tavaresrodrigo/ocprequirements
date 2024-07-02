#!/bin/bash
#
# Author: Rodrigo Tavares
# Date: 2024-07-02
#
# Description: This script tests connectivity and DNS configuration for a given OpenShift cluster.
#
# Usage:
#   ./script.sh -clustername <clustername> -basedomain <basedomain> -api <api_ip> -ingress <ingress_ip> -ntp <ntp_ip> -dns <dns_server>
#
# Parameters:
#   -clustername: The name of the OpenShift cluster.
#   -basedomain: The base domain of the cluster.
#   -api: The IP address of the API server.
#   -ingress: The IP address of the Ingress server.
#   -ntp: The IP address of the NTP server.
#   -dns: The IP address of the DNS server.
#
# Example:
#   ./script.sh -clustername mycluster -basedomain example.com -api 192.168.1.1 -ingress 192.168.1.2 -ntp 192.168.1.3 -dns 8.8.8.8
#
# Notes:
# - Ensure that 'nc' (netcat) and 'dig' are installed on your system.
# - This script does not stop on failure but provides a summary report of all tests.

# Function to print usage
function print_usage() {
    echo "Usage: $0 -clustername <clustername> -basedomain <basedomain> -api <api_ip> -ingress <ingress_ip> -ntp <ntp_ip> -dns <dns_server>"
    exit 1
}

# Function to test connectivity using nc
function test_connectivity() {
    local server=$1
    local port=$2
    local type=$3

    echo "Testing connectivity to $type server: $server on port $port..."
    if ! nc -z -w 2 $server $port; then
        echo "No connectivity to $type server: $server on port $port"
        results+=("$type connectivity" "FAIL")
    else
        echo "Connectivity to $type server: $server on port $port successful."
        results+=("$type connectivity" "PASS")
    fi
}

# Function to test DNS configuration
function test_dns() {
    local query=$1
    local description=$2

    echo "Testing DNS configuration for $description: $query..."
    if ! dig +noall +answer $query > /dev/null; then
        echo "DNS query failed for $description: $query"
        results+=("$description DNS" "FAIL")
    else
        echo "DNS configuration for $description: $query successful."
        results+=("$description DNS" "PASS")
    fi
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -clustername)
        clustername="$2"
        shift
        shift
        ;;
        -basedomain)
        basedomain="$2"
        shift
        shift
        ;;
        -api)
        api_ip="$2"
        shift
        shift
        ;;
        -ingress)
        ingress_ip="$2"
        shift
        shift
        ;;
        -ntp)
        ntp_ip="$2"
        shift
        shift
        ;;
        -dns)
        dns_server="$2"
        shift
        shift
        ;;
        *)
        print_usage
        ;;
    esac
done

# Check if all parameters are provided
if [ -z "$clustername" ] || [ -z "$basedomain" ] || [ -z "$api_ip" ] || [ -z "$ingress_ip" ] || [ -z "$ntp_ip" ] || [ -z "$dns_server" ]; then
    print_usage
fi

# Initialize results array
results=()

# Test connectivity
test_connectivity $dns_server 53 "DNS"
test_connectivity $ntp_ip 123 "NTP"

# Test DNS entries
test_dns "api.$clustername.$basedomain." "API"
test_dns "api-int.$clustername.$basedomain." "API internal"
test_dns "console-openshift-console.apps.$clustername.$basedomain." "Ingress wildcard"
test_dns "$(dig -x $ingress_ip +short)" "Ingress PTR"
test_dns "$(dig -x $api_ip +short)" "API PTR"

# Print summary report in table format
echo -e "\nSummary Report:"
printf "%-30s %-10s\n" "Test Description" "Result"
printf "%-30s %-10s\n" "------------------------------" "----------"

for ((i = 0; i < ${#results[@]}; i+=2)); do
    printf "%-30s %-10s\n" "${results[i]}" "${results[i+1]}"
done

echo "All tests completed."
