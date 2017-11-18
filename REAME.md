Jenkins Docker Slave
--------------------
This image is a simple Jenkins slave that has only Docker installed.

This image assumes that a DIND (using the official docker:dind image) container is running in the same network.

The hostname of the DIND host should be 'dind'.

Example YAML file:
```
version: '3'

services:
  docker-slave:
    image:  docker.artifactory.weedon.org.au/redwyvern/jenkins-docker-slave
    container_name: docker-slave
    hostname: docker-slave
    privileged: true
    restart: always
    dns: 192.168.1.50
    networks:
      - dev_nw

networks:
  dev_nw:
```
