## A Postgres replica has lost its synchronization with the master

Symptoms: Frost-Queries return old data sometimes/always. Writing to the database has seemingly no effect.

Cause: The Master sends WAL-archives to the replicas to share a consistent database.
        If a replica did not catch up in time the needed data might have been deleted.

Resolution: The SQL-Database of the replicas is in an unusable state.
        You need to manually remove the corrupted volumes and recreate the read-only databases:

First, redirect all read SQL-Queries to the main database. This will give us time for the next steps.
Then shut down the read-only postgres instances
```
#Connect to the Swarm Manager
export DOCKER_HOST=ubuntu@smartaqnet-master.dmz.teco.edu
#Start the frost stack again but with the emergency override. This will redirect all SQL requests to the master database.
docker stack deploy -c ./frost/docker-compose.yml -c ./emergency-helpers/docker-compose.frost-emergency-read.yml frost
#Remove the replica service
docker service rm postgis_replica
```

Remove the corrupt database from all replica workers. Make sure to NOT delete the database from worker1 or whatever worker is hosting the master database. While connected to the swarm manager you can inspect (`docker node inspect`) the nodes to make sure they are replicas (`"postgis": "replica"` is a label).
```
#Use the docker daemon of the worker
export DOCKER_HOST=ubuntu@smartaqnet-worker2.vm.teco.edu
#Find dangling volumes
docker volume ls --filter "dangling=true"
#The replica SQL volume should be one of them, remove it
docker volume rm <name>
#Repeat for other workers
```

Now, we can redeploy the whole postgis stack. The replicas will initialize automatically.
```
#Connect to the Swarm Manager
export DOCKER_HOST=ubuntu@smartaqnet-master.dmz.teco.edu
#Redeploy the postgis stack 
docker stack deploy --with-registry-auth -c ./postgis/docker-compose.yml postgis
```

You can follow the replica logs:
```
docker service logs postgis_replica --follow
```

When finished, redeploy the frost stack, so it uses the replicas again:
```
#Connect to the Swarm Manager
export DOCKER_HOST=ubuntu@smartaqnet-master.dmz.teco.edu
docker stack deploy -c ./frost/docker-compose.yml frost
```