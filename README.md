# kafka-nestjs

## Overview

The project consists of simple communication using the Nestjs framework (Typescript) and Kafka, sending a message from the user to the producer via a rest api and from the producer to the consumer via Kafka.

## Steps to be executed

### docker compose

First, there is a docker file (docker-compose.yaml) to run before starting the system. It will initialize Kafka, the producer and the consumer. The following command can be run from the root of the project:

```bash
./docker/docker-compose up -d
```

### create topic

Log in to kafka-1's bash and create a topic with the following command::

```bash
kafka-topics.sh --create \
    --bootstrap-server kafka-1:9092 \
    --partitions 10 \
    --replication-factor 3 \
    --topic test \
    --config unclean.leader.election.enable=false \
    --config min.insync.replicas=2
```

### send message

To send a message to the producer, simply use the _.http_ file, located in the **./api** directory. It will help you execute commands directly to the producer:

* ./api/send-message.http
