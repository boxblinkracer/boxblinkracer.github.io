---
layout: post
title: Automate your CI/CD pipeline with Buddy and OpenAI
description: Ever thought about using AI inside your CI/CD system. It's possible - read more to find out how.
date: 2023-12-8 10:00:00 +0300
image: '/images/blog/buddy-openai/header.png'
tags: [ devops, ai, dev ]
---


---


In the fast-paced world of software development, Continuous Integration and Continuous Deployment (CI/CD) have become indispensable tools for
delivering high-quality software efficiently.

Buddy is a robust CI/CD application designed to streamline the software development
lifecycle by automating various tasks involved in building, testing, and deploying applications.
It provides a comprehensive set of tools and features that enable developers to create, manage, and optimize their CI/CD pipelines efficiently.

Since a few versions, Buddy has introduced the option to create and use **custom actions**.
This allows developers to extend and customize their pipelines according to their specific requirements with individual integrations and tasks.

While digging deeper into the possibilities of custom actions, I was wondering, how could **AI** be used inside our pipelines.
Is it possible? Is it reliable? Let's find out!

I've implemented a custom action for Buddy that allows us to use **OpenAI** inside a pipeline.
Based on this, I was able to play around with how AI could influence our delivery process in the future.

And yes, I'm still thinking about other cool and bullet-proof use cases - so this is a **proof of concept** that shows what could be done,
and how a process could look like.

The end of the blog post will also contain a link to the **open source repository**, where you can find the custom OpenAI action, along with other actions,
that you could use inside your Buddy workspace.

## Proof of Concept: Only deploy with valid Ticket ID

My proof of concept is about deployments that require a ticket ID.

So let's assume that we **require a ticket ID** being present in the commit message.
In addition to our ticket ID, a NTR (not ticket related) is also allowed.
But if both are missing, the deployment should be **canceled**.

If our deployment is executed and was successful, we also want to create some kind of **changelog** for our commit message.
This changelog should not be very technical.
The idea is to send it out via **Slack** to our **English team**, as well as to the **Dutch team** by providing a translated version of the changelog.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/buddy-openai/sample.png" loading="lazy" alt="" >
    </div>
</div>

### 1. Ask OpenAI if Ticket ID is found

I've created a sample open source repository with custom Buddy actions, just like the **OpenAI integration**.
Please start by adding that project to your Buddy workspace as described in the repository. (link at the end of this blog post).

The custom OpenAI action allows us to provide a **prompt**, as well as our **OpenAI key**.

Please keep in mind, if you have multiple of these OpenAI actions, it's recommended to use a **workspace variable** in Buddy for the OpenAI key,
instead of placing it directly into every OpenAI action in your pipelines. This helps you to centralize your key in Buddy.

The output of the OpenAI action is stored in a variable **OPENAI_ANSWER**, which can be used in subsequent actions.
The result contains the first choice of the OpenAI engine, which is the most likely answer to your prompt.

As a prompt, I told OpenAI to look for a ticket ID. I've provided the **patterns** for ticket IDs, as well as the **possible answers** that OpenAI should return.
This helps to get a more accurate result for further processing.
Last but not least I've added the **commit message** by using one of the prepared variables of Buddy: **$BUDDY_EXECUTION_REVISION_MESSAGE**.

Here's the prompt:

```html
Does this text contain a ticket ID? The pattern is either NTR or PR-xyz . Possible answers yes/no : $BUDDY_EXECUTION_REVISION_MESSAGE
```

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/buddy-openai/config-1.png" loading="lazy" alt="" >
    </div>
</div>

The result of the action can then look like this:

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/buddy-openai/result-1.png" loading="lazy" alt="" >
    </div>
</div>

## 2. Store result in variable

Because we are using multiple OpenAI requests, these will override our result variable **OPENAI_ANSWER** inside our pipeline.
Therefore, we want to store our initial result in a new and separate variable **TICKET_FOUND**.

We do this by adding a new **Local Shell** action, that will execute the following command:

```shell
export TICKET_FOUND=$(echo "$OPENAI_ANSWER" | tr '[:upper:]' '[:lower:]')
```

After that, we have access to the variable **$TICKET_FOUND** with the possible options "yes" and "no".
We also make sure it's always lowercase, so we don't have to deal with different cases in our conditions later on.


<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/buddy-openai/config-2.png" loading="lazy" alt="" >
    </div>
</div>

## 3. Run actions if Ticket ID was found

All that is left now, is to add a new condition in our subsequent actions, that verify if
the value for our variable **$TICKET_FOUND** is "yes".

If OpenAI cannot find a ticket ID pattern, then these actions will not be executed.

We open our **Deployment Action**, and add our condition.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/buddy-openai/config-3.png" loading="lazy" alt="" >
    </div>
</div>

## 4. Ask OpenAI to create a changelog

Let's say we have deployed our new application (if a ticket was found).
Now we want to add an OpenAI action and have a **changelog** being created for us.

This should not be technical, and it should have a maximum of 300 characters.

We ask OpenAI to create this changelog with the following prompt, and also provide the commit message by using the variable **$BUDDY_EXECUTION_REVISION_MESSAGE**.

```shell
Create a non-technical release note. keep easy and short with max 300 characters: $BUDDY_EXECUTION_REVISION_MESSAGE
```

Below is the changelog I got for my commit message.

```shell
# commit message:
PR-123: fix curl problem in previous version

# OpenAI answer:
Release Note: PR-123 has resolved the curl issue in the previous version. Enjoy a smoother experience with our latest update.
```

This is already a pretty good result. Now just imagine fetching the content of your Jira ticket and use this one in your prompt.
I think you will get some amazing results in most cases.

## 5. Send changelog to English and Dutch team in Slack

We can now simply add a **Slack action** in Buddy as next step in our pipeline.

As the message, we just need to use the variable **$OPENAI_ANSWER**, and the changelog will be sent to our configured Slack channel.
That's it :)

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/buddy-openai/config-4.png" loading="lazy" alt="" >
    </div>
</div>

Before we send the changelog to our Dutch team, we want to **translate it to Dutch**.

We add another OpenAI action, that will translate the changelog.
All we do is, we ask OpenAI to translate the answer of our previous OpenAI action into Dutch.

```shell
translate this to dutch: $OPENAI_ANSWER
```

The result (again stored in the variable **$OPENAI_ANSWER**) could then look like this, and can be sent out to our Dutch team
using another Slack action in our pipeline.

```shell
PR-123 lost een curl probleem op van de vorige versie. Geniet van een soepelere ervaring met onze nieuwste release!
```

And that's it!
We have sent our changelog to our English and Dutch team, and we didn't event have to write a single line.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/buddy-openai/config-5.png" loading="lazy" alt="" >
    </div>
</div>

## Conclusion

Using AI inside our pipelines is a very powerful approach that can help us to automate things, we haven't been able to do before.
But we still need to be careful, because pipelines should always be reliable and bullet-proof.
Adding AI with unexpected results can be dangerous and risky.

While I am still thinking about more valid and less risky use cases,
my opinion is, having AI inside a pipeline is an absolutely stunning thought.
Depending on the use cases, it can indeed change the way we deliver software in the future.

Links:

* <a target="_blank" rel="noopener nofollow noreferrer" href="https://buddy.works/">https://buddy.works</a>
* <a target="_blank" rel="noopener nofollow noreferrer" href="https://openai.com/">https://openai.com</a>
* <a target="_blank" rel="noopener nofollow noreferrer" href="https://github.com/boxblinkracer/buddy-actions">https://github.com/boxblinkracer/buddy-actions</a> 

