---
layout: post
title:  Automate E2E Tests with Cypress, Shopware and Mollie
description: Ever wanted to do real world payment and checkout E2E tests in an e-commerce system! This tutorial is made for you!
date:   2021-04-08 20:00:00 +0300
image:  '/images/blog/cypress-shopware-mollie/header.png'
tags:   [qa, test-automation, shopware, payment, Mollie]
---


---

Have you ever been struggling with fully automating E2E tests for you whole Shopware shop? Also with a full checkout that even includes the integration of your payment service provider? Then this article is your solution!

Testing is one of the most important things when it comes to a successful delivery of your product. But the more tests you have, the more time it takes to fully verify your whole test suite before every single release.

Great thing, that there are frameworks to **automate** these steps for you!

We do quite a lot of testing and quality assurance when it comes to development of Shopware shops here at dasistweb GmbH (www.dasistweb.de). Starting from basic **Unit Tests** up to **Integration Tests** and even **E2E based** testing in our QA department.

Having the later one automated is a must have if you want to scale and improve your processes even more!

This works pretty good, but as soon as you want to test a **complete checkout** you might see different limitations like stability issues, "cross-origin" problems or just the ability to do that type of testing with your payment service provider.

So how can you archieve this? What are we going to learn in this article??

> We will create an automated checkout process, where we select a payment method, continue to the payment providers sandbox page, and trigger an expected payment status for our order.

<div class="gallery-box">
  <div class="gallery">
    <img src="/images/blog/cypress-shopware-mollie/cypress.gif" loading="lazy" alt="">
  </div>
 </div>


Sounds interesting? Great, let's start with the tools you need.

# Cypress
While there are lots of E2E testing frameworks available, we recently decided on using **Cypress** (www.cypress.io) for our web projects. It comes without the need of a separate Selenium instance, and with some pretty amazing tools like the GUI interface, that allows you to visually see what you are creating. And it also runs great in a CI pipe, which is absolutely important nowadays.

Still, like with any other scripted tests, it's indeed an **art to craft sustainable test cases**. This article will assume that you understand the basics of design patterns for testing. If you want to learn more about it, please check out this guide about <a href="/blog/e2e-design-patterns">Design Patterns for sustainable automatic E2E Tests</a>.

Writing tests in Cypress is really easy! But when it comes to do a complete checkout, things start to get tricky! Did you ever need to fake an order or payment itself? Did you ever have the „cross-origin" problem in Cypress?

To tackle these obstacles, you need indeed a **great payment provider**, who gives you such possibilities!

# Mollie
Mollie is a rising star when it comes to payment. Awesome experience, great features and overwhelming API. But long story short, what they offer is something very unique. It's a **sandbox payment page** that allows you to decide, if your payment was successful, if it failed, has been cancelled and more. No fake credit cards for specific target states - just simple radio buttons!

And as you can imagine, this is amazing for automated E2E tests!

Let's start with a hypothetical (or real) Shopware shop running along with our installed Mollie payment plugin and an enabled **test mode**.

Our Cypress project is configured, and we also have some actions that lead us through the checkout. Please note, these actions are pretty self explaining and I will assume, that you are able to write those for your click routes!

# Let's Code our Test
When writing a test for Mollie (or in general) there are 3 obstacles that we need to tackle:
* Domain "localhost" is not allowed by Mollie!
* Cross-Origin problem of Cypress.
* SameSite Cookie Policy makes troubles.
  * Update July 12th 2021: additional SameSite "Lax" configuration is now required as described later in this article.
  * Update Sept. 8th 2021: now Shopware changed to "Lax" with Shopware 6.4.4, so there's also a guide on that later in this article.

Solving these problems is actually pretty easy.
Though I will explain 2 of 3 **later in this article**, so that we can continue with our flow and test story.

Still, to be able to at least start developing our test in Cypress, we would need to solve the **first obstacle** "localhost". We need to ensure that our (local) Shopware shop is available with something else than https://localhost.
If you are running against an online server, this is not interesting for you!

A solution would be to use the /etc/hosts file to add a new entry and configure a custom domain. So modify this file and add this to tell our host that the custom domain "local.shopware.shop" just points to our "localhost".

```bash
127.0.0.1      local.shopware.shop
```

Afterwards, please don't forget to update the host/domain of your shop or sales channel in Shopware.

Please use **HTTPS** for this, otherwise the LAX Cookie policy and our workaround for this might not work. This would lead to a new session with an empty cart when coming back from Mollie (starting with Shopware 6.4.4.0).

Once configured, we can add our custom domain as **Base URL** in Cypress.

We can now finally start to write our test scenario.
This will be done by some simple action-driven steps that lead us to our checkout confirm page where we head over to the Mollie sandbox page.

The first steps are to visit the shop, start a login for our user, navigate to the clothing category, click on the first product and add it to our cart by using the button on the product detail page.

```javascript
cy.visit('/');

login.doLogin('xxx', 'yyy');

topMenu.clickOnClothing();

listing.clickOnFirstProduct();

pdp.addToCart();
```

Adding the product will automatically open the "off-canvas cart" that we use to navigate to the cart itself.

```javascript
checkout.goToCheckoutInOffCanvas();
```

Once landed on our confirm page, we have to select the payment method we want for this test. We just use Mollie PayPal for this. Our action offers an argument, so we can easily define, what payment method to select and use.

```javascript
checkout.switchPaymentMethod('PayPal');
```

Afterwards, we simply place our final order in Shopware by accepting the terms and click on "Send Order".

```javascript
checkout.placeOrderOnConfirm();
```

All pretty simple so far right?!

The last step should bring us to the **Mollie Sandbox page**. This is the first time where your test would break due to the cross-origin problem that we configure later on.

Besides that, being on the Mollie page is a perfect point for our **first assertion**. We verify that we are [a] on the Mollie payment screen, and [b] that we see our payment identifier in the URL.
This is our indicator that the payment selection did indeed work.
We use **2 separate assertions**, because the URL pattern is different for some payment methods. A few of them require selecting an issuer first, such as iDEAL or KBC/CBC, and others bring you directly to the final sandbox page.

```javascript
cy.url().should('include', 'https://www.mollie.com/checkout/test-mode/');
cy.url().should('include', 'paypal');
```

After verifying this, we can continue with our checkout.
Depending on what payment method we use, we either have to select an **issuer** first, or directly select any of the available **payment status** options for this method ("paid" in case of PayPal).

```javascript
if (currentPayment === 'ideal') {
    molliePayment.selectIDEAL();
} else if (currentPayment === 'kbc') {
    molliePayment.selectKBC();
}
if (currentPayment === 'klarnapaylater') {
    molliePayment.selectAuthorized();
} else {
    molliePayment.selectPaid();
}
```

If you now get an **error** when submitting the form using the button in the sandbox page, then it's because of the **missing cookie configuration** in our Cypress project (3rd obstacle!).

But once that has been configured, Mollie redirects us back to Shopware, where we can test, that we land on our **success page**. You can of course also verify data consistency of your order in any preferred way, but I'll leave that up to you.

```javascript
cy.url().should('include', '/checkout/finish');
cy.contains('Vielen Dank für Ihre Bestellung');
```

And that's it!
We have **successfully** executed a **full automated checkout** with Shopware, Mollie and an expected payment status.

Now just think about iterating through a list of payment methods…or even testing, that a failed payment brings you back to the cart with an error, while all your products are still existing in your cart…

In fact, the Mollie plugin itself tests all these (>10) payment methods on different viewports in just a few minutes without any required interaction.

If you want to see the full code, you can access it at https://github.com/mollie/Shopware


# Solving our Obstacles
Let's find out how to solve our problems with Cypress visiting and working with external domains in a single test!


## Cross Origin Domain
By default it's not allowed to visit different domains in a single test. This leads to the problem that we can't visit the Mollie sandbox page. Instead of this, we get a cross-origin exception.

While it's often a better approach to use fakes, mocks and stubs, we rely on visiting the **real Mollie page** in that case. Mollie does not provide an API that we can call to change the payment states. Theres "only" the test mode checkout page! And on the other hand, we want a real E2E test anyway!"

If you want to force Cypress to visit a different domain, then it's possible by turning **off**the **Chrome Web Security**. This somehow didn't work in earlier versions, but with Cypress 6.8, I can confirm it really works.

It might not work for all browsers, but a few is better than none for these tests. And it also works in the Electron browser, which is the default in CLI runs. So all good.

Just use this in your Cypress JSON configuration:

```json
{
    "chromeWebSecurity": false
}
```

## Cookie Policy
The last step is to **disable** the **SameSite Cookie Policy**.

If you can remember, there was an error when submitting the form on the Mollie sandbox page!

The reason is, that this form requires some cookie/session values to exist, which are prevented by default in Cypress (or the browser) due to the SameSite policy. But this can be turned off easily!
Please also note, that it's not working on every browser, but hey…again Chrome and Electron work like a charm ;)

Modify your export in your **plugins/index.js** file and add a **browser launch event**, that turns off the policy.

```javascript
module.exports = (on, config) => {
  on('before:browser:launch', (browser = {}, launchOptions) => {
    if (browser.name === 'chrome' || browser.name === 'edge') {
        launchOptions.args.push('--disable-features=SameSiteByDefaultCookies')
        return launchOptions
    }
  })
}
```

**Mollie SameSite LAX (Update July 12h 2021)**
Mollie changed their cookies to use "Lax" for SameSite on July 2nd 2021.
This will probably break your tests, even though the configuration from above has been applied. That leads to a problem when submitting your expected payment status on the Mollie Sandbox page. It shows "**The form has expired**", because the form cannot be posted without a **SESSIONID** cookie for the Mollie domain.

The good thing is, the solution is really easy, although it took me a while:).

The required **SESSIONID** cookie can be created anywhere in your tests. Please keep in mind, if you somewhere reset your session and cookies, it might be gone. For me it works best, when initializing that cookie **directly on the sandbox page** (don't forget to reload the page to have that cookie activated).

But it's not only about creating the cookie, we also change its "SameSite" property to be "**None**" instead of "Lax". With this, Cypress can access that cookie again and the interaction with the Mollie sandbox page should work like before.

Here's a helper function that you can call when you are on the Mollie Sandbox page:

```javascript
initSandboxCookie() {

    cy.setCookie(
        'SESSIONID',
        "cypress-dummy-value",
        {
            domain: '.www.mollie.com',
            sameSite: 'None',
            secure: true,
            httpOnly: true
        }
    );
    // reload current page to activate cookie
    cy.reload();
}
```

**Shopware SameSite LAX (Update Sep 8th 2021)**
After Mollie, Shopware did also switch over to LAX cookies starting with Shopware 6.4.4.0.

If we do not create a workaround for this, then it would lead to an **empty cart** when coming back from the external Mollie domain. That means, we cannot assert any successful checkout anymore.

It took me a while, but the solution is also very easy in this case.
We simply **hijack and modify the "session-" cookie** of Shopware before leaving our shop domain. This means we fetch all cookies using a Cypress request call, extract the value of our "session-" cookie, and save it with our **SameSite "None"** policy, so that we still have it, when coming back later on.

> One important thing to consider!
> You need to use HTTPS to have it working. HTTP will not work!

Here is a short helper function, that you can use for the "session-" cookie before placing the order in Shopware which will then redirect you to Mollie.

```javascript
// ...
prepareCrossDomainCookie('session-');
checkout.placeOrderInShopware();
// ....
```

Snippet:

```javascript
prepareCrossDomainCookie(name) {
    cy.request({url: '/'}).then((res) => {
        const cookies = res.requestHeaders.cookie.split(/; */);
        cookies.forEach(cookie => {
            const parts = cookie.split('=');
            const key = parts[0]
            const value = parts[1];
    
            if (key === name) {
                  cy.setCookie(
                      name,
                      value, 
                      {
                         sameSite: 'None',
                         secure: true
                      }
                  );
            }
        });
    });
}
```


# CI Pipelines
Now that our tests are finally working, what if we want integrate those in a CI pipeline?

Depending on your setup, you could either run Cypress in a CI/CD tool like **Buddy** (https://buddy.work) and then test your shop on your server, or use it in a platform like Github and be able to automatically run the tests.

I will show you the CI option with Github Actions today! Please keep in mind, that I cannot learn you **Github actions** in general here, so we just assume that you already have a few steps in your existing pipeline. But what is probably missing is, when it comes to Cypress.

If we want to run tests against a Shopware shop in Github, then we obviously need a **running instance of a shop**, technically done by using a Docker container.

I would recommend **dockware** (https://dockware.io), which allows you to easily launch any Shopware 6 shop and even a handful of Shopware 5 shops wihout anything to do on your side. This includes a full setup including configuration, demo data, and more…so pretty much perfect for our case!

> Please note, this sample uses Shopware 5, but it also works great in Shopware 6 or any other version!

We start dockware/play:5.6.9 (non-dev) with a simple "docker run" that uses our HTTPS port 443, and give it a few seconds to launch. That sets up a shop that we can access from Cypress in the upcoming actions using the domain "https://localhost".

```yaml
- name: Setup Docker
  run: |
    docker run --rm -p 443:443 --name shop -d dockware/play:5.6.9
    sleep 30
```

But can you remember our problem with Mollie and "localhost"?
Good thing, we already know the solution! This also works great on Github! So let's add a custom domain entry.

```yaml
- name: Setup Docker
  run: |
    docker run --rm -p 443:443 --name shop -d dockware/5.6.9
    sleep 30
    sudo echo "127.0.0.1 local.shopware.shop" | sudo tee -a /etc/hosts
    docker exec shop bash -c "mysql -u root -pxxx shopware -e \"UPDATE s_core_shops SET host = 'local.shopware.shop', hosts = '';\""
```

After that you can simply use " https://local.shopware.shop" for your tests in Github.

And now just imagine you use a matrix setup to run your tests across different versions of Shopware?! Doesn't that sound exciting?

```yaml
strategy:      
matrix:        
shopware: [ '5.7.6', '5.6.8', '5.6.9' ]
steps
- name: Setup Docker
  run: |
    docker run --rm -p 443:443 --name shop -d dockware/play:${{ matrix.shopware }}
    ...
```

# It's wrap!
It might seem like a lot to consider, but these are only a few pretty straightforward things, that you need to take care of, when running your tests.

And hey, you now have the skills to run **full checkout tests** with Mollie in your Shopware shop. Either locally, or even in a **CI pipeline** using dockware and custom domains. 

Last but not least, a special shoutout to **Tim from Mollie** who helped a lot in figuring out how we can work with the Sandbox page! Thanks dude!

