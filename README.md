Clone using `$git clone --recursive git@github.com:SmartAQnet/frost-bridge.git` (you need to setup ssh key at github)

## Prerequisites
* docker-compose
* ssh keys on DOCKER_HOST and inside ssh-agent or predeployed TLS Keys

## Setup

1. cd into the conf/{HOST} directory to select host: `$cd conf/smartaqnet-dev` (edit .env to use your own DOCKER_HOST or comment out if set in your shell environment Note: currently the ssh: protocol is selected however the docker-compose implementation is a bit shaky so you might want to use plain TLS)

3. on first setup call `$docker -f ../docker-compose-init.yml up` to initialize the certificates

4. call `$ docker-compose up -d` 

5. call `$ docker-compose ps`  to confirm everything is up and running

## Cleanup 

1. `$ docker-compose down`
2. `$ docker-compose up -d`

## Full Cleanup loosing all data!!!!

1. `$ docker-compose down -v`
