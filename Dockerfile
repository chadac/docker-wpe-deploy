FROM debian:jessie

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

## http://stackoverflow.com/a/18138352
RUN echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config &&\
    echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config

COPY run-deploy /usr/local/bin/run-deploy
COPY setup-ssh /usr/local/bin/setup-ssh

RUN chmod 111 /usr/local/bin/run-deploy &&\
    chmod 111 /usr/local/bin/setup-ssh
