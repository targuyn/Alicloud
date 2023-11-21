import json
import os
import time
import json
import requests
from aliyunsdkcore.client import AcsClient
from aliyunsdkecs.request.v20140526.DescribeEipAddressesRequest import DescribeEipAddressesRequest
from aliyunsdkecs.request.v20140526.UnassociateEipAddressRequest import UnassociateEipAddressRequest
from aliyunsdkecs.request.v20140526.DeleteRouteEntryRequest import DeleteRouteEntryRequest
from aliyunsdkvpc.request.v20160428.AssociateEipAddressRequest import AssociateEipAddressRequest
from aliyunsdkecs.request.v20140526.CreateRouteEntryRequest import CreateRouteEntryRequest


def create_client(access_key, access_secret, region_id):
    # Create an Alibaba Cloud ECS client
    client = AcsClient(access_key, access_secret, region_id)
    return client

def describe_eip_address(client, eip_address):
    # Create a request to describe the EIP addresses
    request = DescribeEipAddressesRequest()
    request.set_EipAddress(eip_address)
    # Send the request and retrieve the response
    response = client.do_action_with_exception(request)
    # Parse the JSON response
    response_json = json.loads(response)
    return response_json

# Create a request to unbind the EIP
def unassociate_eip_address(eip_id, instance_id):
    request = UnassociateEipAddressRequest()
    request.set_AllocationId(eip_id)
    request.set_InstanceId(instance_id)
    return request

# Create a request to Delete route
def delete_route_entry(route_table_id, destination_cidr_block, next_hop_id):
    request = DeleteRouteEntryRequest()
    request.set_RouteTableId(route_table_id)
    request.set_DestinationCidrBlock(destination_cidr_block)
    request.set_NextHopId(next_hop_id)
    return request

# Create a request to assign the EIP
def associate_eip_address(eip_id, In_type, instance_id):
    request = AssociateEipAddressRequest()
    request.set_AllocationId(eip_id)
    request.set_InstanceType(In_type)
    request.set_InstanceId(instance_id)
    return request

# Create a request to create route to ENI
def create_route_entry(route_table_id, destination_cidr_block, next_hop_type, next_hop_id):
    request = CreateRouteEntryRequest()
    request.set_RouteTableId(route_table_id)
    request.set_DestinationCidrBlock(destination_cidr_block)
    request.set_NextHopType(next_hop_type)
    request.set_NextHopId(next_hop_id)
    return request


def move_eip(client, eip_id, instance_id, route_table_id, destination_cidr_block, in_type, next_hop_type, next_hop_delete, next_hop_add):
    # Send the unbind EIP request and handle the response
    try:
        request = unassociate_eip_address(eip_id, instance_id)
        response = client.do_action_with_exception(request)
        print("EIP unbound successfully.")
        time.sleep(10)
    except Exception as e:
        return print("Failed to unbind EIP:", str(e)) 

    # Send the Delete route request and handle the response
    try:
        request = delete_route_entry(route_table_id, destination_cidr_block, next_hop_delete)
        response = client.do_action_with_exception(request)
        print("Route entry deleted successfully.")
        time.sleep(10)
    except Exception as e:
        return print("Failed to delete Route entry:", str(e))
    
    # Send the assign the EIP request and handle the response
    try:
        request = associate_eip_address(eip_id, in_type, instance_id)
        response = client.do_action_with_exception(request)
        print(f"EIP assigned to {in_type} successfully.")
    except Exception as e:
        return print(f"Failed to assign EIP to {in_type}:", str(e))

    # Send the create route request and handle the response
    try:
        request = create_route_entry(route_table_id, destination_cidr_block, next_hop_type, next_hop_add)
        response = client.do_action_with_exception(request)
        print(f"Route to {in_type} created successfully.")
        return
    except Exception as e:
        return print(f"Failed to acreate route to {in_type}:", str(e))

def main_logic(response_json, url):
    # Check if the response contains the requested EIP address
    if "EipAddresses" in response_json:
        eip_assignments = response_json["EipAddresses"]["EipAddress"]
        if isinstance(eip_assignments, list) and len(eip_assignments) > 0:
            # Print the information for the requested EIP address
            eip = eip_assignments[0]
            print("EIP Address: ", eip["IpAddress"])
            print("Allocation ID: ", eip["AllocationId"])
            print("Instance ID: ", eip["InstanceId"])

            # Check the instance ID and print HAVIP or ENI accordingly
            instance_id = eip["InstanceId"]
            if instance_id.startswith("havip-"):
                print("Resource Type: HAVIP")
                try:
                    response = requests.get(url, timeout=5)
                    if response.status_code == 200:
                        return "ALL GOOD"
                    else:
                        print("MOVE TO VM3")
                        return "VM3"
                except requests.exceptions.Timeout:
                    print("Connection to the HAVIP timed out -> MOVE TO VM3")
                    return "VM3"
                except requests.exceptions.RequestException as e:
                    return print(f"An error occurred: {e}")
            elif instance_id.startswith("eni-"):
                print("Resource Type: ENI")
                try:
                    response = requests.get(url, timeout=5)
                    if response and response.status_code != 200:
                        print("WAIT FOR HAVIP")
                    elif response and response.status_code == 200:
                        print("MOVE TO HAVIP")
                        return "HAVIP"
                except requests.exceptions.Timeout:
                    print("Connection to the URL timed out -> WAIT FOR HAVIP")
                    return "WAIT"
                except requests.exceptions.RequestException as e:
                    return print(f"An error occurred: {e}")
            else:
                print("Resource Type: Unknown")
        else:
            print("No information found for the requested EIP address.")
    else:
        print("No information found for the requested EIP address.")

 

def handler(event, context):
    region_id = os.environ.get("REGION_ID")
    access_key = os.environ.get("ACCESS_KEY")
    access_secret = os.environ.get("ACCESS_SECRET")
    eip_address = os.environ.get("EIP_ADDRESS")
    url = os.environ.get("URL")
    eip_id = os.environ.get("EIP_ID")
    instance_id_havip = os.environ.get("INSTANCE_ID_HAVIP")
    instance_id_eni = os.environ.get("INSTANCE_ID_ENI")
    route_table_id = os.environ.get("ROUTE_TABLE_ID")
    next_hop_id_eni = os.environ.get("NEXT_HOP_ID_ENI")
    next_hop_id_havip = os.environ.get("NEXT_HOP_ID_HAVIP")
    destination_cidr_block = "0.0.0.0/0"
    
    client = create_client(access_key, access_secret, region_id)
    check_eip = main_logic(describe_eip_address(client, eip_address), url)

    try:
        if check_eip is not None:
            if "VM3" in check_eip:
                move_eip(client, eip_id, instance_id_eni, route_table_id, destination_cidr_block, "NetworkInterface", "NetworkInterface", next_hop_id_havip, next_hop_id_eni)
            elif "HAVIP" in check_eip:
                move_eip(client, eip_id, instance_id_havip, route_table_id, destination_cidr_block, "HaVip", "HaVip", next_hop_id_eni, next_hop_id_havip)
            else:
                print(check_eip)
            return "success"
    except Exception as e:
        print("Something went wrong", str(e))
    