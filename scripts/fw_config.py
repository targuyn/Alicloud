import requests
import xml.etree.ElementTree as ET
import urllib3
from python_terraform import Terraform
import time
import paramiko
from contextlib import closing
import multiprocessing
import os


def wait_until_channel_endswith(channel, endswith, wait_in_seconds=15):
    timeout = time.time() + wait_in_seconds
    read_buffer = b''
    while not read_buffer.endswith(endswith):
        if channel.recv_ready():
           read_buffer += channel.recv(4096)
        elif time.time() > timeout:
            raise TimeoutError(f"Timeout while waiting for '{endswith}' on the channel")
        else:
            time.sleep(1)

def fw_init(host, username, ssh_key, new_password):
    with closing(paramiko.SSHClient()) as ssh_connection:
        ssh_connection.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_connection.load_system_host_keys()
        k = paramiko.RSAKey.from_private_key_file(ssh_key)
        timeout = int(600)
        timeout_start = time.time()
        while time.time() < timeout_start + timeout:
            time.sleep(1)
            try:
                ssh_connection.connect(hostname=host, username=username, pkey=k)
                break
            except Exception as e:
                print(e)
                print("Waiting for vm-series to be available ...")

        time.sleep(120)
        ssh_channel = ssh_connection.invoke_shell()

        wait_until_channel_endswith(ssh_channel, b'> ')
        ssh_channel.send(f'configure\n')
        print("sent configure")

        wait_until_channel_endswith(ssh_channel, b'# ')
        ssh_channel.send(f'set mgt-config users admin password\n')
        print("sent mgt-config command")

        wait_until_channel_endswith(ssh_channel, b'Enter password   : ')
        ssh_channel.send(f'{new_password}\n')
        print("entered password")

        wait_until_channel_endswith(ssh_channel, b'Confirm password : ')
        ssh_channel.send(f'{new_password}\n')
        print("confirmed password")

        wait_until_channel_endswith(ssh_channel, b'# ')
        ssh_channel.send(f'commit\n')
        print("sent commit")

        # longer timeout of 60s to cater to commit time
        wait_until_channel_endswith(ssh_channel, b'# ', 120)
        print("changed admin password")

        print(f"Password for user admin configured in Firewall {host}")

def load_configs(fw_mgmt, username, new_password, fw_name):
    try:
        # Get API Key
        url = f"https://{fw_mgmt}/api/?type=keygen&user={username}&password={new_password}"
        response = requests.get(url, verify=False)
        fw_api_key = ET.XML(response.content)[0][0].text
        print(fw_api_key)
        
        # Upload base config
        url = f"https://{fw_mgmt}/api/?type=import&category=configuration&key={fw_api_key}"
        config_file = {'file': open(f'./configs/{fw_name}-cfg.xml', 'rb')}
        response = requests.post(url, files=config_file, verify=False)
        print(response.text)

        # Load the config
        url = f"https://{fw_mgmt}/api/?type=op&cmd=<load><config><from>{fw_name}-cfg.xml</from></config></load>&key={fw_api_key}"
        response = requests.get(url, verify=False)
        print(response.text)

        # Commit config
        url = f"https://{fw_mgmt}/api/?type=commit&cmd=<commit></commit>&key={fw_api_key}"
        response = requests.get(url, verify=False)
        print(response.text)

        print(f"Configuration loaded on Firewall {fw_name}")

    except Exception as e:
        print("Something went wrong", str(e))
    
if __name__ == '__main__': 
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    working_dir = "./"
    tf = Terraform(working_dir=working_dir)
    outputs = tf.output()
    fw1_mgmt = outputs['FW-1-Mgmt']['value']
    fw2_mgmt = outputs['FW-2-Mgmt']['value']
    fw3_mgmt = outputs['FW-3-Mgmt']['value']
    username = "admin"
    new_password = outputs['password_new']['value']
    ssh_key = outputs['ssh_key_path']['value']
        
    p1 = multiprocessing.Process(target=fw_init, args=(fw1_mgmt, username, ssh_key, new_password))
    p2 = multiprocessing.Process(target=fw_init, args=(fw2_mgmt, username, ssh_key, new_password))
    p3 = multiprocessing.Process(target=fw_init, args=(fw3_mgmt, username, ssh_key, new_password))
    p1.start()
    p2.start()
    p3.start()
    p1.join()
    p2.join()
    p3.join()

    load_configs(fw1_mgmt, username, new_password, "fw1")
    load_configs(fw2_mgmt, username, new_password, "fw2")
    load_configs(fw3_mgmt, username, new_password, "fw3")
    time.sleep(60)
    
    print("Done configuring VM-Series firewalls")
    