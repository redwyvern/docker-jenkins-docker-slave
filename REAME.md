Jenkins Docker Slave
--------------------
This image is a simple Jenkins slave that has only Docker installed.

This image assumes that a DIND (using the official docker:dind image) container is running in the same network.

The hostname of the DIND host should be 'dind'. 
