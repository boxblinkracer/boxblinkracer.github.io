---
layout: post
title: Secure Symfony deployments against missing ENV variables
description: How to protect yourself from deploying an application with missing ENV variables.
date: 2024-1-18 10:00:00 +0300
image: '/images/blog/symfony-missing-envs/header.png'
tags: [ devops, dev, qa ]
---


---

In the world of software development, environment variables are a crucial thing to enable usage of sensitive data, or configuration information
depending on the current environment of the system. So basically everything you can't or must not add to Git :)

This however also means that you need to take care of preparing these variables when deploying your application.

Before we proceed with the problem, there is a ready-to-use demo application available as download.
It comes with a README file that guides you through the whole story of that application.

<a target="_blank" rel="noopener nofollow noreferrer" href="https://github.com/boxblinkracer/boxblinkracer.github.io/tree/main/downloads">symfony-demo-missing-env.zip</a>


# The problem

Let's assume you have a Symfony application and you are using environment variables. These variables are typically used somewhere in your application.
The usage is often inside a service class or component.

And very likely, these classes are not used everywhere in your application, but maybe only on a specific case, or even in a specific condition somewhere.
This also means, that there might not always be an instance created of it.

Here is an example.

Imagine a class that requires an Api Key inside the constructor:

```php 
 private string $apiKey;

 public function __construct(string $apiKey)
 {
     $this->apiKey = $apiKey;
 }
```

In this case, we might not be able to do auto-wiring in Symfony, so we have to explicitly tell the application where to find the Api Key.
We do this in the **services.yaml** (in our case) and tell Symfony to use the environment variable **TRACKING_API_KEY**.

```yaml
services:
  App\Service\TrackingService:
    arguments:
      $apiKey: '%env(resolve:TRACKING_API_KEY)%'
```

Now whenever we inject our TrackingService somewhere, a new instance will automatically use the Api Key from the environment variable,
which we assume should be in the **.env** file in our case.

But what's the problem now?

If we open the page that uses the TrackingService, we will see an error, because the environment variable is missing.
And this is correct.

Now head over to a different page - **there is no error**! Also, head over to the CLI and run your typical commands that you use
when deploying the application in your pipeline - **no error**!

> Now you should know why you should be worried.

If we don't pay attention to have valid environment variables, we could break the application without even recognizing it!

Yes we could probably add default values, but that would also require additional and conditional handling in our application.
But why should we do this, if we always require an environment variable?

# The solution

## Placing the solution

Let's figure out what we really want to do. We want to make sure that our **pipeline correctly fails when an environment variable is missing**.
So we need some kind of CLI command that checks for missing variables.

What about adding something like this to our Makefile (yes we assume having makefiles): **make check-envs**.
That would be great right? But isn't it too dangerous to have a separate command that nobody uses?
This could easily be forgotten inside a pipeline!

Now let's think about how we could make sure that this command is always executed before we deploy our application.

In my projects, I often use a **make build** command which builds the application, whatever it means in your case.
But it's very likely that there is a step to build the application, even if it's just installing assets.

What if we would just enhance that command and make sure, that the build process doesn't even work on missing environment variables?
That would even make sense right, because it's broken and it cannot be built then!

## Scripting the solution

Okay, so we finally know where to place the check. But how do we actually do it?

Symfony offers a great command to debug and check for missing environment variables.

```ruby 
php bin/console debug:container --env-vars
```

This however has **no correct exit return value** that could break our pipeline correctly, because it's only for debugging purposes.

But the great thing is, with a bit scripting and experience using `grep`, we can easily extract warnings, if existing, and decide
on whether to proceed the build process or not.

Here is the full makefile command to build our application.
It will automatically fail if there are missing environment variables.

```ruby
build:
	if php bin/console debug:container --env-vars | grep 'WARNING'; \
		then php bin/console debug:container --env-vars; exit 1; \
	fi
	php bin/console --no-debug assets:install
```

# Conclusion

We secure our application with all kinds of tests and analysers, but still have a weak point when deploying the application.
I know that, because it already happened to me.

This simple solution can easily prevent you from running into the same issue in your applications.

Links:

* <a target="_blank" rel="noopener nofollow noreferrer" href="https://symfony.com/doc/current/configuration/env_var_processors.html">https://symfony.com/doc/current/configuration/env_var_processors.html</a>
