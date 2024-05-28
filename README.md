## Overview

This project involves deploying a MySQL database and an API service on a Kubernetes cluster. The MySQL database is
deployed using a StatefulSet, and the API service is deployed with a ReplicaSet to ensure high availability. The API
service interacts with the MySQL database to retrieve customer information.

## Prerequisites

1. Kubernetes cluster set up and running.
2. kubectl configured to interact with your Kubernetes cluster.

## Instructions

### Step 1: Deploy the MySQL Pod

To deploy the MySQL database, run the following command from your terminal:

```bash
./init-MYSQL.sh
```

This script will create a MySQL pod using a StatefulSet. The MySQL database will be persistent, ensuring data is not
lost if the pod goes down.

### Step 2: Deploy the API Service

To deploy the API service, run the following command from your terminal:

```bash
./init-API-service.sh
```

This script will create the API service with a ReplicaSet, ensuring there are always three instances of the API service
running for high availability.

### Accessing the API

To access the API, use the following endpoint:

```bash
http://{LoadBalancerID}/v1/customers
```

This endpoint will return a list of all customers from the MySQL database.

## Summary

1. Run ./init-MYSQL.sh to deploy the MySQL pod with StatefulSet.
2. Run ./init-API-service.sh to deploy the API service with a ReplicaSet count of 3.
3. Access the API endpoint at http://{LoadBalancerID}/v1/customers to retrieve customer data from the database.

## Additional Information

1. Ensure your Kubernetes cluster has sufficient resources to run the pods.
2. Check the status of the pods and services using kubectl get pods and kubectl get services.
3. For any issues, refer to the logs using kubectl logs <pod-name>.

Thank you for using this project! If you have any questions or run into issues, feel free to reach out.
