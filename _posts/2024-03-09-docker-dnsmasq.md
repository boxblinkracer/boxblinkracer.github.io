---
layout: post
title: Easy multi-tenant wildcard domain setups with Docker and dnsmasq
description: Forget /etc/hosts! Create plug'n'play setups that allow hosts and containers to resolve any domain and use your project's reverse proxy for routing.
date: 2024-3-09 10:00:00 +0300
image: '/images/blog/docker-dnsmasq/header.png'
tags: [ devops, dev ]
---


While development setups have been relatively straightforward in the past,
requirements nowadays are way more complex, considering you want to have a production-like environment on your local machine.

The rise of headless systems, decentralized e-commerce approaches like Shopware Apps, and more, have led to developer environments
with way **more than just a single domain and a single server**.

My setups consist of things like NGINX reverse proxies, Vue.js apps, a couple of Symfony applications either as web based API, or as scaled
self-sufficient background workers. In addition to this an ELK stack based on Opensearch as well as Mailcatcher, REDIS, Grafana, Typesense, Swagger and more.
And that all in a single project.

This approach of multiple applications in a single project often comes with the requirement of having **multiple domains** to access these.
I usually register these domains on my host by adding them to the **/etc/hosts** file.

But as soon as you need to have dynamic domains, like in a **multi-tenant system**, or you want to have a wildcard domain,
then you reach the limits of /etc/hosts.

## Limitations of /etc/hosts

By editing the /etc/hosts file on your host, you can add static domain entries that resolve to a specific IP address.
So you can make up a domain and let it point to your localhost, that runs e.g. a Docker container on port 80/443.

```bash
127.0.0.1    my-project.dev
```

But this comes with a couple of limitations.

* Every new domain requires **manual intervention**. If you are an agency with multiple customers, this means that every developer needs to initially add the required domains of a new project to their local /etc/hosts file. If existing projects add new domains, you need to make sure that developers know about this and add them on their hosts again.
* If you have a **multi-tenant system** where each tenant has a unique and randomly generated subdomain like https://x5V12KLW3kbv32ksgc.my-project.dev, then you would need to add that generated domain to your hosts file. This means whenever you create a new tenant in the database or application, you get a new domain and need to manually add it again and again to your file. This is just not feasible for a production-like developer environment.
* Let's bring it to the next level. In your **multi-tenant system**, you need to call the tenant's domain from a **container inside your Docker network**. Assume we have just configured our tenant domain on our host machine, how would your **container know** about these domains too? And again, what if you create new tenants and get lots of new generated domains?

If you face such challenges, you might be looking for a more flexible and automated solution that can handle dynamic domains and resolve them to the appropriate container.

In this article, I'll guide you through the process of setting up a **DNS server** using **dnsmasq** in your **Docker setup**, enabling seamless communication within your development environment.

---

# Our Project

We will use a simple Docker setup with a NGINX reverse proxy, a Shopware container, and an API container for this article.

In our project, every tenant has a unique domain to call our API, like https://mandate-123.project.dev.

The call however, should not only be working from our host machine, but also from our Shopware container from within our Shopware plugin (server-side request from container to container).

## 1. Docker Setup

Here is our sample **docker-compose.yml** file.

```yaml
version: '3'

services:
  proxy:
    image: dockware/proxy:latest
    container_name: proxy
    ports:
      - "80:80"
      - "443:443"
    networks:
      - web
    volumes:
      - "./docker/proxy:/etc/nginx/conf.d"
  shopware:
    container_name: shopware
    image: dockware/play:6.5.8.2
    networks:
      - web
  api:
    container_name: api
    image: dockware/flex:latest
    networks:
      - web

networks:
  web:
    external: false
```

## 2. NGINX Configuration

Here is 1 sample of our NGINX configuration for the reverse proxy.

The domains in our project are:

* shopware.project.dev
* api.project.dev

The proxy listens to our ports 80 and 443 for both domains and routes the requests to the appropriate container, using the **proxy_pass** directive.

```bash 
server {
    listen          80;
    server_name     api.project.dev;
    return 301      https://$host$request_uri;
}

server {
    listen           443 ssl;
    server_name      api.project.dev;
    
    ssl_certificate /etc/nginx/ssl/selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/selfsigned.key;
    
    location / {
        proxy_set_header Host $host;
        proxy_pass https://api;
    }
}
```

## 3. Add our DNS Server

Usually we would add the following domains to our /etc/hosts file on our host:

```bash
127.0.0.1  api.project.dev 
127.0.0.1  shopware.project.dev
```

But because of the limitations of /etc/hosts, we want to use a DNS server that resolves these domains to our Docker containers.
So we add a new container for **dnsmaq** to our docker-compose.yml.

```yaml
  dnsmasq:
    image: jpillora/dnsmasq
    ports:
      - "53:53/udp"
    networks:
      - web
```

The container exposes the **port 53** to our localhost, which is the default port for DNS servers.
Make sure that your port 53 is not already in use on your host.
If you use <a target="_blank" rel="noopener nofollow noreferrer" href="https://orbstack.dev">Orbstack</a>, you're good to go, if you use Docker Desktop, you might need to open the settings, navigate to Resources/Network and
disable the feature "Use kernel networking for UDP".

The next step is to **tell our host to use this DNS**, but only for requests to our domain **project.dev**.

If you are on a Linux or MAC system, you can easily adjust the **resolver** configuration.
To lock down the resolver to only resolve the project.dev domains, we just need to create a new file in the **/etc/resolver** directory, with the name of our domain.
The file should contain the content **nameserver 127.0.0.1** which means that the nameserver will be searched on our localhost on port 53, which is our dnsmasq container (if running).

```bash 
sudo mkdir -p /etc/resolver
sudo rm -rf /etc/resolver/project.dev
sudo sh -c 'echo "nameserver 127.0.0.1" >> /etc/resolver/project.dev'
```

Congratulations! When you now request any domain ending with project.dev,
your host will already start to communicate with the dnsmasq container.

## 4. DNS Server Configuration

The configuration for dnsmasq is pretty simple.
We just need to tell it to resolve all project.dev domains to a specific IP.

```bash 
address=/project.dev/(targetIP)
```

**But what IP do we need?**

It's the IP of our **reverse proxy** Docker container, because that one does all the routing magic.

Unfortunately our proxy container does not have a static IP that we know.
So let's give it one.

This can be done by configuring our network in the docker-compose.yml file and assign a subnet.
Afterwards we can assign a static IP based on that subnet to our proxy container.

Our network gets the 10.0.0.0/24 range and our proxy gets the IP address **10.0.0.100**.

```yaml

proxy:
  image: dockware/proxy:latest
  ...
  networks:
    web:
      ipv4_address: 10.0.0.100

networks:
  web:
    external: false
    ipam:
      config:
        - subnet: 10.0.0.0/24
```

Now let's create a configuration for our DNS server.
Create a file **dnsmasq.conf** file and add this line to it.

```bash 
address=/project.dev/10.0.0.100
```

We also need to mount this file to our dnsmasq container in the docker-compose.yml file.

```yaml
  dnsmasq:
    image: jpillora/dnsmasq
    ...
    volumes:
      - "./dnsmasq.conf:/etc/dnsmasq.conf"
```

And that's it!

If you now open a project.dev domain on your host,
it will use the nameserver of your dnsmasq Docker container, that resolves the domain by pointing to our reverse proxy container in Docker.

The reverse proxy will then route the request to either the Shopware container or the API container, as long as the subdomains are recognized
according to the NGINX configuration.

Now just imagine you automate these steps. Especially the ones that write the resolver on the developer machines.
None of your developers need to configure anything manually anymore. It just works with the provided docker-compose.yml file and your setup script automation.

## 5. Multi-Tenant Systems

How can we now resolve our **randomly generated domains** like https://x5V12KLW3kbv32ksgc.project.dev?

The good thing is, we don't need to do anything special for this.
Our setup is already fully prepared. The only thing we need to adjust is the **NGINX configuration**.
Our reverse proxy just needs to listen to these wildcard domains and route them to the appropriate container.

Here is an example of a configuration that listens to ***.project.dev** and forwards it to our API container.

```bash
server {
    listen        80;
    server_name   *.project.dev;
    return 301 https://$host$request_uri;
}

server {
    listen        443 ssl;
    server_name   *.project.dev;

    ssl_certificate /etc/nginx/ssl/selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/selfsigned.key;

    location / {
        proxy_set_header Host $host;
        proxy_pass https://api;
    }
}
```

## 6. Multi-Tenant Systems (inside Docker Containers)

We also want our Shopware container to be able to request the domain https://x5V12KLW3kbv32ksgc.project.dev.
The requests are not done on the host system but directly from **within the container**, which means our current setup is not enough.

But the good thing is, we just need to repeat almost the same steps as on our host system.
More specific, we just need to prepare the **resolver in our container**, and that's it.

So what is missing in theory are these bash commands:

```bash 
sudo mkdir -p /etc/resolver
sudo rm -rf /etc/resolver/project.dev
sudo sh -c 'echo "nameserver 127.0.0.1" >> /etc/resolver/project.dev'
```

Unfortunately, the IP address **127.0.0.1 is wrong**.
While our host system uses the localhost with port 53 to detect the dnsmasq container, our container needs to use the **IP address of the dnsmasq container inside the Docker network**.

So we need to give our dnsmasq container a **static IP address**, as we just did with our proxy.
We use 10.0.0.99 in our sample.

```yaml
  dnsmasq:
    image: jpillora/dnsmasq
    ...
    networks:
      web:
        ipv4_address: 10.0.0.99
```

Now we can add nameserver entries inside our Docker containers, that point to the IP address **10.0.0.99**.

However, assigning that manually would be too much effort. Especially when we have a system of multiple Docker containers.

We want to **automate this process**.

Let's create a script **configure_nameservers.sh**.
It iterates through all running containers and executes the commands to adjust the nameserver values.
You can also provide a static list of containers instead of iterating through running containers of course.

Please note that the requirements and concept of the "sudo" and "echo" commands might be a bit different for you, depending on what Docker images you use.
But the idea is the same.

```bash
#!/bin/bash
# dynamically get all running containers
containers=$(docker ps --format '{{.Names}}' )
# use a static list of containers
#containers="shopware api"

for container in $containers
do
    docker exec -it $container bash -c "sudo sh -c 'echo \"nameserver 10.0.0.99\" > /etc/resolv.conf'"
    docker exec -it $container bash -c "sudo sh -c 'echo \"options ndots:0\" >> /etc/resolv.conf'"
done
```

Now run your command:

```bash
sh configure_nameservers.sh
```

That's it!

Your Shopware container can just request https://x5V12KLW3kbv32ksgc.project.dev directly from within the container, even though
no one did ever configure it to exist somewhere.
The request will be passed on to the Docker reverse proxy and route to the API container, according to your configuration.

Now imagine running this script in the **automation process of your project setup**.
It will all work out of the box for every developer and every container.

Please keep in mind, that you need to consider that you might have self-signed certificates when working with HTTPS.
So send requests from host and containers with disabled SSL checks, or make sure your containers have the certificates installed as trusted ones.
But this is a new topic and not part of this article.

## Conclusion

By using a specific **dnsmasq** container along with a **custom resolver** configuration, we prepared not only our host system,
but also our Docker containers to call whatever domain we want.

And this all without any configuration interaction from a developer.

Links:

* <a target="_blank" rel="noopener nofollow noreferrer" href="https://orbstack.dev">Orbstack for MAC</a>
* <a target="_blank" rel="noopener nofollow noreferrer" href="https://github.com/jpillora/docker-dnsmasq">https://github.com/jpillora/docker-dnsmasq</a>



