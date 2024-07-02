
# Pre-Check Script for OpenShift Installation on vSphere

## Overview

Save time during OpenShift Container Platform (OCP) installation with Installer-Provisioned Infrastructure (IPI) in vSphere by ensuring that network requirements are met before you run `openshift-install`.

The installation process can be delayed considerably if the requirements are not met beforehand. This script is designed to be run on a bastion or node within the network where the installation will take place. It verifies that all necessary network requirements are satisfied.

## Usage

### Prerequisites

Ensure that the following tools are installed on the machine where this script will be executed:
- `nc` (netcat)
- `dig`

### Running the Script

Clone this repository and navigate to the directory:

```bash
git clone https://github.com/tavaresrodrigo/ocprequirements.git
cd ocprequirements
```

Run the script with the required parameters:

```bash
./pre-check.sh -clustername <clustername> -basedomain <basedomain> -api <api_ip> -ingress <ingress_ip> -ntp <ntp_ip> -dns <dns_server>
```

Example:

```bash
./pre-check.sh -clustername mycluster -basedomain example.com -api 192.168.1.1 -ingress 192.168.1.2 -ntp 192.168.1.3 -dns 8.8.8.8
```

## Script Details

The script performs the following checks:
- **Connectivity Tests**: Verifies connectivity to the DNS and NTP servers using netcat.
- **DNS Configuration Tests**: Validates DNS entries for API, internal API, and Ingress wildcard using `dig`.

### Connectivity Tests

- DNS server on port 53
- NTP server on port 123

### DNS Configuration Tests

- API: `api.<clustername>.<basedomain>`
- API internal: `api-int.<clustername>.<basedomain>`
- Ingress wildcard: `console-openshift-console.apps.<clustername>.<basedomain>`
- PTR records for Ingress IP and API IP

## Summary Report

The script provides a summary report in a table format, indicating the results of each test:

```
Summary Report:
Test Description                Result    
------------------------------  ----------
DNS connectivity                PASS
NTP connectivity                PASS
API DNS                         PASS
API internal DNS                PASS
Ingress wildcard DNS            PASS
Ingress PTR DNS                 PASS
API PTR DNS                     PASS
```

## Contribute

Please open new issues or submit your PR if you want to contribute. 