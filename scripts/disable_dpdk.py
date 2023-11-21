import requests
import urllib3
from python_terraform import Terraform
import time
import paramiko
from contextlib import closing
import multiprocessing


def wait_until_channel_endswith(channel, endswith, wait_in_seconds=15):
    timeout = time.time() + wait_in_seconds
    read_buffer = ""
    while not read_buffer.endswith(endswith):
        if channel.recv_ready():
           read_buffer += channel.recv(4096).decode('ascii')
        elif time.time() > timeout:
            raise TimeoutError(f"Timeout while waiting for '{endswith}' on the channel")
        else:
            time.sleep(1)

def disable_dpdk(host, username, new_password):
    with closing(paramiko.SSHClient()) as ssh_connection:
        ssh_connection.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_connection.load_system_host_keys()
        timeout = int(600)
        timeout_start = time.time()
        while time.time() < timeout_start + timeout:
            time.sleep(1)
            try:
                ssh_connection.connect(hostname=host, username=username, password=new_password, look_for_keys=False, allow_agent=False)
                break
            except Exception as e:
                print(e)
                print("Waiting for vm-series to be available ...")
        
        ssh_channel = ssh_connection.invoke_shell()
        wait_until_channel_endswith(ssh_channel, '> ')
        ssh_channel.send(f'set system setting dpdk-pkt-io off\n')
        print("Sent disable DPDK")

        wait_until_channel_endswith(ssh_channel, ') ')
        ssh_channel.send(f'y\r')
        time.sleep(3)

        print("Sent yes, firewall restarting")

    
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
    
    p1 = multiprocessing.Process(target=disable_dpdk, args=(fw1_mgmt, username, new_password))
    p2 = multiprocessing.Process(target=disable_dpdk, args=(fw2_mgmt, username, new_password))
    p3 = multiprocessing.Process(target=disable_dpdk, args=(fw3_mgmt, username, new_password))
    p1.start()
    p2.start()
    p3.start()
    p1.join()
    p2.join()
    p3.join()

    # disable_dpdk(fw1_mgmt, username, new_password)
    # disable_dpdk(fw2_mgmt, username, new_password)
    # disable_dpdk(fw3_mgmt, username, new_password)
    
    print("DPDK disabled on VM-Series firewalls")
    