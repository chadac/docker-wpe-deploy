FROM debian:jessie

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

COPY deploy-to-wpengine /usr/local/bin/
