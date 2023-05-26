---
layout: post
title: Shopware Community Days 2023 from a Developers Perspective
description: SCD with a new concept on empowering developers and merchants in the eCommerce Community
date: 2023-05-26 10:00:00 +0300
image: '/images/blog/shopware-scd23/header.png'
tags: [ shopware ]
---


---


The annual Shopware Community Days event is a highly anticipated gathering of eCommerce enthusiasts, business owners, developers, and industry professionals. As each year passes, this event grows in influence and significance, providing a platform for knowledge sharing, networking, and gaining valuable insights into the future of eCommerce.



This year, the event took on a different format, featuring separate developer and merchant days. The developer day and its venue had a great feel of the Shopware Unconference organized by Firegento. Although it deviated from the usual SCD experience, the atmosphere of an (un)conference proved to be an ideal solution for developers. Unfortunately, due to space limitations, only 100 people were able to attend this day. However, there is great potential to expand this developer event in the future and accommodate a larger number of attendees.

One positive aspect was the presence of a single track of talks, which made it convenient to attend and experience all of them. I particularly appreciated this arrangement.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-scd23/devs.jpg" loading="lazy" alt="" >
    </div>
</div>


The day commenced with Rico Neitzel, interviewing Stefan Hamann, the CEO of Shopware. The talk led us on a journey through the history of Shopware using an old overhead projector. It evoked a pure sense of nostalgia and highlighted the company's journey from its humble beginnings to the proud establishment it is today.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-scd23/stefan.jpg" loading="lazy" alt="" >
    </div>
</div>


The subsequent talk by the esteemed Michael "Telgi" Telgmann, though somewhat bittersweet and emotional, was of great quality. Starting with the cinema movie that introduced Shopware 8 years ago, it was time to bid farewell to a system that had guided us throughout these years. Shopware 5 has reached its End of Life. However, until the end of July 2023, Shopware will continue to provide bug fixes and improvements, and security updates will be available until the end of July 2024. For those who still wish to use Shopware 5, I recommend checking out SaveFive ([https://safefive.de/]. This dedicated group focuses on extending the life of Shopware 5 through additional security updates. Additionally, developers were surprised and excited about the decision to pass Shopware 5 on to the community - so we eagerly await the outcome.

Ramona Schwering, a well known speaker, enlightened us about Composable Frontends, the new frontend system. Building a storefront has never been easier, and that's the impression I got from her talk. Need a product image? Just add it with a small composable. Want an "Add to cart" button? No problem. Her talk provided valuable insights into the fundamental aspects of composables. I'm excited to delve deeper and explore how it all functions in real world projects.

The event also included updates about the community. The Shopware Community Engagement Program (SCEP) was introduced as a new initiative to support community members and their work. From what I gathered, the program aims to engage individuals who are already actively involved, in a way that should not end like the known Masters-Program, which makes adults cry if they are not accepted. We will have to see what it truly entails.

Jens Küper discussed the challenges faced by Shopware in running the SaaS solution at scale. He shared insights into their approach, including the use of custom reverse proxies to reduce load on instances when rate limits are reached and more. I found this glimpse into the inner workings of the system to be enlightening. It would be great to explore more details in future talks.

Martina Linnemann, the co-host of the event, not only excelled as a host but also delivered an insightful talk on the new community feedback tools. She addressed the question of where to post bugs, provide feedback, and share ideas. While Slack and the Issue Tracker continue to be relevant, she introduced the latest tool [https://feedback.shopware.com/] for submitting new ideas in an organized and clutter-free manner, fostering meaningful discussions in the forum. It's commendable to see Shopware's commitment to improving communication channels.

Sebastian Seggewiß, renowned for his wonderful talks, enlightened us about the Shopware Administration and the company's plans for the future. He ensured that everyone was on the same page, clarifying the distinction between apps and plugins. He emphasized the symbiotic relationship between the two and highlighted the key aspects of apps. While there was a comparison sheet suggesting that apps eliminate the need for a larger technology stack, the reality, I have to say is, that Twig, JavaScript, and SCSS are still integral components of a Shopware app, albeit PHP is mostly eliminated and maybe replaced with a different language from the backend side. I also realized that even a backend server is not necessary for certain functionalities, such as Custom Fields. I think, there is a need for further marketing and showcasing real use cases to better explain the App System. Nevertheless, Sebastian delivered an excellent presentation.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-scd23/slide.png" loading="lazy" alt="" >
    </div>
</div>


During the interview moderated by Sander Mangel, we gained insights into the architectural approaches of Shopware from Daniel Nögel, the VP of Engineering. The comparison between the current state of Shopware and its earlier years highlights the significant positive changes it has undergone in a professional manner. What began as an idea has now evolved into a system with a grand vision, and Daniel, in his role as VP of Engineering, is perfectly positioned to drive it forward.

Unfortunately, Niklas Dzösch, who was supposed to be our host for the day, was unable to do so because of his ongoing loss of voice from being sick. However, he still made an effort to host the Shopware vs. Community challenge. Team Community, consisting of Stephan Pohl (frontend super hero), Max Schlemmer (the kindest person you'll ever meet), and Uwe Kleinmann (Mr. Performance), battled against Team Shopware, comprised of Soner Sayakci (1: the person who knows everything), Christian Rades (goto 1;), and Björn Meyer (a fantastic guy who will bring dynamically generated JS API clients to Shopware... :D ). The challenge involved using AI to create a Cody ElePHPant, but it proved to be more difficult than anticipated to specify prompts and obtain accurate results. After numerous peculiar elephant creations, Shopware finally managed to build the winning picture, as voted by the entire community on Slack.


<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-scd23/cody.jpg" loading="lazy" alt="" >
    </div>
</div>


Unfortunately, the talk about AI had to be canceled due to Niklas' voice issues on that day. However, this afforded me enough time to prepare for my own talk, titled "We Rise Above Beyond," which followed next. After four months of preparation, I did a presentation from the community, for the community. Using a fictional project that incorporated real tasks, failures, and experiences from community members, I aimed to demonstrate the possibilities with Shopware and provide insights into topics such as Open ID Connect, MySQL JSON column problems, and more. The talk, hopefully entertaining, was sprinkled with humor, an enactment of Shakespeare's Hamlet (yes, I went all-in), and professional superhero comics representing our community heroes: Uwe Kleinmann, Joshua Behrens, Edin Dedagic, Johan Moorman, and Martin Weinmayr. I extend my gratitude once again for their invaluable contributions.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-scd23/comics.jpg" loading="lazy" alt="" >
    </div>
</div>

Fabian Blechschmidt brought the day to a close with a fascinating game. Ever heard of black stories? He used it to perform live debugging with us, presenting real cases and problems that occurred. Being creative and finding solutions through simple "yes/no" questions was indeed challenging at times, but somehow Jonas Dambacher did an exceptional job... liebe grüße.

It was a wonderful day, guided by the fantastic hosts Martina Linnemann and Christian Rades, who stepped in for Niklas. Both of you did an outstanding job in leading us through the event.

Lastly, I want to give a great shoutout to Claudia Teubner from Shopware for making this day possible. Well done!

What would I wish for? Well, there are certainly areas that could be improved. I've always been a huge fan of the entire SCD experience as it was before, but I completely fell in love with the separate developers' day. For 2024, I would love to see a bigger venue, similar to the merchant day, accommodating a large number of developers (and even non-devs who would like to attend). Additionally, having a live stream for those unable to attend in person would be a fantastic addition.

Fortunately, I was able to attend the Merchant day as well. From a developer's perspective, I expected it to be a more relaxed day where I wouldn't know many people. However, it turned out to be an amazing day too. Despite the different vibe (in a good way), I had the opportunity to meet familiar faces and engage in great discussions, including topics like "when will plugins be ready for Shopware 6.5" and more. It made me realize that developers can also participate in a day that's primarily intended for sales teams and merchants. "Together we rise above beyond" holds true not only for developers but also for a merchant-dev combination.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-scd23/party.jpg" loading="lazy" alt="" >
    </div>
</div>


To keep it brief for now, it was truly a great day. Sebastian Hamann's keynote keeps getting better every year, and he was accompanied by Mark Stanley, Vanessa Brauch, and Moritz Naczenski, who simply nailed it. Cassie Kozyrkov from Google dispelled our fears about AI by considering it as an optional tool we can use, delivering one of the most remarkable talks you'll ever hear. Marcel Korzen (Wortmann), Felix Schmalenberger (Wortmann) and Martin Weinmayr (dasistweb) showcased Guided Shopping as a fascinating B2B tool, and Jonas Kröger, Jonas Dambacher, and Co. discussed Shopware PaaS.

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-scd23/keynote.jpg" loading="lazy" alt="" >
    </div>
</div>


However, the highlight was undoubtedly the announcement of "AI Copilot" by Shopware. Although there is still much work to be done, once you see it, you'll understand its benefits and potential. Yes, there are other important tasks at hand, but imagine if the world stopped inventing the future just to focus on our present!
Still I agree with Matthias…”AI Copilot” sounds great….but why not “Shopware Copilot”?! :)

<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-scd23/copilot.png" loading="lazy" alt="">
    </div>
</div>

Oh, and I was finally able to meet Claire and tell her how much value she brings as a professional host of the Community Day. (bring her back)

I want to express my gratitude to Shopware for providing this incredible experience. I eagerly look forward to SCD 2024 with a focus on developers and merchants, along with the opportunity for everyone to attend both days, regardless of who they are or where they are located (through a live stream).


<div class="gallery-box">
    <div class="gallery">
        <img src="/images/blog/shopware-scd23/people.png" loading="lazy" alt="">
    </div>
</div>
