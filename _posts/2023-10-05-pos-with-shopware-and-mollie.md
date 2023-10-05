---
layout: post
title: Point-of-Sale with Shopware and Mollie
description: In-person payments with Mollie terminals and your Shopware 6 shop
date: 2023-10-4 10:00:00 +0300
image: '/images/blog/mollie-pos/header.png'
tags: [ shopware, dev, mollie ]
---


---




Online shops, marketplaces, and digital shopping experiences have become ubiquitous in our modern era. It's indeed an exciting time we live in, where each day brings us closer to a bright and shiny digital replica of the real world. Our entire community, including agencies, platforms, and more, is dedicated to providing the best experiences and integrating the latest technologies, such as AI, and more into our lives.

However, amidst this digital transformation, there's a **world beyond our screens** — a world where you can walk into **physical stores**, touch products, and make immediate purchases, experiencing the delightful satisfaction of holding something new and remarkable in your hands. This tangible world coexists with our digital lives, and the transactions that occur here include transactions based on **physical credit cards** or convenient **wallet payment methods** like Apple Pay or Google Pay.

These **point-of-sale systems** enable seamless transactions within retail stores. Unfortunately, the integration of these systems with existing solutions, such as a merchant's online shop, may **not always be optimal**, or in some cases, **not even feasible**.

Have you ever considered offering your local store's customers the ability to view their purchases in their online accounts or facilitating refunds for offline purchases through a simple phone call or email? Perhaps not, because sometimes, due to limitations, it's just **not possible**.

## Mollie Terminals

Mollie, a leading European payment provider, is renowned for offering a wide array of payment methods, complemented by user-friendly APIs designed for developers. Through collaborations with various integration partners, Mollie has efficiently expanded its presence in diverse markets and platforms, including the Shopware ecosystem.

However, until this year, Mollie did not support **in-person payments**. In 2023, Mollie has taken a significant step by introducing its point-of-sale (POS) system, complete with brand-new terminals tailored for merchants.

With the use of these intelligent and secure terminals, businesses can provide customers with a seamless in-person payment experience. This offering is characterized by effortless setup, expert support, and the ability to unify all online and in-person payments through a single integration. Regardless of whether you make a purchase through Mollie online or in-person using the terminals, you will always have access to features such as reconciliation, returns, and other financial processes through the user-friendly Mollie Dashboard. This marks a substantial advancement in achieving an omnichannel solution with Mollie.

To obtain these terminals, simply get in touch with your Mollie account manager and sales team. All terminals will be shipped pre-configured, ensuring that you can swiftly initiate your first payment with minimal setup time.

Equipped with scanners, a printer card slot, and NFC capability, this Android-based device offers a straightforward onboarding experience. Your primary task is likely to be as simple as connecting the terminal to your Wi-Fi network, and you're good to go.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/mollie-pos/terminal.svg" loading="lazy" alt="" >
    </div>
</div>

## Shopware 6 and POS

Starting from version 4.2.0, the official **Mollie Shopware 6 plugin** offers seamless integration with the Mollie POS system and terminals. This exciting development allows you to leverage your Shopware 6 online shop for your **brick-and-mortar stores**, consolidating all orders into a **single centralized hub** for your business.

The payment method integration itself functions just like any other payment method within your Shopware 6 setup. This versatility empowers you to tailor and configure your local store experience to align with your unique requirements.

For instance, you have the flexibility to configure a **specific sales channel** for your local store, leverage features like Shopware's **Digital Sales Room**, or even create **kiosk systems** and **self-ordering options**, similar to those found in various fast-food restaurants.

In this walkthrough, we will focus on using a separate sales channel within Shopware to illustrate this integration's seamless implementation.

## Walkthrough

### Step 1: Setup Terminals

We'll initiate the process by ensuring the usability of the received terminals.

To begin, open the **Mollie Dashboard** and navigate to the **settings** section.
In the list of available payment methods, please **enable** the "Point-of-sale" payment method.

Furthermore, you should also notice a dedicated menu item labeled "Terminal" in your **sidebar panel**. This section will present you with a list of available terminals associated with your company.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/mollie-pos/dashboard-terminals.png" loading="lazy" alt="" >
    </div>
</div>

Each terminal is assigned a specific name, which, currently, can only be altered by a Mollie account manager. To distinguish between terminals, you can refer to the serial number located next to the terminal ID. You'll find the hardware serial number on a sticker on the backside of your terminal device.

Now that the software side of the setup is complete, your final task is to ensure that your terminal is properly **connected to your local Wi-Fi network** and has a functioning internet connection. You can easily accomplish this directly on the device.

### Step 2: Setup Shopware 6

Once you've completed the necessary setup in the Mollie system, you can proceed in the Shopware Administration.

If you haven't installed the **Mollie plugin** for Shopware 6 yet, please do so now.
Make sure to read the instructions and **configure it** by adding your API keys in the plugin configuration.

In the general settings of Shopware, **enable** the POS payment method. Afterward, **assign** the payment method to your **sales channel**, just as you would with any other method.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/mollie-pos/admin-payment.png" loading="lazy" alt="" >
    </div>
</div>

With these simple steps, you'll be ready to start receiving payments through your integrated Mollie POS system.

### Step 3: The checkout experience

It's time to start our payment!

When initiating a checkout, you'll now find the POS payment method **listed among the available payment options** on the checkout confirmation page.

Upon selecting it, a **dropdown** will appear, prompting you to choose the specific terminal you wish to use. Terminals may be labeled, for example, as "Cash Desk #1" or "Ground Floor Terminal," depending on your naming convention.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/mollie-pos/shopware-checkout.png" loading="lazy" alt="" >
    </div>
</div>

After confirming your selection and placing the order, you'll be **redirected** to a custom **waiting page**.
Here, you'll receive instructions to proceed with your payment on the chosen terminal.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/mollie-pos/waiting-screen.png" loading="lazy" alt="" >
    </div>
</div>

The selected terminal will **automatically display** the order amount and signal that it's ready to accept a payment.

Once the payment is successfully completed, **Shopware** will **automatically redirect** you to either the success page or a failure page, where you can either celebrate your successful transaction or make another attempt if necessary.

> That's it!
> You now have a fully functional and easily configurable POS system that seamlessly combines in-person and online payments within a single integrated system.

### Step 4: Payment updates

When discussing impending changes that could impact your payment processes, such as transitions, refunds, and beyond, the Mollie terminals boast exceptional integrations that seamlessly fit into existing systems.

Each terminal payment operates with the **same simplicity** as online payments.

Your Shopware shop will consistently **receive webhooks** for payment updates,
granting you the ability to perform refunds and a host of other functionalities.

This makes the Mollie terminals an ideal complement for existing integrations,
offering a wealth of technical opportunities and seamless implementations.

### Step 5: Testing the checkout

A significant advantage of Mollie lies in its remarkably **simplified API**,
facilitating the initiation of payments and management of crucial processes and tasks.

During testing, Mollie provides an **exceptional sandbox system**.
Here, you can effortlessly **simulate** various payment **scenarios**, whether it's a successful payment,
a failed one, a cancellation, or even an expiration. The beauty of this testing environment is that you don't need to supply any special, arcane numbers or complex data.

The ease of testing also extends to the POS system in Shopware 6.
When you activate the plugin's test mode, a single **Test terminal** option appears in the dropdown on the checkout confirmation page.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/mollie-pos/shopware-checkout-test.png" loading="lazy" alt="" >
    </div>
</div>

Simply select this test terminal, proceed with your order, and you'll land on the waiting page within Shopware.

Here, you'll find a **special button** that allows you to specify the payment status for your simulated test payment.
Clicking this button opens a new tab, **redirecting** you to the **Mollie sandbox page**,
where you can select the desired payment status.


<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/mollie-pos/waiting-screen-test.png" loading="lazy" alt="" >
    </div>
</div>


Once you've made your choice on the sandbox page, the **original tab** with the Shopware waiting page will **automatically redirect** you 
and follow the steps as if it was a live payment. 

This means you can thoroughly test POS payments in Shopware 6, replicating the exact behaviour of live transactions, 
all **without** the need for a physical **hardware terminal**.


## Technical Facts

To round up this article, I want to share some technical facts about terminals and integration options.

- You just need to start a payment with the Mollie API by using the method “pointofsale” and providing a terminal ID. And it suddenly pops up on your terminal.
- Terminal payments only work using the Payments API. There’s no option to provider order data so far.
- You can provide a Webhook URL, so Mollie sends the same Webhooks as with classic online payments.
- If you want to implement a kiosk system, then keep in mind that users might not have the option or time for a Shopware account registration or login. In this case you might want to go with a plugin that automatically logs you in, once the session is gone. This helps you to create the expected UX.
- Mollie offers 2 types of terminals. A mobile terminal that you can carry around, as well as one that is integrated into a checkout system or kiosk.

## Conclusion

The new Mollie POS system offers a seamless integration, allowing you to effortlessly incorporate your local retail shops into your automated online business. Through technical integration methods like webhooks and other intelligent mechanisms, the terminals harmoniously blend with your existing payment methods within Shopware 6.

It's time to explore new horizons for your business, unlocking its full potential with the powerful combination of Shopware and Mollie.

Links:

* <a target="_blank" rel="noopener nofollow noreferrer" href="https://store.shopware.com/en/molli20782621168f/mollie-payments-plugin-for-shopware-6.html">Mollie Plugin for Shopware 6</a>
* <a target="_blank" rel="noopener nofollow noreferrer" href="https://www.mollie.com/products/pos-payments">https://www.mollie.com/products/pos-payments</a>
* <a target="_blank" rel="noopener nofollow noreferrer" href="https://www.shopware.com">https://www.shopware.com</a> 
