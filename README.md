# Development Version

## :exclamation: Security Warning :exclamation:
The current development version starts a dockerized swarm as priviliged docker containers.
The docker deamon of the manager node is bound to 127.0.0.1:22375 of the HOST. TLS verification is disabled.
Access to this port is equivalent to root priviliges on the HOST machine.

## Prerequisites
- Docker
- Docker-Compose
- Free ports as specified in docker-compose.swarm.yml

## Setup
Clone this repository:

```
git clone https://github.com/SmartAQnet/smartaqnet-infrastructure.git
git checkout cluster-dev
```

Execute `docker-compose -f docker-compose.swarm.yml up` in the `/dev` folder of this repository. This will deploy a local swarm with one manager and three workers similar to the topology currently hosted at TECO. All swarm nodes include their own docker daemon. This solution is known as *docker-in-docker* and replaces the need for separate VMs to test a swarm.

To interact with the docker swarm, open a new terminal and execute
```
export DOCKER_HOST=127.0.0.1:22375
docker node ls
```

you should see an output similar to this:

```
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
le7ktjjhmritygw2d2mygky6n *   swarm-manager-1     Ready               Active              Leader              19.03.5
yf865k2r0k3g2igctgamdnw24     swarm-worker-1      Ready               Active                                  19.03.5
ubsg9jaqu9qsoebq45h3ssiti     swarm-worker-2      Ready               Active                                  19.03.5
i4a0yco1voqvpo2676098l3ok     swarm-worker-3      Ready               Active                                  19.03.5
```

If you see an error or some of your workers are not ready, [simply shut down the swarm](#Shut-down) and try again. The workers try to join the swarm after 10 seconds (See `sleep 10` in `docker-compose.swarm.yml`). You can adjust this waiting period accordingly if you see your workers not connecting.

Finally, in the same terminal in which you set the `DOCKER_HOST` variable execute: `./deploy_all_dev.sh`

This will build all needed images, push them to a private registry which is also created on this swarm, and deploy all stacks as defined in the docker-compose.yml-files in this repository.

You should be able to reach the FROST-Server `localhost/v1.0/`

## Shut down

Shut down the swarm:
```
docker-compose -f docker-compose.swarm.yml down -v
```

This will also remove any state of the swarm and all the docker stacks within the swarm. Currently this is needed as a complete recovery of the stack within the containerized swarm is not always possible.

# Overview
![Overview](overview.png)
