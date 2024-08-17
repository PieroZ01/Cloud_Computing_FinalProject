import os
import random
from locust import HttpUser, task, between
from requests.auth import HTTPBasicAuth

URL = "localhost:8080"

class NextcloudUser(HttpUser):
    auth = None
    user_name = None
    wait_time = between(2, 5) # wait time between tasks
    
    # Login and authentication task
    def on_start(self):
        user_idx = random.randrange(1, 51) # IMPORTANT: change the range to the number of users you want to simulate with
        self.user_name = f"test_User_{user_idx}"
        self.auth = HTTPBasicAuth(self.user_name, f"test_Password_{user_idx}")
    
    # Task to list files in the root directory of the user   
    @task(5) # (5 is the weight of the task)
    def propfind(self):
        self.client.request("PROPFIND", f"/remote.php/dav/files/{self.user_name}/", auth=self.auth)
    
    # Task to read the content of the Readme.md file in the root directory of the user
    @task(5)
    def read_file(self):
        self.client.get(f"/remote.php/dav/files/{self.user_name}/Readme.md", auth=self.auth)
        
    # Task to upload a 5KB file to the root directory of the user
    @task(10)
    def upload_file_5KB(self):
        remote_path = f"/remote.php/dav/files/{self.user_name}/5KB_file_{random.randrange(0, 10)}"
        with open("/test_data/small_file_5KB", "rb") as file:
            self.client.put(remote_path, data=file, auth=self.auth)
        self.client.delete(remote_path, auth=self.auth) # delete the file after uploading it to keep the storage clean
    
    # Task to upload a 5MB file to the root directory of the user
    @task(5)
    def upload_file_5MB(self):
        remote_path = f"/remote.php/dav/files/{self.user_name}/5MB_file_{random.randrange(0, 10)}"
        with open("/test_data/average_file_5MB", "rb") as file:
            self.client.put(remote_path, data=file, auth=self.auth)
        self.client.delete(remote_path, auth=self.auth) # delete the file after uploading it to keep the storage clean
            
    # Task to upload a 1GB file to the root directory of the user
    @task(1)
    def upload_file_1GB(self):
        remote_path = f"/remote.php/dav/files/{self.user_name}/1GB_file_{random.randrange(0, 10)}"
        with open("/test_data/large_file_1GB", "rb") as file:
            self.client.put(remote_path, data=file, auth=self.auth)
        self.client.delete(remote_path, auth=self.auth) # delete the file after uploading it to keep the storage clean
        
    # Task to download a 5MB file from the root directory of the user
    @task(5)
    def download_file_5MB(self):
        self.client.get(f"{URL}/remote.php/dav/files/{self.user_name}/test_file_5MB", auth=self.auth)
