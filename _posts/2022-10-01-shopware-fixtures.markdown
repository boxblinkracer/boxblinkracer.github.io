---
layout: post
title:  Improve your Shopware 6 experience with Fixtures
description: Improving development and testing experiences with fixtures in your Shopware 6 plugin and shop.
date:   2022-10-03 15:00:00 +0300
image:  '/images/blog/shopware-fixtures/header.png'
tags:   [shopware, dev, qa, test-automation, mollie]
---

---

Building projects with Shopware is great. Still, with every project and plugin, you'll face the same familiar things to conquer.

One of them is the basic question, **where to store the database**, that is required for your developers?
This database should obviously **simulate your client project** as good as possible for development purposes.

But also as plugin manufacturer! Haven't you already thought about, how annoying it is, to always configure your plugin, before
you can actually continue improving it?

If so, then lucky you! There's a solution, and it's called Fixtures!

# What are Fixtures?

The purpose of testing fixtures is, to ensure you have a **fixed and well known prepared environment**.
This helps your tests to be run smoothly, and that you can rely on the data that exists.
And yes, this is also known as the test context, that you may have heard of.

This rough wording also means, fixtures could be created in every programming language for almost every use case.
In the end, there's nothing really complex when it comes to building them.
It's actually just a definition of how the data source is defined (JSON, XML, PHP objects, ...) and how they will be inserted into your database, environment or whatever it will cover.

Most of the frameworks already have some great options to create data, such as the <a target="_blank" rel="noopener nofollow noreferrer" href="https://developer.shopware.com/docs/concepts/framework/data-abstraction-layer">DAL in Shopware 6</a>.

But why do things like FixturesBundle then exist? Why is this necessary, if the basic creation of the data would already be possible?
Simply, because you need some kind of entrypoint that collects your fixtures, converts them from the data source format into the required one, and starts the actual execution.

I think, a lot of us Shopware agencies build this on their own, over and over again.

While building <a href="dockware.io" target="_blank" rel="noopener nofollow noreferrer">dockware.io</a> in our company, and making it public, we've realized, that sometimes it's just better
to share projects and use the **help of the full community** to improve and extend them with more options and features.

So, why not also the fixtures?

# FixturesPlugin (by basecom)

When I was invited to speak at the <a target="_blank" rel="nofollow noreferrer noopener" href="https://www.meetup.com/sfugos/events/283236122">Symfony User Group Osnabrück #18</a>, hosted by <a target="_blank" rel="nofollow noreferrer noopener" href="https://www.basecom.de">basecom</a>,
I learned, that they already use fixtures in a very good way.
That was indeed a great foundation for what I was looking for, to improve our internal processes at <a target="_blank" rel="nofollow noreferrer noopener" href="https://www.dasistweb.de">dasistweb GmbH</a>, and in general.

Basecom was luckily willing to share their plugin as **Open Source project** for the whole community.
A great move, **thank you for this**!

But what is the good thing about it? You can already build your custom DAL integrations on your own, right?
Yes, but the plugin handles the easy execution of your fixtures with some nice options!

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-fixtures/fixturesplugin.png" loading="lazy" alt="">
    </div>
</div>

While **priorities** and **dependencies** between your fixtures help you to get the correct **execution order**,
**groups** help you to separate and split your fixtures into different topics, that could be used on demand.

Along with this, we've improved some **helper features** to easily access typical data, like default taxes, or even upload product images from your fixtures folder.

The next chapters will show you different use cases in Shopware 6.
They will use the FixturesPlugin, so if you want to download it, here's the link: <a target="_blank" rel="nofollower noopener noreferrer" href="https://github.com/basecom/FixturesPlugin">https://github.com/basecom/FixturesPlugin</a>.

# Creating Fixtures

Let's see how a fixture can be created.

Please keep in mind, there are some examples in the plugin repository, and also, in the end, it's just plain coding with DAL, SystemConfigService and more.

We have a fixture class `SubscriptionProducts` to create products, that are configured to be subscription products.
If we don't use auto wiring, then we have to register our fixture with the `basecom.fixture` tag.

```xml 
<service id="MyShop\Fixtures\Product\SubscriptionProducts">
    <argument type="service" id="Basecom\FixturePlugin\FixtureHelper"/>
    <argument type="service" id="product.repository"/>
    <tag name="basecom.fixture"/>
</service>
```

Now let's look at the actual implementation.

Please note, I've removed a couple of DAL lines to make it shorter. The minimum mandatory fields for an `upsert` are a bit more...

The basic concept is very easy. We use custom static UUIDs for our entities and either create or update them with an `upsert` statement.
We can of course also update existing IDs (if always existing), or dynamically iterate through a list of existing entities (e.g. assign all existing payment methods to all existing sales channels).

```php 
# your unique static ID for this fixture product
private static string PRODUCT_A_ID = 'b2492f53b1b84a82a70494270f2e9b1d';

public function load(FixtureBag $bag): void
{
    $storefrontID = $this->helper->SalesChannel()->getStorefrontSalesChannel()->getId();
    $defaultTaxID = $this->helper->SalesChannel()->getTax19()->getId();
    $categoryClothingID = $this->helper->Category()->getByName('Clothing')->getId();
    
    $this->repoProducts->upsert([
        [
            'id' => self::PRODUCT_A_ID,
            'name' => 'Product A',
            'taxId' => $defaultTaxID,
            'visibilities' => [
                [
                    # any unique, static ID for the relation entity
                    'id' => 'b6422f53b1b84a82a70494270f2e9b1d', 
                    'salesChannelId' => $storefrontID,
                    'visibility' => 30,
                ]
            ],
            'categories' => [
                [
                    'id' => $categoryClothingID,
                ]
            ],
            'stock' => 99,
            'customFields' => [...],
            ...
            ...
        ]
    ],
        Context::createDefaultContext()
    );
}
```

If you now run this command in your CLI, your new "Product A" is automatically created (or updated) and assigned to the category "Clothing".

```bash 
php bin/console fixture:load
```

# Real World Scenarios

Now that you know how to create fixtures, it's time to figure out, what we can do with it in our **real world scenarios**.

Depending on what you develop, or what your role is in your company, you might have different requirements and approaches.

Here is a list of typical scenarios that I faced in my experience.

## Full Shop

When you develop full shops, there are 2 options in most cases.
Either go with a database dump for development, or build full fixtures from the ground up.

The latter one might already be the hardest one to achieve!
Why? Because it requires additional effort to build good fixtures for your developers.

But once you have it, it's pure power!

> Being independent of an actual database dump can be super powerful

Blazing fast PHP-based imports, and no need to access a database dump from
a system or another developer. Just pure PHP! And if you know dockware, just think about how cool it is, to launch a dockware container in a CI pipeline, load your fixtures and start your Cypress tests, even before your pull request is merged!

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-fixtures/pr-pipeline.png" loading="lazy" alt="">
    </div>
</div>

And if you one day figure out a new edge case with a specific product, just build it in your fixtures and everyone benefits from it.

The only tradeoff you have to live with, is, that it's not possible to get a real 1:1 version of your Shopware shop.

You can build your shopping experiences as fixtures, but probably not all! You might not have completely accurate real world products, and of course no real order data.

But on the other hand, do you really always need that?

I'll let you decide on your own.

## Plugin Development

If you develop a plugin, there are 2 things to think of.

First, get rid of annoying steps in your setup routine. Do everything that is required in an automatic way using fixtures.
And second, think about offering the (developing) customers of your plugin, fixtures to get going even faster.

What does that mean?

As you may know, I'm developing the <a target="_blank" rel="nofollow noopener noreferrer" href="https://github.com/mollie/Shopware6">Mollie payment plugins for Shopware</a>.
The Shopware 6 plugin recently got new fixtures for contributors, as well as for agencies, that use the plugin.

### Contribution Fixtures (Plugin)

I'm always interested in improving the developer experience and setup routines.
For me, it's very important to get rid of repeating and annoying tasks, while still keeping the transparency.

The Mollie plugin contains **2 groups of fixtures**, that can either be run separately, or all in one (full plugin fixtures).

The **mollie-setup** group automatically activates all Mollie payment methods and assigns it to the Sales Channel.
It also makes sure to enable the **Test Mode** automatically for you.

After running the following command, you can already start to test a checkout in your shop. Nothing more to do.
Mhm...yeah..you have to set an API key, but luckily, there's a CLI command for that in Shopware ;).

```bash 
php bin/console fixture:load:group mollie-setup
php bin/console system:config:set MolliePayments.config.testApiKey test_123456789
```

The second fixture group is the **mollie-demodata** group.
As the name implies, this one is all about **prepared demo data** that you usually need for different use cases in Mollie.

It will create subscription products, voucher products and more. All with nice description, prices and even cover images.
They will all be assigned to separate categories, so that you can immediately start testing, instead of configuring products first.

```bash 
php bin/console fixture:load:group mollie-demodata
```

If you want to run all fixture groups, you can also run this command instead:

```bash 
php bin/console fixture:load:group mollie
```

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-fixtures/mollie-fixtures.png" loading="lazy" alt="">
    </div>
</div>

### Agency Fixtures (Plugin)

Besides improving my own experience as a contributing developer, there's also another perspective to think of. Agencies!
And Mollie already has an answer for this too, and yes, you did already read it.

The reason why the fixtures are split into 2 groups, is, because as an agency, you can simply use **mollie-setup** fixtures.

This will make sure you don't have to **manually activate and assign payment methods**, while still **avoiding demo products** to be installed.
You can stick to your own shop catalogue, and still enjoy a smooth setup routine.

## QA Fixtures

The last, but not the least important topic is QA.
This approach really depends on your workflow and current process when testing.

I personally separate it into 2 different options.
You either use **only your fixtures for testing**, or you usually **test in a (changing) environment** with imported database dumps.

Here is how to handle both of them.

## Testing with Fixtures (QA)

This is probably the easiest process, because you may already have what you need.

If you develop a full shop, or even plugin, you already have your (demo) data in the **development fixtures**.
Simply load these into your testing environment, and you're good to go.

In addition to this, you can also add additional groups like **qa**, **test**, **stage** or more, to add separate fixtures that are **specific
to testers or a certain environment**.

## Testing with DB dump (QA)

If you have a testing **environment with a real (changing) backup database** of your client shop, then you may not be able to fully load your fixtures into this environment.
With this approach, you clearly want to verify and validate features in the "real" shop of your client.

But do we still need fixtures? Yes, maybe.

In my experience, depending on the quality of the database dumps, it happens from time to time, that things are just annoying or not possible to test.
If you have a database where (somehow) only a few products can be purchased, because they are usually out of stock, then simply use a fixture
to **update all products to a stock of 99**. Then you don't have to search for a product that can be purchased.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-fixtures/product-stock.png" loading="lazy" alt="">
    </div>
</div>

Or in the Mollie plugin for example, I have lots of Cypress tests.
And somehow I didn't want to build all these testing fixtures in Cypress. I just wanted to use the demo data of Shopware, or in other words -> just use any products that exist.

This means, that e.g. for the "subscription" tests, I have to update all products to be a subscription product.
And yes, this clearly destroys my prepared QA environment. I was always annoyed when I started with manual testing.

The solution with fixtures is quite easy now. I have a "base" product fixture that **removes all Mollie product settings** by cleaning the custom fields of all products first,
and then it **only sets the subscription properties** for products that I really want to be subscription products.

Automate the fixture loading in your CI/CD pipeline, and you will never be annoyed again.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-fixtures/mollie-properties.png" loading="lazy" alt="">
    </div>
</div>

# It's a wrap

I really hope this article makes you want to use fixtures in your projects.

Although it's an additional effort, and also has to be planned with a strategic concept,
it's such an amazing thing for so many use cases and really takes away the pain, that we certainly all know somehow.

## Where to go from here?!

If you have managed to create fixtures, check out these steps to move your process even further:

* Run any Shopware 6 with <a target="_blank" rel="noopener nofollower noreferrer" href="https://www.dockware.io">dockware.io</a> and apply your fixtures there.
* Add Cypress tests to your shop and run it with dockware in a CI pipeline: <a href="/blog/cypress-shopware-mollie">Read now</a>
* Send your Cypress results to your TestRail Test Management software for better QA plans and reports: <a href="/blog/cypress-testrail">Read now</a>
