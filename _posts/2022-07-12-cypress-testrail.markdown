---
layout: post
title:  Automate your tests with Cypress and TestRail
description: Increase test management efficiency by sending testing results from Cypress to TestRail.
date:   2022-08-03 20:00:00 +0300
image:  '/images/blog/cypress-testrail/header.png'
tags:   [qa, test-automation]
---


---

I'm a big fan of automation in general. May it be for development, deployments or even testing.
It is indeed a possible solution for many cases, but when it comes to testing, please keep the following in mind:

> Automation is not the solution to increase quality, but it's a great help to save time and reduce effort.

When we talk about testing automation, some people focus on scaling up their tests to be fully automated and try to get rid of manual work, while
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
So I've created a custom **integration for Cypress** and TestRail to do this.

This article focuses on explaining you this approach, the benefits and how to install and configure the integration.

But let's first start with the involved parties!

# TestRail

TestRail (<a target="_blank" href="https://www.gurock.com/testrail">https://www.gurock.com/testrail</a>) is one of the available test management applications out there.
I like it because of its **efficient** look and feel, its **features** and the available **API** that lets you really get the most out of your processes and integrations.

The basic concept is that you create **test cases** in your projects.
Test cases are the list of available things to test in a project.
These test cases can be structured with **sections** so that you have a better overview.
Every test case has different properties such as **type**, **automation type**, **reference IDs** and more to allow you even more by filtering for what you need.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/cypress-testrail/testrail-cases.png" loading="lazy" alt="">
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
        <img src="/images/blog/cypress-testrail/testrail-plan.png" loading="lazy" alt="">
    </div>
</div>


When testing starts, I can just open a test run, read the instructions and add a new result, such as passed, failed, and more.
Depending on your defect management, you can then proceed by pushing defects to Jira for instance. But this is a totally different story.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/cypress-testrail/testrail-result.png" loading="lazy" alt="">
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

And especially when it comes to testing web applications, there is just no way around Cypress.

# Cypress

Cypress (<a target="_blank" href="https://www.cypress.io">https://www.cypress.io</a>) is a **test automation framework** for simply anything that runs in a browser.
One of the best things next to its stability is the built-in UI view, where you can watch and debug all your tests. This is just brilliant!

And unbelievable, but it's Open source and therefore free.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/cypress-testrail/cypress-tests.png" loading="lazy" alt="">
    </div>
</div>

The basic concept is that you create tests based on **Javascript**.

Cypress offers lots of commands and even built-in `waits` for those commands and assertions.
That means you can easily access an element, and just use something like `click()` on it. You don't have to wait for the element or do other checks before you can use it.
Easy and simple!

```javascript 
it('buttons should work correctly', () => {
    // get element and just click on it
    cy.get('.my-button-1').click();
    // get 2nd element and hover it
    cy.get('.my-button-2').trigger('mouseover');
})
```

You can then start your tests either in this UI view, or directly with the `run` command as CLI option.
After your tests have been executed, you see a nice report and overview about your results.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/cypress-testrail/cypress-report.png" loading="lazy" alt="">
    </div>
</div>


# Cypress TestRail Integration

To integrate Cypress with TestRail you need to add a plugin or module to your Cypress project.
That plugin should then communicate with the API of TestRail and **send the results from Cypress to TestRail**.

And because I love to develop things, I did such an <a target="_blank" href="https://github.com/boxblinkracer/cypress-testrail">integration</a> for you.

You just need to install it and configure your **TestRail credentials** in your Cypress.env.json file.
Then set the **run ID** that you want to fire against.
And when it comes to your test cases (yes they need to be mapped), just add the TestRail **Case ID** to your tests.

That is everything, easy right?!
Let's check it out together.

If you use something else than Cypress, just look at my Github page.
I do have <a target="_blank" href="https://github.com/boxblinkracer?tab=repositories">more integrations</a> available.

# Use the Cypress TestRail Integration

## 1. Installation

The integration is just a simple NPM package.
Just run this command to install it.

```bash 
npm i cypress-testrail --save-dev
```

## 2. Setup TestRail credentials

Now configure your credentials for the TestRail API. Just add this snippet in your `Cypress.env.json` file and adjust the values.

Please keep in mind, the **runId** is always the test run, that you want to send the results to. You can find the ID inside the test run in TestRail.
It usually starts with an R, like "R68".

```json 
{
  "testrail": {
    "domain": "my-company.testrail.io",
    "username": "myUser",
    "password": "myPwd",
    "runId": "45"
  }
}
```

## 3. Register Plugin

Just place this line in your `support/index.js` file. There's nothing more that is required to register the TestRail reporter.

```bash 
import 'cypress-testrail';
```

## 4. Map Test Cases

We're almost done. You can now map TestRail test cases to your Cypress tests.

Please use the TestRail **Case ID** as a **prefix** inside the Cypress test title.
The plugin will automatically extract it, and send the results to your test run in TestRail.
The case ID needs to be at the beginning and separated with an : from the rest of the title.

```javascript
it('C123: My Test for TestRail XYZ', () => {

    cy.get('#sw-field--name').type('John');
    // ...
    // ...

})
```

## 4. Start cypress Tests

Start the Cypress Test Suite and enjoy watching Cypress sending results directly to TestRail while the tests run.

# It's a wrap

I hope this article helps you to improve your TestRail and Cypress experience.
If you have questions, ideas or feedback, just let me know.

Here is the Github URL for the integration:  <a target="_blank" href="https://github.com/boxblinkracer/cypress-testrail">https://github.com/boxblinkracer/cypress-testrail</a>
