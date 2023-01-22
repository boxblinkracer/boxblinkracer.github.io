---
layout: post
title:  Managing Translations in Shopware 6 with PHPUnuhi
description: Streamline your translation process and improve accuracy with PHPUnuhi's tools and features for Shopware 6
date:   2023-01-22 10:00:00 +0300
image:  '/images/blog/shopware-phpunuhi/header.png'
tags:   [devops, shopware]
---


---


It's no secret that Shopware has been expanding into new territories for the past few years,
including countries such as the Netherlands, Poland, and the USA.

With this expansion comes the need to **support more languages** when developing plugins and online stores.
Many developers and agencies are likely facing similar challenges, such as **missing translations** and **broken JSON snippets** that are out of sync.
Recently, I found myself in a similar situation and, with some unexpected free time, I decided to create a framework to help us manage translations more effectively.

# What is PHPUnuhi?

PHPUnuhi is a PHP-based framework for **validating and managing translations**.

The name "Unuhi" is derived from the Hawaiian word for "translate" or "translation".

The framework was originally developed as a simple PHP script within the Mollie Payments plugin for Shopware 6 to prevent missing translations.

However, as time went on, it became clear that there was more that could be done to improve the translation process.

That's why I decided to create a separate framework that focuses **exclusively on translations**, while still maintaining a user-friendly interface for developers and users.

One of the key features of PHPUnuhi is that it is platform-independent and can be extended to other platforms beyond Shopware 6.

Before diving into 2 specific use cases within Shopware 6, let me explain the basic concept of PHPUnuhi.

# Storage formats, Exchange formats and Translator services

PHPUnuhi is designed with multiple abstraction layers that enable you to combine various formats and services in a flexible and modular way.

This allows you to create a custom setup tailored to your specific needs.


<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-phpunuhi/patterns.png" loading="lazy" alt="" width="50%">
    </div>
</div>

## Storage formats

Storage formats define how your translations are stored.
This can be a JSON file, INI file, MySQL storage or anything else.
A handful of storage formats already exist in the framework (feel free to contribute if you need more).

Shopware 6 has a special storage format that allows you to access translations of entities directly in the database.

## Exchange formats

PHPUnuhi's Exchange component allows you to easily share your translations with others, such as translation agencies.

The component allows for the export and import of translations in various file formats including CSV and HTML.

The HTML format even generates a single file that can be opened in a browser and edited with a simple "save" button to download a TXT file for later imports.

## Translator services

If you handle translations internally, it can be a time-consuming task.

To ease this burden, PHPUnuhi provides an option to automatically translate missing entries using popular services
such as Google Web, Google Cloud, DeepL, and OpenAI.

This can save you time and effort, allowing you to focus on other tasks.
Furthermore, the inclusion of services like OpenAI gives you the power of state-of-the-art machine translation technology,
so why not take advantage of it?

# Installation

To install PHPUnuhi in your project, simply use Composer.

```bash 
composer require boxblinkracer/phpunuhi
```

Afterwards create the XML configuration file (default filename phpunuhi.xml).
This contains all details of your translations.

Let's see this on the sample of a Shopware 6 plugin.

# Shopware 6 - Plugin Development

Translations are organized into **Translation-Sets**, with each set representing a specific scope.
This can be a particular feature or broader categories such as "storefront" and "administration".
The definition of sets is flexible and can be tailored to your specific needs.

Every Translation-Set contains **multiple locales**. That means, that PHPUnuhi can verify that all translations within your locales match,
and nothing was forgotten.

When creating a Translation-Set, you can specify additional settings that may depend on the components you are using.
These settings can include the **storage format**, as well as **filters** to include or exclude specific translations.
This allows for even more control and customization of your translation process.

Let's create a simple JSON-based configuration for our plugin:

```xml 

<phpunuhi
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="./vendor/boxblinkracer/phpunuhi/config.xsd"
>
    <translations>
        <set name="Administration">
            <format>
                <json indent="4" sort="true"/>
            </format>
            <locales>
                <locale name="de-DE">./Resources/app/administration/de-DE.json</locale>
                <locale name="en-GB">./Resources/app/administration/en-GB.json</locale>
            </locales>
        </set>
    </translations>
</phpunuhi>
```

This configuration bundles both our **de-DE.json** and **en-GB.json** into a single Translation-Set, named "Administration".

Let's verify if our files are in sync.

```bash 
php vendor/bin/phpunuhi validate
```

PHPUnuhi's validation process checks for missing keys, structures, and content in your translations.
If any issues are detected, the validation process will fail and provide a detailed output on what went wrong,
including which files are missing specific keys and values.

This allows you to quickly identify and fix any issues with your translations.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-phpunuhi/validation-structure.png" loading="lazy" alt="">
    </div>
</div>

By integrating PHPUnuhi into your **CI pipeline**, you can ensure that your translations are always up to date and accurate.
Even if you don't always actively pay attention to translations, the validation step in your pipeline will **alert you** to any issues that arise.
This allows you to easily catch and address any translation errors as part of your automated build process.

Once the validation process has identified errors in your translation files,
you have the option to fix them manually or use the built-in **fixing command** provided by PHPUnuhi.

This command automatically **corrects the structure** of your JSON files, and depending on the format settings,
it may even **sort** them alphabetically.

This simplifies the process of maintaining your translations and helps ensure that they are always accurate and up-to-date.

```bash 
php vendor/bin/phpunuhi fix:structure
```

Now that we fixed the structure, our validator would still fail. Simply, because the translations are now existing, but are still empty.

Let's use Google to **translate our missing values**.

```bash
php vendor/bin/phpunuhi translate --service=googleweb
```

After running the fixing command, you should notice that the missing entries have been **automatically translated**.
If you re-run the validator, it should now pass.

It's important to keep in mind that the translations generated by the command should be **reviewed before merging** them.
Using GIT for file-based translations is a good practice.
Additionally, keep in mind that different translation services have varying levels of quality, such as Google Web, Google Cloud, DeepL, and OpenAI.

It's worth noting that the "googleweb" service is easy and free to use, but it may be restricted after a certain amount of usage.
For heavy usage, it's recommended to get a Google Cloud API key for better performance.

# Shopware 6 - Shop Development

Even if you're not developing plugins with JSON files, but instead developing full shops as an agency or merchant, you can still take advantage of PHPUnuhi's features.

PHPUnuhi includes a **special storage format** for Shopware 6 which is directly **connected to the Shopware database and entities**.

This allows you to validate and fix translations of products, salutations, shipping methods, and more - essentially, **any entity** that has a "_translation" table in the database.

To start using this feature, you'll need to create a new configuration XML.
This time, you'll use the new storage format, which requires **ENV variables** for your database connection.
You can either set these variables on your server or provide them directly in the XML.

Next, create a new Translation-Set for your products.

Keep in mind that Shopware has many fields that can be translated, so you may want to **create filters** to focus on specific fields.

Lastly, configure the locales you want to focus on.

```xml

<phpunuhi
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="./vendor/boxblinkracer/phpunuhi/config.xsd"
>
    <php>
        <env name="DB_HOST" value="127.0.0.1"/>
        <env name="DB_PORT" value="3306"/>
        <env name="DB_USER" value=""/>
        <env name="DB_PASSWD" value=""/>
        <env name="DB_DBNAME" value="shopware"/>
    </php>

    <translations>
        <set name="Products">
            <format>
                <shopware6 entity="product"/>
            </format>
            <filter>
                <include>
                    <key>name</key>
                    <key>description</key>
                </include>
            </filter>
            <locales>
                <locale name="de-DE"/>
                <locale name="en-GB"/>
            </locales>
        </set>
    </translations>
</phpunuhi>
```

Before we start with our translation process, let's try to find out our **current coverage of translations**.

Run the **status** command to see this.

```bash 
php vendor/bin/phpunuhi status
 ```

This shows how many translations you have, and also the coverage of the possible translations.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-phpunuhi/coverage.png" loading="lazy" alt="">
    </div>
</div>

We can already see that we have no 100% coverage yet.
It seems as if our 2 products are missing 1 name and 1 description.

Let's translate our missing entries with the DeepL service.

```bash 
php vendor/bin/phpunuhi translate --service=deepl --deepl-key=xxxx
 ```

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-phpunuhi/translate-deepl.png" loading="lazy" alt="">
    </div>
</div>

As you can see, 2 entries have been translated, the source of these texts were taken from the existing values in the database.
The quality of the translations, as seen here with DeepL, looks quite promising.

To verify the changes, you can open the administration in Shopware 6 and check the values there.
The new translations should be visible immediately.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-phpunuhi/translated-value.png" loading="lazy" alt="">
    </div>
</div>


Now that we saw DeepL, let's repeat the step with a different service, such as OpenAI.

```bash 
php vendor/bin/phpunuhi translate --service=openai --openai-key=xxxx
 ```

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-phpunuhi/translate-openai.png" loading="lazy" alt="">
    </div>
</div>

As you can see, the translations generated by OpenAI are also of high quality.

However, there is an issue with a leading "." and line break at the start of the sentence,
which may be a result of imperfections in either my code or the OpenAI model.

Nevertheless, I am confident that these issues will be addressed and improved in the near future.

# Where to go from here?

If you find the approach of PHPUnuhi useful, I highly recommend exploring the Github repository and its extensive documentation.
There is a wealth of features to discover, including the HTML Export, storage formats, groups, and more.

You can find the repository here: https://github.com/boxblinkracer/phpunuhi

