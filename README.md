# Development Version

## Prerequisites
- Docker
- Docker-Compose
- Free ports as specified in docker-compose.swarm.yml

## Setup
Clone this repository with submodules:

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

# Production Version

## Swarm Set-up
[TBD: init swarm and setup labels, execute deploy_all_prod.sh on manager]

## Resize Docker partition
Use `lsblk` to find the partition the docker daemon is using. Use `growpart` and `resize2fs` to resize the partition/filesystem. Backing up the partition table before doing so would be better.

```
ubuntu@smartaqnet-worker1:~$ lsblk
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
vda     252:0    0   16G  0 disk 
├─vda1  252:1    0 15.9G  0 part /
├─vda14 252:14   0    4M  0 part 
└─vda15 252:15   0  106M  0 part /boot/efi
vdb     252:16   0   48G  0 disk 
└─vdb1  252:17   0   32G  0 part /var/lib/docker
ubuntu@smartaqnet-worker1:~$ sudo growpart /dev/vdb 1
CHANGED: partition=1 start=2048 old: size=67106783 end=67108831 new: size=100661215,end=100663263
ubuntu@smartaqnet-worker1:~$ sudo resize2fs /dev/vdb1
resize2fs 1.44.1 (24-Mar-2018)
Filesystem at /dev/vdb1 is mounted on /var/lib/docker; on-line resizing required
old_desc_blocks = 4, new_desc_blocks = 6
The filesystem on /dev/vdb1 is now 12582651 (4k) blocks long.

ubuntu@smartaqnet-worker1:~$ lsblk
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
vda     252:0    0   16G  0 disk 
├─vda1  252:1    0 15.9G  0 part /
├─vda14 252:14   0    4M  0 part 
└─vda15 252:15   0  106M  0 part /boot/efi
vdb     252:16   0   48G  0 disk 
└─vdb1  252:17   0   48G  0 part /var/lib/docker
```