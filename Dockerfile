FROM debian:jessie

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

## http://stackoverflow.com/a/18138352
RUN echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config &&\
    echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config

COPY deploy.sh /usr/local/bin/run-deploy

RUN chmod 111 /usr/local/bin/run-deploy
