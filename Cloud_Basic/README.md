# Cloud-Based File Storage System

This folder contains the solution for the **Cloud Basic** assignment.

## Folder Structure

This folder is organized with the following structure:

```bash
.
├── README.md # This file
├── add_users.sh # Script to add users to the system
├── create_files.sh # Script to create test data files
├── delete_users.sh # Script to remove users from the system
├── docker-compose.yaml # Docker compose file
├── locust-tasks # Locust tasks folder
│   └── locustfile.py
├── system_setup.sh # Script to setup the system
├── test_data # Folder to store test data files
└── upload_file.sh # Script to upload files to the system

```

## Deployment and usage instructions

### Prerequisites

To deploy and run the system, you need to have the following tools installed on your machine:
- `docker`
- `docker-compose`

### Deployment

The deployment of the system is done using `docker-compose`. To install the system and therefore run the docker containers, you need to run the following commands:

```bash

docker network create nextcloud_network
docker-compose up -d

```

These commands will create a new network called `nextcloud_network`, download the necessary images and start the containers.

More details about the `docker` images used in this system can be found in the report `pdf` file.

To stop the system, you can run the following command:

```bash

docker-compose down

```

### Usage

After the system is deployed, you can access the **Nextcloud** service by opening the following URL in your browser: `http://localhost:8080`.

The default credentials are:
- **Username**: `admin`
- **Password**: `password`

To set up the environment, you need to run the `system_setup.sh` script:

```bash

sh system_setup.sh

```

This script will set the private storage space per user to 5GB, enable the encryption to improve the security of the system, encrypt all the files already uploaded to the system and finally add `locust` to the trusted domains. This last step is necessary to later perform the load tests.

### Load tests

It's possible to perform load tests on the deployed system using `locust`. Before running the tests, it's necessary to setup the environment following the instructions below:

1. Add some users to the system by running the `add_users.sh` script:

```bash

sh add_users.sh <N>

```

Where `<N>` is the number of users you want to add to the system.

2. Create the test data files by running the `create_files.sh` script:

```bash

sh create_files.sh

```

This script will create files of different sizes in the `test_data` folder; specifically, it will generate three files: a small file (5KB), a medium file (5MB) and a large file (1GB).

3. Upload to the system a medium size file (5MB) for each user by running the `upload_file.sh` script:

```bash

sh upload_file.sh <N>

```

>Note: The number of users `<N>` should be the same as the number of users added in the first step. Remember also to update the number of users in the `locust-tasks/locustfile.py` file (line 15) with the same desired number of users to perform the load tests correctly.

4. Run the `locust` load tests; to do so, access the `locust` interface by opening the following URL in your browser: `http://localhost:8089`.

The tasks to be performed by the users are defined in the `locust-tasks/locustfile.py` file. Specifically, the users will perform the following tasks, each with a specific weight:
- Login and authenticate in the system
- List the files in the user's private storage space
- Read the content of a file contained in the user's private storage space
- Upload a 5KB file to the user's private storage space
- Upload a 5MB file to the user's private storage space
- Upload a 1GB file to the user's private storage space
- Download a 5MB file from the user's private storage space


After the tests are finished, you can remove the users from the system by running the `delete_users.sh` script to clean up the environment:

```bash

sh delete_users.sh <N>

```