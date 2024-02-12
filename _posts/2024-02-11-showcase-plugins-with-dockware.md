---
layout: post
title: Building Showcase Docker images for your Shopware plugins
description: Build your own showcase Docker image with your Shopware plugin for your potential customers with dockware.
date: 2024-2-11 10:00:00 +0300
image: '/images/blog/shopware-showcase-docker/header.png'
tags: [ devops, dev, shopware ]
---


---

Shopware is one of the leading e-commerce platforms in Germany and Europe. With its built-in plugin system, it’s easy to extend and customize the platform to suit your needs.

This robust ecosystem forms the foundation for many plugin manufacturers and developers.

But what if you, as a plugin manufacturer, wish to showcase your plugins to potential customers? What if they do not currently have a Shopware installation up and running?
Or what if you just want an easy online setup that you can immediately reset by simply restarting your containers?

This article demonstrates how to effortlessly create showcase Docker images that anyone can run with a single command. Launching and testing your plugins has never been easier - even on a local machine.

Consider this example: with just one line in your terminal, you can launch the latest **Shopware 6** instance with the **Mollie payment plugin pre-installed**, alongside various pre-configurations and adjustments to ensure it **works seamlessly out of the box**.

```bash 
docker run --rm -p 80:80 boxblinkracer/shopware6-mollie
```

You can find the full example as open source project in my <a target="_blank" rel="noopener nofollow noreferrer" href="https://github.com/boxblinkracer/docker-sw6-mollie">Github repository</a>.

Let's build a Docker image for your plugin!

# Building the project

We start by creating a new directory and placing a **Dockerfile** inside of it.
This file is used from Docker to build your image.

Usually, you would start with a base image, like **php:8.3-apache**.
Or you can also start with a plain **ubuntu** based image.

The problem is, that you also need to take care of having Shopware installed and prepared for your needs.
This can be avoided by just inheriting from the **dockware/play** image that comes with a prepared Shopware 6 including demo data.

If you want to read more about dockware, see <a target="_blank" rel="noopener nofollow noreferrer" href="https://www.dockware.io">www.dockware.io</a> for more.

Let's add these 2 lines to our Dockerfile.
The first one makes sure to inherit from the dockware/play image, the second line is used when launching the image.
It will just make sure to call the built-in **entrypoint.sh** script from dockware, that starts MySQL and a lot more.

```Dockerfile
FROM dockware/play:latest

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
```

That's almost everything about the basics.

If you now run the command below, it will build the Docker image from the Dockerfile in the current directory ("."). The name of the image will be **myCompany/shopware6-pluginname:latest**.
And we can even push it to our existing Docker Hub account to make it available for everyone.

```bash 
docker build -t myCompany/shopware6-pluginname:latest .

docker pull myCompany/shopware6-pluginname:latest
```

# Adding the plugin

Now, if you're looking to add our plugin to the Shopware installation, there are various methods to do so, depending on where you want to source your plugin from. You could opt to build it directly from GitHub, from a ZIP file, or even acquire it from the Shopware store.

Please keep in mind that everything you add to a public Docker image, can be seen by everyone.
So, if you have a paid plugin, it might not be the best idea, or even allowed to add it to a public Docker image.

Let's continue by adding our plugin directly from the official Shopware store using **composer**.

Our Dockerfile will again start from the dockware/play image.

The new **RUN layer** we add, will first start our MySQL to make sure we can access the database.
Afterward we add the **packages.shopware.com repository** to our composer configuration.
Unfortunately we need a **token** to access the packages. Please keep in mind, this will be placed inside the distributed Docker images, so don't put confidential information here.

Luckily our plugin is a free plugin, so we can just add the token "**test**" and it will work!

After preparing the Shopware registry, we can simply install our plugin by using the corresponding composer command.

Finally, a bit cache clearing, refreshing of plugins, and we can already **install** and **activate the plugin**
before finishing the layer by gracefully stopping our MySQL service.

```Dockerfile
FROM dockware/play:latest

RUN sudo service mysql start && \
    cd /var/www/html && composer config repositories.shopware-packages '{ "type": "composer", "url": "https://packages.shopware.com" }' && \
    cd /var/www/html && composer config bearer.packages.shopware.com "test" && \
    cd /var/www/html && composer require store.shopware.com/molliepayments && \
    cd /var/www/html && php bin/console --no-debug cache:clear && \
    cd /var/www/html && php bin/console --no-debug plugin:list && \
    cd /var/www/html && php bin/console --no-debug plugin:refresh && \
    cd /var/www/html && php bin/console --no-debug plugin:install --activate MolliePayments && \
    cd /var/www/html && php bin/console --no-debug cache:clear
    sudo service mysql stop

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
```

And that's it.
When you start your Docker image, it will start a Shopware 6 with your plugin already installed and activated.

# Custom Features and Configuration

What if you want to add some custom features or configurations to your plugin?

You can of course add anything you want to your **Dockerfile** setup.
This will be added at **build time**.

If you want to create custom and flexible features that users can adjust inside their containers, you might want to add
features to a custom **entrypoint** file.

We create a new file **plugin-entrypoint.sh** in your project folder.
Our entrypoint loads environment variables and verifies if we have a value for **MY_KEY**. If so, we set
this value for our config.apiKey using the Shopware CLI command for configurations.

```bash
#!/bin/bash
set -e
source /etc/apache2/envvars
source /var/www/.bashrc
export BASH_ENV=/var/www/.bashrc

if [ $MY_KEY != '' ]; then
  sudo service mysql start;
  cd /var/www/html && php bin/console --no-debug system:config:set MyPlugin.config.apiKey "$MY_KEY"
  sudo service mysql stop;
fi

exec "$@"
```

The final step is to incorporate our entrypoint file into the Dockerfile during the image building process. Since Dockware already utilizes an entrypoint, we can simply append our custom entrypoint before the one from Dockware (/entrypoint.sh).

```Dockerfile
FROM dockware/play:latest

ADD plugin-entrypoint.sh /plugin-entrypoint.sh

# other things...

ENTRYPOINT ["/bin/bash", "/plugin-entrypoint.sh", "/entrypoint.sh"]
```

Congratulations, you now have a custom feature for your Docker image.

```bash 
docker run --rm -p 80:80 --env MY_KEY=api123 myCompany/myPlugin:latest
```

# Automatic Building in Pipelines

Let's be honest, manual building and updating of your Docker image isn't the most efficient approach, right?

Here's a sample **CircleCI workflow** to automate the process:
It will build the images in parallel for AMD and ARM and pushes both to Docker Hub as tags **latest-arm64** and **latest-amd64**.
Then it creates a custom manifest for **latest** that includes both of our previous tags.
The pipeline can be initiated manually but can also be run automatically and scheduled.
I personally love to build a **Github workflow** that helps me to trigger CircleCI either manually or automatically.

```yaml
version: 2.1

parameters:
  imgName:
    type: string
    default: "myCompany/myProject"

workflows:
  release_image:
    jobs:
      - build-arm64:
          name: build-arm64
      - build-amd64:
          name: build-amd64
      - build-manifest:
          name: update-manifest
          requires:
            - build-arm64
            - build-amd64

jobs:

  build-arm64:
    machine:
      image: ubuntu-2204:current
      docker_layer_caching: true
    resource_class: arm.medium
    steps:
      - checkout
      - run:
          name: Docker Hub Login
          command: echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
      - run:
          name: Build and push
          command: |
            docker build -t << pipeline.parameters.imgName >>:latest-arm64 --build-arg ARCH=linux/arm64 docker
            docker push << pipeline.parameters.imgName >>:latest-arm64

  build-amd64:
    machine:
      image: ubuntu-2204:current
      docker_layer_caching: true
    resource_class: medium
    steps:
      - checkout
      - run:
          name: Docker Hub Login
          command: echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
      - run:
          name: Build and push
          command: |
            docker build -t << pipeline.parameters.imgName >>:latest-amd64 --build-arg ARCH=linux/amd64 docker
            docker push << pipeline.parameters.imgName >>:latest-amd64

  build-manifest:
    machine:
      image: ubuntu-2204:current
      docker_layer_caching: true
    resource_class: medium
    steps:
      - run:
          name: Docker Hub Login
          command: echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
      - run:
          name: Create and push manifest
          command: |
            docker manifest create << pipeline.parameters.imgName >>:latest --amend << pipeline.parameters.imgName >>:latest-amd64 --amend << pipeline.parameters.imgName >>:latest-arm64
            docker manifest push << pipeline.parameters.imgName >>:latest
```

# Conclusion

Having a well-prepared showcase Docker image for your plugins greatly simplifies the testing and evaluation process for potential customers. They no longer require Shopware or need to deal with installation and configuration hassles.

You can prepare a perfect environment and make sure people immediately see the value of your plugin.

Links:

* <a target="_blank" rel="noopener nofollow noreferrer" href="https://github.com/boxblinkracer/docker-sw6-mollie">Docker Image for Mollie Shopware 6</a>
* <a target="_blank" rel="noopener nofollow noreferrer" href="https://www.dockware.io">https://www.dockware.io</a> 
