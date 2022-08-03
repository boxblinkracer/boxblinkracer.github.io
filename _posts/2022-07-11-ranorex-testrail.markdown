---
layout: post
title:  Automate your tests with Ranorex and TestRail
description: Increase test management efficiency by sending testing results from Ranorex to TestRail.
date:   2022-07-11 20:00:00 +0300
image:  '/images/blog/ranorex-testrail/header.png'
tags:   [qa, test-automation]
---


---

I'm a big fan of automation in general. May it be for development, deployments or even testing.
It is indeed a possible solution for many cases, but when it comes to testing, please keep the following in mind:

> Automation is not the solution to increase quality, but it's a great help to save time and reduce effort.

When we are talking about testing automation, some people focus on scaling up their tests to be fully automated and try to get rid of the manual work, while
others try to only automate what makes sense.

My opinion is that automated tests can **never remove the need of manual testing** and are therefore only a helping hand in your overall QA process.

Focusing on the latter approach, it's a must-have that your **testers are in full control** of what happens.
This means that testers should be using a **test management software**, and the actual **results** of automated testing frameworks should be **sent to this software**.

The final report in your management software will then contain a combination of manual testing results and automated ones.

But here is a difference when it comes to defining test runs.
Will your automation framework create new test runs **everytime** it is executed? That would make sense, absolutely.
On the other hand, your testers might have a prepared test plan with defined runs that you want to "fire" against.
Neither is right or wrong, it's just a matter of what you need in the end.

While lots of integrations focus on creating new test runs, I have indeed the need of doing it in a different way.
So I've created a custom **module for Ranorex** and TestRail to do this.

This article focuses on explaining you this approach, the benefits and how to install and configure the module.

But let's first start with the involved parties!

# TestRail

TestRail (<a target="_blank" href="https://www.gurock.com/testrail">https://www.gurock.com/testrail</a>) is one of the available test management applications out there.
I like it because of its **efficient** look and feel, its **features** and the available **API** that lets you really get the most out of your processes and integrations.

The basic concept is that you create **test cases** in your projects.
Test cases are the elaborated scenarios, stories and things you want to test in your project.
These test cases can be structured with **sections** so that you have a better overview.
Every test case has different properties such as **type**, **automation type**, **reference IDs** that allow you to apply filters later on.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/ranorex-testrail/testrail-cases.png" loading="lazy" alt="">
    </div>
</div>

After your test cases have been prepared, you can use them in your **test plans** and **test runs**.
A test plan contains multiple test runs.

And this is where it starts to get tricky.

Creating a concept on how you test in a project really depends on your skills, the project itself, budget, capacity and way more.
If you have experience in that, or even have the ISTQB certificate, you know what I'm talking about.

In projects that need to be more efficient, and where controlling is not that important, I've figured out that
*long-running test runs* are better than starting a new run everytime I (re)test.

So in TestRail I usually create a new test plan, and then add **separate test runs** that should all be green before I release.
Why separate ones? Because I want to have the separation **visually in my plan**.
There is a test run for the automated tests, another one for "Smoke and Sanity", and then maybe for regression tests, new features and more.

The runs include required test cases and are either chosen by using filters or by simply selecting specific test cases that I need.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/ranorex-testrail/testrail-plan.png" loading="lazy" alt="">
    </div>
</div>


When testing starts, I can just open a test run, read the instructions and add a new result, such as passed, failed, and more.
Depending on your defect management, you can then proceed by pushing defects to Jira for instance. But this is a totally different story.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/ranorex-testrail/testrail-result.png" loading="lazy" alt="">
    </div>
</div>


While I could easily test every test run of our plan manually, I can also start to **outsource these**.
And I think the best one would be to let **a system** test some of our test runs, right?

# Test Automation Frameworks

When deciding on a framework to automate your test cases, please pay attention to what you **really need for your business**.

What **programming language** do you prefer? Do you need **CI/CD** options? What is the most stable framework for your projects (yes, you really need to try it!).
And also, what do you actually want to test? And what **platform**?

I've reduced my stack to 2 basic frameworks that I like very much.
For web related things I use **Cypress** for Windows I use **Ranorex**.

And especially when it comes to testing Windows Desktop applications, there is just no way around Ranorex.

# Ranorex

Ranorex (<a target="_blank" href="https://www.ranorex.com">https://www.ranorex.com</a>) is a **UI test automation framework** for Windows Desktop, Web and Mobile platforms.
With its amazing technologies to identify and detect UI elements in Windows applications, it's a software that I really enjoy using.
And because of its immense benefit it's also definitely worth the price.

The basic concept is that you create tests that contain chained **modules**, which are executed in a sequence one after one.


<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/ranorex-testrail/ranorex-1.png" loading="lazy" alt="">
    </div>
</div>


The modules contain different **actions and validations** that can either be added manually or by simply **recording** it while clicking around in your application.

To improve maintainability and add reusability, all the found elements in your application are stored in an **object repository**.
These elements can simply be used by your actions.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/ranorex-testrail/ranorex-2.png" loading="lazy" alt="">
    </div>
</div>



The final result is that you end up with multiple layers to improve the quality of your test suite.
Build and reuse modules, or simply fix and improve the XPath of an element that is used across hundreds of tests.
I think you get the idea ;)

When you start your tests in Ranorex, it will automatically run every test, which means all modules are executed in order,
until every selected test has been run.

Afterwards you see a nice **report** that you can use to fix your application.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/ranorex-testrail/ranorex-report.png" loading="lazy" alt="">
    </div>
</div>

# Ranorex TestRail Integration

Ranorex comes with a built-in TestRail integration.
It works great, but unfortunately there is a 2-way-sync implemented.
This means that TestRail suddenly has unplanned new test cases that might have been created in Ranorex.
Also every new run in Ranorex creates a new test run in TestRail.

This is not wrong, but might just not be what you need in your project.

Also, with this built-in integration, it's not completely possible to add a Ranorex project to an existing TestRail projects in a decoupled way.

> My goal was to use any automation framework for existing TestRail tests and just send the results back to TestRail.

This is why I've created a separate <a target="_blank" href="https://github.com/boxblinkracer/ranorex-testrail">integration for Ranorex and TestRail</a>.

You just need to configure it in your setup routine and provide your **TestRail credentials**.
Then set the **run ID** that you want to fire against.
And when it comes to your test cases (yes they need to be mapped), just use a provided **module in a teardown** of a single test
and let TestRail know what **Test Case ID** this test is for.


<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/ranorex-testrail/ranorex-integration.png" loading="lazy" alt="">
    </div>
</div>

That is everything, easy right?!
Let's check it out together.

If you use something else than Ranorex, just look at my Github page.
I do have <a target="_blank" href="https://github.com/boxblinkracer?tab=repositories">more integrations</a> available.

# Use the Ranorex TestRail Integration

## 1. Installation

Open your Ranorex project, right click on your solution and click Manage Packages.
Now search `boxblinkracer.Ranorex.TestRail` in the NuGet package manager and add it to your project.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/ranorex-testrail/ranorex-nuget.png" loading="lazy" alt="">
    </div>
</div>

## 2. Setup TestRail credentials

Create a new SETUP section for your TestSuite and drag the **TestRailSetup action** into it.
Right click on it and open the Data Bindings dialog.
Now use "Auto-create", followed by "Auto-bind" to create the parameters.

It's time to enter your **credentials**:

* TestRailURL: Your TestRail URL, e.g. "https://mycompany.testrail.io"
* TestRailUsername: Your TestRail username
* TestRailPassword: Your TestRail password
* TestRailTestRunID: The prepared Test Run in TestRail that you want to send results to, e.g. "R30"

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/ranorex-testrail/ranorex-setup.png" loading="lazy" alt="">
    </div>
</div>

## 3. Add TestRailResult Action

Alright, we're actually done. All we need to do now, is to decide what Ranorex tests are ready to work with TestRail.
Drag the **TestRailResult action** to your tests. I would recommend using it as last action in the TEARDOWN section of a test.
Right click on it and open the Data Bindings dialog.

Now use "Auto-create", followed by "Auto-bind" to create the parameters.
Enter the Test Case ID of a TestRail test that you want to verify with the currently selected Ranorex Test. Please keep in mind that this is a Test Case ID, like "C1", "C335".

This is completely decoupled from an actual Test Run. So we can really maintain our basic test setups in here.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/ranorex-testrail/ranorex-mapping.png" loading="lazy" alt="">
    </div>
</div>

## 4. Start Ranorex Tests

Start the Ranorex Test Suite and wait until your tests are finished. The Ranorex Report will show detailed logs about the TestRail integration for every single test.

# It's a wrap

I hope this article helps you to improve your TestRail and Ranorex experience.
If you have questions, ideas or feedback, just let me know.

Here is the Github URL for the integration:  <a target="_blank" href="https://github.com/boxblinkracer/ranorex-testrail">https://github.com/boxblinkracer/ranorex-testrail</a>
