#!/usr/bin/env python3

import requests
import json
import threading
import queue

ocp_versions_endpoint = "https://arorpversion.blob.core.windows.net/ocpversions/"
rp_version_endpoint = "https://arorpversion.blob.core.windows.net/rpversion/"

def get_ocp_versions(url=None, location=None):

    result = []

    response = requests.get(url+location)
    if not response.ok:
        return None

    versions = json.loads(response.content)
    result = [ v['version'] for v in versions ]
    return result

def get_rp_version(url=None, location=None):
    response = requests.get(url+location)
    if not response.ok:
        return None

    return response.content.decode("utf-8")

def process_location(location=None):
    return {
        "location": location,
        "ocp_versions": get_ocp_versions(ocp_versions_endpoint, location),
        "rp_version": get_rp_version(rp_version_endpoint, location)
    }

if __name__ == "__main__":

    locations = [
			"eastus2euap", "westcentralus", "australiaeast", "japaneast", "koreacentral",
			"australiasoutheast", "centralindia", "southindia", "japanwest", "eastasia",
			"centralus", "eastus", "eastus2", "northcentralus", "southcentralus",
			"westus", "westus2", "canadacentral", "canadaeast", "francecentral",
			"germanywestcentral", "northeurope", "norwayeast", "switzerlandnorth", "switzerlandwest",
			"westeurope", "brazilsouth", "brazilsoutheast", "southeastasia", "uaenorth",
			"southafricanorth", "uksouth", "ukwest",
    ]

    que = queue.Queue()
    threads = []

    for location in locations:
        thread = threading.Thread(target=lambda q, location: q.put(process_location(location)), args=(que, location,))
        thread.start()
        threads.append(thread)

    for thread in threads:
        thread.join()

    results = []
    while not que.empty():
        results.append(que.get())

    results = sorted(results, key = lambda i: i['location'])

    print(results)
