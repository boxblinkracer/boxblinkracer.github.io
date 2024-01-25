---
layout: post
title: Message Queueing with Docker and self-sufficient replica containers
description: Building self-sufficient (worker) containers and seamlessly integrate them into your dev-setup experience.
date: 2024-1-25 10:00:00 +0300
image: '/images/blog/docker-replica-containers/header.png'
tags: [ devops, dev ]
---


---

Scalable and performant applications are the key to success nowadays.
In lots of cases this means using **asynchronous processes** to handle tasks in the background.

Whether you go with Event Sourcing, CQRS or just plain old message queues, you always have the same setup which
involves queues, messages and workers that consume those messages.

But how do you build that **locally for developers**? Shouldn't we aim for a setup that is as close as possible to
production? But still, shouldn't it be as slim as possible for our local developer machines?

This article shows you some neat tricks to get awesome **self-sufficient** worker containers locally.
We will build worker containers, that manage themselves, but also be able to run things on these containers
in our automation scripts for the setup.

## The architecture

Let's start with our architecture.

We have a basic web application. It can be a Symfony application, a Laravel application or even something not related to PHP.

Our web application contains an API to receive commands or events that should trigger an asynchronous handling.
The asynchronous handling is done by a worker process in the background.
So our API adds a new message to the queue, and then a separate process listens for those messages inside the queue.

If new messages exist, a worker fetches a new message and its data and then processes it.

Our **docker-compose.yml** contains a simple web container that handles HTTP and HTTPS requests and forwards it to our application.
Please note that the queueing system is not part of snippet below, just to keep it slim for the sake of this article.

```yaml
  app:
    image: dockware/flex:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "./src:/var/www/html"
```

## Consuming messages

Let's imagine having a Symfony application. We would for instance consume our messages with the following command:

```bash
php bin/console messenger:consume
```

We have a couple of options to work with this now.
We can of course simply connect into the container and manually trigger that command. That's especially useful when
developing or debugging it.

Once we want to automate things, we could easily add a **cronjob** and start it.
That works too, but in production we have a really huge, scalable and decentralized system - and that's what we are building now.

## Adding worker containers

It's time to add our worker containers.
There are 2 options that we have.

We can an add explicit containers, like "worker1", "worker2" and so on.
Or, we could go the fancy way, and build a setup that easily allows us to **scale our workers up or down** on the local system.

Docker has the option to provide a **deploy.replicas** configuration. This means that that container is launched multiple times.
Unfortunately this prohibits us from using the **container_name** option. So we might not be able to run automated scripts on it
when setting up our developer environment after the containers have launched! But no worries - there is a solution later in this article.

Let's add a worker container that is replicated as 2 instances.
You can easily increase or decrease that number.

```yaml
  worker:
    image: dockware/flex:latest
    deploy:
      mode: replicated
      replicas: 2
    volumes:
      - "./src:/var/www/html"
```

Congratulations, after a **docker-compose up -d** you now have 2 worker containers running along your app container.

## Adding Supervisor to our worker containers

Okay - we have our worker containers. But how do we start our worker processes?
We could use **cronjobs** or **supervisor**, which gives us even more options.

Let's start by installing supervisor.
We do this by providing a installation script in our case.

Please keep in mind, depending on your container image there are different options to run installation scripts.
With **dockware** it's possible to inject a **boot_end** script that is executed at the end of the boot process. (yes you can also directly build images of course...)

```yaml
  worker:
    image: dockware/flex:latest
    deploy:
      mode: replicated
      replicas: 2
    volumes:
      - "./docker/scripts/install_worker.sh:/var/www/boot_end.sh:ro"
      - "./src:/var/www/html"
```

The following script installs supervisor, and executes a few (maybe for you unnecessary) permission adjustments.

What is important, is creating a supervisor **configuration file**.
This one contains the command that should be executed and also gives us the option to launch multiple processes at the same time.

And that's the **powerful thing**. We can now have a completely flexible setup according to our needs.
That means we can launch **2 workers** with each running **3 processes** at the same time, which brings
us to a total of **6 message consumers** across different instances.

```bash
sudo apt update && sudo apt install -y supervisor

sudo chown 33:33 /var/www/html/var -R
sudo chmod 775 /var/www/html/var -R

CONFIG=/etc/supervisor/conf.d/project_worker.conf

sudo mkdir -p /etc/supervisor/conf.d
sudo rm -rf $CONFIG
sudo touch $CONFIG
sudo chmod 777 $CONFIG

sudo echo "" >> $CONFIG
sudo echo "[program:app-worker]" >> $CONFIG
sudo echo "process_name=%(program_name)s_%(process_num)02d" >> $CONFIG
sudo echo "command=php bin/console messenger:consume" >> $CONFIG
sudo echo "directory=/var/www/html" >> $CONFIG
sudo echo "user=www-data" >> $CONFIG
sudo echo "group=www-data" >> $CONFIG
sudo echo "numprocs=3" >> $CONFIG
sudo echo "autostart=true" >> $CONFIG
sudo echo "autorestart=true" >> $CONFIG
sudo echo "stdout_logfile=/var/log/app-worker.out.log" >> $CONFIG
sudo echo "stderr_logfile=/var/log/app-worker.err.log" >> $CONFIG
sudo echo "" >> $CONFIG
```

That's it, once your containers are launched, supervisor is installed, configured and started.
As soon as you add messages to your queue, your workers will immediately start consuming them (from any of the instances).

## Adding automation to scripts

Can you remember the problem that we cannot specify container names for replicated containers?
Why is this a problem?

Let's imagine we have a command **make run** that starts a full pipeline to prepare things.
And maybe we want to drop the database for a fresh start inside that command.

Our running workers might **avoid** us doing so because they are connecting **over and over** again to the database.

```bash
make run: ## this is a sample of a command that configures our dev environment
  cp .env.dist .env
  docker exec -it app bash -c "composer install"
  docker exec -it app bash -c "npm install"
  docker exec -it app bash -c "php bin/console doctrine:database:drop --force"
  docker exec -it app bash -c "make build-assets-and-more"
```

So how can we stop our workers before dropping the database?
We cannot directly connect to them, because they don't have a name, such as our **app** container, right?

The solution is to run a small **bash script**.
And this should lighten up your eyes, because it suddenly gives you **full control** over your worker containers.

This is a script (scripts/stop_workers.sh) that extracts all container names that contain the word **worker** (your names might differ).
It then iterates over all containers and stops supervisor on them.

```bash
#!/bin/bash
containers=$(docker ps --format '{{.Names}}' --filter name=worker)

for container in $containers
do
  docker exec -it $container bash -c "sudo service supervisor stop"
  docker exec -it $container bash -c "sudo service supervisor status"
done
```

Let's add that script to our **make run** command.

```bash
make run: ## this is a sample of a command that configures our dev environment
  cp .env.dist .env
  docker exec -it app bash -c "composer install"
  docker exec -it app bash -c "npm install"
  sh scripts/stop_workers.sh
  docker exec -it app bash -c "php bin/console doctrine:database:drop --force"
```

# Conclusion

That's it.

We now have a super easy local Docker setup, with flexible replica sets of our worker containers.
All containers are installed in a self-sufficient way and will immediately start consuming messages from our queue.

And if we still need to execute scripts on them, we can do so by adding some easy bash scripts to our automation pipeline.