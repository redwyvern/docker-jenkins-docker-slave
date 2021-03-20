FROM ubuntu:xenial

############################### DO NOT DERIVE FROM BASE IMAGES ###############################
# Keep this image simple so that it can still be built if the whole infrastructure goes down #
##############################################################################################

# Pre-install some utilities needed to install the rest of the software
RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends \
    locales \
    tzdata \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    git && \
    apt-get -q autoremove && \
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# Add locales after locale-gen as needed
# Upgrade packages on image
# Preparations for sshd
RUN locale-gen en_US.UTF-8 &&\
    apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q upgrade -y -o Dpkg::Options::="--force-confnew" --no-install-recommends &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew"  --no-install-recommends openssh-server &&\
    apt-get -q autoremove &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin &&\
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd &&\
    mkdir -p /var/run/sshd

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set the timezone
# Normally this would be done via: echo ${IMAGE_TZ} >/etc/timezone && dpkg-reconfigure -f noninteractive tzdata 
# A bug in the current version of Ubuntu prevents this from working: https://bugs.launchpad.net/ubuntu/+source/tzdata/+bug/1554806
# Change this to the normal method once this is fixed.
RUN ln -fs /usr/share/zoneinfo/${IMAGE_TZ} /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"

RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends \
    docker-ce-cli && \
    apt-get -q autoremove && \
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

ARG GIT_USER=Jenkins
ARG GIT_EMAIL=jenkins@weedon.org.au

# Set user jenkins to the image
RUN useradd -m -d /home/jenkins -s /bin/bash jenkins

COPY authorized_keys /home/jenkins/.ssh/authorized_keys
RUN chown -R jenkins.jenkins /home/jenkins/.ssh

USER jenkins

RUN git config --global user.name "${GIT_USER}" && \
    git config --global user.email "${GIT_EMAIL}"

USER root

# Install OpenJDK 11 (Java is required for Jenkins slave)
RUN \
    add-apt-repository ppa:openjdk-r/ppa -y && \
    apt-get clean && apt-get update && apt-get install -y --no-install-recommends openjdk-11-jdk && \
    apt-get -q autoremove && \
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

ENV DOCKER_HOST tcp://dind

# Standard SSH port
EXPOSE 22

COPY init.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/init.sh

# Default command
CMD init.sh && exec /usr/sbin/sshd -D
