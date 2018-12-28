
## Polyscripted Wordpress

This is the root project for Polyscripted WordPress.

Polyscripted WordPress applies polyscripting techniques to a WordPress container to create an instance of WordPress that is extremely resilient to script injection attacks.

Polyscripting works by using moving taret defense technologies to create a unique instance of the PHP programming language for every instance of this container. Since the PHP language is unique, script injection attacks quite simply fail: they do not know the specific instance of PHP running in this container.

What is Moving Target Defense? Read on...

Polyscripted WordPress is sponsored by @Polyverse Corporation.


**Introduction: Moving Target Defense**

When it comes to programming, it is important to accept an essential fundamental truth: every piece of software is hackable. Ultimately, this means everyone is vulnerable. Given enough time and resources, a vulnerability can always be found and an exploit can be crafted. What makes this attractive to a malicious actor is that a crafted attack can be applied across a wide surface area. With any given vulnerability, a hacker is able to execute an exploit across a range of machines that meet the criteria defined by a presupposed, assumed, and known attack vector. The effort-to-reward ratio is in their favor.

Exploits are cheap and widely available. While it is incredibly expensive to craft an exploit for every vulnerability, they can be built once and sold many times over because of the homogeneity of programs. Everyone runs the same programs, operating systems, machines, languages and databases. This includes those concocting attacks. This sort of identical  access provides an advantageous roadmap to build malicious exploits, to find vulnerabilities and to carefully craft attacks that can be used at a large scale. It presents difficult problems and powerful opportunities within the security space.

Moving Target Defense (MTD) offers a solution that draws its inspiration from nature.

Genetic diversity is both a key to, and a result of the survival and evolution of organisms. All members of a population do not share the exact genetic makeup. If every human was a clone, the first deadly disease that came along would affect each individual the same way, essentially wiping out the human race. Think of a disease like a malicious hack. It needs to propagate and interact with the host&#39;s defenses in a certain manner in order to effectively spread. If every human was  genetically identical, a disease able to successfully infect one person could similarly infect other humans with the same deadly consequence. Yet, this is not the case with organisms. A disease that is deadly to one individual, may not ail another with so much as a fever because of the diversity in their genetic makeup. The key here is that everyone possess unique DNA, which is a key component to a species&#39; survival.

What if computer programs shared this quality of having their own unique genetic makeup? This is the concept that MTD applies to cybersecurity. MTD is predicated on introducing unique components between machines, programs, binaries, and languages, thus limiting exploitation to when its makeup exactly matches the expected attack vector. As with infections, many attack vectors rely on being able to access certain anchor points or data. MTD  aims to rearrange these anchor points so that an exploit is unable to adjust to nor account for the change, causing an attack to ultimately fail.

MTD is the practical application of nature&#39;s genetic diversity to technology. It creates a program that while identical in function, is entirely unique from any previous version of the program. For example, Polyverse&#39;s polymorphic version of Linux is one such MTD solution. It relies on custom compilers to generate unique binaries that allow for the constant rearrangement of the aforementioned anchor points. By &#39;scrambling&#39; these anchor points, the protected software programs and systems effectively become immune to all but the most targeted of memory exploits. Simply put, a malicious actor must choose to directly target your machine or server knowing that it is different from any with which they may have previously interacted. In the case of systems running polymorphic version of Linux and adhering to a strategy of MTD, knowing that the attack vector, even if successfully enumerated, will not stay the same for long is an invaluable asset. In other words, the application&#39;s memory landscape is a constantly shifting moving target, making exploitation significantly more difficult, resource intensive, and time consuming.

The tactics the polymorphic version of Linux applies to compilers, a concept dubbed &quot;Polyscripting&quot; is now applying to language interpreters. Interpreted languages in web applications are ubiquitous and are used for critical tasks, such as information storage and retrieval, as well as providing seamless interactivity via an application&#39;s UI. These languages include PHP, JavaScript and SQL and provide commonplace, easily identifiable, and exploitable areas of publicly distributed web applications. One such exploitation is code injection attacks.

**Code Injection Attacks**

It is easy to point fingers when it comes to security breaches. Whether it&#39;s deprecated legacy code, a zero-day vulnerability, or a forgotten patch, people make mistakes and things happen. These breaches continue to happen, even as the industry focuses on budding new technologies like artificial intelligence, quantum computing, and blockchains in order to stay secure. SQL injection continues, and WordPress vulnerabilities that allow code injection are being taken advantage of. Data is consistently corrupted and stolen and ransomware is a constant plague on both the private and public sectors.

Code injection is an incredibly powerful tool that hackers employ to accomplish their goals. It is an attack vector allowing a malicious actor to run their own code on a server or website belonging to a separate entity. Often, it is used as a backdoor to access information or to change and to corrupt data. Some of the most devastating breaches in history have relied on simple code injection. For example, the Equifax breach relied on code that was injected through an unprotected deserialization call. There are certain methods to meticulously guard against code injection, such as input sanitization, code signing and whitelisting. Despite the techniques that exist to thwart code injection, such attacks continue to occur at an increasingly alarming rate. September 2018 alone saw numerous noteworthy code injection attacks:

* Scarma Labs published a white-paper before blackhat 2018 that described a PHP vulnerability that has gone unpatched and unreported for over a year since they first notified various services of the issue, WordPress, the most used CMS on the internet, as of a few weeks after the reports, had still not issued a fix for the vulnerability which allows code injection.1
-
* A zero-day bug allowed hackers to access CCTV surveillance cameras, and subsequent code injection and remote code execution allowed hackers to gain access to user accounts as well as change passwords.2
-
* A Remote Code Execution vulnerability existed in the widely popular Duplicator WordPress plugin that affected many users, this was patched September 5th 2018.3

Needless to say, this exploit is hardly a thing of the past.

Equifax is probably the most potent example of code injection that led to an incredibly devastating remote code execution attack. This mega-breach resulted in potentially 143 million Americans&#39; most sensitive personal information being exposed. Equifax utilized Apache Strut&#39;s as its framework for creating Java web applications. The parser this uses—Jakarta—contained the security flaw. This flaw was patched prior to the breach, but the patch was never applied.

The Jakarta parser had a feature that allows you to deserialize XML into Java objects. A simplified version looks like this:

\&lt;object class=&quot;io.polyverse.Person&quot;\&gt;
        \&lt;field name=&quot;Name&quot;\&gt;Archis\&lt;/field\&gt;
        \&lt;field name=&quot;City&quot;\&gt;Seattle\&lt;/field\&gt;
\&lt;/object\&gt;

All someone had to do was try to instantiate an internal object:

\&lt;object class=&quot;java.system.Exec&quot;\&gt;
        \&lt;field name=&quot;Command&quot;\&gt;/bin/rm\&lt;/field\&gt;
        \&lt;field name=&quot;Params&quot;\&gt;-rf\&lt;/field\&gt;
\&lt;/object\&gt;

The Struts vulnerability allowed any and all objects to be instantiated by default when no whitelist/blacklist was provided. The hackers were able to inject code and execute it remotely.

This is part of a practice that Polyverse calls DevSecOps. Safe defaults by developers that prevent dangerous execution paths from being followed. The aforementioned flaw was widely exploited despite a corrective patch being published the same day the vulnerability was announced to the public. An extreme, but all too real example of someone capitalizing on an exploit of this nature.

**Polyscripting — An Introduction**

Rather than endlessly stressing about patching and attempting to juggle all of the vulnerabilities exposed via your application&#39;s attack surface, Polyscripting removes the prerequisite mechanics that allow such attacks to occur. This ensures that even when safeguards prove ineffective, the attack vector was previously undiscovered, or a patch was not applied in a timely manner, the attack will simply not work.

Applying the idea of Moving Target Defense, the question to ask is what kind of homogeneity allows for malicious code injection? What makes code injection and remote code execution possible as a whole? What information does a malicious actor have to gather that allows them to exploit a third party&#39;s assets?

There are two assumptions made during this kind of attack: First, that malicious code can be injected into the system, and second, that the malicious code can be remotely executed.

Polyscripting negates that second assumption. Today, remote code execution and code injection attacks are possible because a hacker can write injectable code, upload it to a server, and execute it. In this scenario, the server understands the hacker&#39;s code in the exact same way it understands valid code because they are written in the same language, with the same syntax. This allows the attacker to derive value from the injection. The hacker&#39;s roadmap relies on the successful execution of their code. If a server contains a PHP interpreter, then it has the capacity to parse and execute any PHP code.

What if that wasn&#39;t the case? If a server was unable to execute injected code, then this attack vector as a whole would be rendered ineffective. Without impacting functionality, Polyscripting gives each website a unique instance of a programming language. This kind of diversity renders that second crucial assumption, that the attacker will be able to execute the code they have injected, false.

Polyscripting takes a programming language and scrambles (explained later, but understanding scrambling as randomization will suffice for now) the syntax and grammar within the source for that language before the interpreter is compiled. The output is a dictionary that is used to transform all necessary source code before it runs in production. This results in an application that has its own unique implementation of a language, as well as the matching interpreter. The new interpreter no longer understands the original syntax and grammar of the original language. It will only execute the source code that matches the newly generated unique interpreter. Additionally, this process can be repeated on demand, adding additional layers of defense, making time an ally to a system&#39;s defenses through the use of regular intervals at which the interpreter and source code undergo polyscripting. This process emulates a moving target, remapping the application&#39;s address space so frequently that proper enumeration, crafting, and execution of an exploit becomes impractically difficult. This schews the effort-to-reward ratio so that it is no longer in a hacker&#39;s favor.

It comes down to **cause** and **effect**. Whether the cause of code injection is exploiting broken deserialization methods, a legacy vulnerability in a plugin, or an unknown language vulnerability, the responsibility to guard against these falls on the programmer. However, hackers are creative, and even the &quot;most securely written&quot; of programs get hacked. Just look at Facebook, Playstation, Equifax or Target. All companies with massive security teams that genuinely put in the research, time, and effort to stop the **cause** of these attacks, yet they still happen. Polyscripting is a way to stop this **effect.** Normally, the effect of a successful code injection attack would be the execution of the malicious code, with Polyscripting a syntax error gets thrown and no malicious code is run; stopping the malicious effect.

**Standard Workflow**

In a basic workflow for a standard website running PHP, the PHP interpreter is compiled and loaded onto the web server. The website&#39;s source code is also pushed to the same server. The PHP interpreter then parses and interprets the source code before sending the result elsewhere: to a user, browser, database, etc.





At a very basic level, this is a two-step process:

**                               **  **1. Build                               2. Run**


**Polyscripting Workflow**

Polyscripting only adds one additional layer to this deployment process. The PHP source code gets scrambled to the polyscripted version and the websites source code gets scrambled to match the unique instance of PHP that was generated. The interpreter for the language (PHP) is changed at compile time and, ideally, the scrambled dictionary is only accessed and only exists **before** being deployed to a web server.

**       **

**                       **  **1. Build   2. Scramble &amp; Transform  3. Run**

 ![Polymorphic PHP](https://github.com/archisgore/diagrams/blob/master/Polyscripted%20Wordpress.png)

**Language Scrambling**

The process of scrambling a language is beautifully simple. The make-up of a programming language is contained within its syntax and grammar. The keywords and syntax of a language are defined and compiled to make up the words and ordering of word-tokens that a language understands. Programs are then parsed based on this lexical syntax to generate the grammar the further defines a language.

The values of the keywords themselves are arbitrary in any given language. Keywords are defined for the convenience of those writing the code. If you think of these words as just a means to write a language, the values themselves are random. Where &quot;echo&quot; is defined in the lexical grammar, a replacement could be defined with any randomized value. If you replace &quot;echo&quot; in the lex file with &quot;foo&quot; and then run the code: foo &quot;hello world,&quot; it will echo the string given. However if you try to run the code: echo &quot;hello world&quot;, a syntax error will be thrown. The language no longer understands &quot;echo&quot;, but treats the command &quot;foo&quot; as it would previously have treated &quot;echo&quot;.



**Conclusion**

Polyscripting has the potential to be a powerful tool to defend against code-injection attacks. Though scrambling keywords is powerful, there are many other ways to increase the effectiveness of Polyscripting. Scrambling more than just keywords, but also built-in PHP functions, is a feature that would increase Polyscripting&#39;s effectiveness and is a likely addition in the near future. Similarly, scrambling more than the language tokens, but also the grammar and the Abstract Syntax Tree of the language will add an entirely new layer of security to any language Polyscripting is applied to. Polyverse is creating a new standard to expect from programming languages —Polyscripting capabilities.

For more information contact [support@polyverse.io](mailto:support@polyverse.io) or visit our website: [https://polyverse.io/](https://polyverse.io/)

**Links &amp; Resources**

[https://polyverse.io/polyscripting/](https://polyverse.io/polyscripting/)

[https://github.com/polyverse/polyscripted-php](https://github.com/polyverse/polyscripted-php)

[https://github.com/polyverse/ps-wordpress](https://github.com/polyverse/ps-wordpress)

[https://blog.polyverse.io/introducing-polyscripting-the-beginning-of-the-end-of-code-injection-fe0c99d6f199](https://blog.polyverse.io/introducing-polyscripting-the-beginning-of-the-end-of-code-injection-fe0c99d6f199)

[https://view.attach.io/ByfWW3KGf](https://view.attach.io/ByfWW3KGf)

[https://cdn2.hubspot.net/hubfs/3853213/us-18-Thomas-It&#39;s-A-PHP-Unserialization-Vulnerability-Jim-But-Not-As-We-....pdf](https://cdn2.hubspot.net/hubfs/3853213/us-18-Thomas-It&#39;s-A-PHP-Unserialization-Vulnerability-Jim-But-Not-As-We-....pdf)

[ https://threatpost.com/zero-day-bug-allows-hackers-to-access-cctv-surveillance-cameras/137499/](https://threatpost.com/zero-day-bug-allows-hackers-to-access-cctv-surveillance-cameras/137499/)

[ https://www.wordfence.com/blog/2018/09/duplicator-update-patches-remote-code-execution-flaw/](https://www.wordfence.com/blog/2018/09/duplicator-update-patches-remote-code-execution-flaw/)







# Polyscripted WordPress is built from https://github.com/docker-library/wordpress

## Maintained by: [the Docker Community](https://github.com/docker-library/wordpress)

This is the Git repo of the [Docker "Official Image"](https://docs.docker.com/docker-hub/official_repos/) for [wordpress](https://hub.docker.com/_/wordpress/) (not to be confused with any official wordpress image provided by wordpress upstream). See [the Docker Hub page](https://hub.docker.com/_/wordpress/) for the full readme on how to use this Docker image and for information regarding contributing and issues.

The [full description from Docker Hub](https://hub.docker.com/_/wordpress/) is generated over in [docker-library/docs](https://github.com/docker-library/docs), specifically in [docker-library/docs/wordpress](https://github.com/docker-library/docs/tree/master/wordpress).

## See a change merged here that doesn't show up on Docker Hub yet?

Check [the "library/wordpress" manifest file in the docker-library/official-images repo](https://github.com/docker-library/official-images/blob/master/library/wordpress), especially [PRs with the "library/wordpress" label on that repo](https://github.com/docker-library/official-images/labels/library%2Fwordpress).

For more information about the official images process, see the [docker-library/official-images readme](https://github.com/docker-library/official-images/blob/master/README.md).

---

-	[Travis CI:  
	![build status badge](https://img.shields.io/travis/docker-library/wordpress/master.svg)](https://travis-ci.org/docker-library/wordpress/branches)
-	[Automated `update.sh`:  
	![build status badge](https://doi-janky.infosiftr.net/job/update.sh/job/wordpress/badge/icon)](https://doi-janky.infosiftr.net/job/update.sh/job/wordpress)

| Build | Status | Badges | (per-arch) |
|:-:|:-:|:-:|:-:|
| [`amd64`<br />![build status badge](https://doi-janky.infosiftr.net/job/multiarch/job/amd64/job/wordpress/badge/icon)](https://doi-janky.infosiftr.net/job/multiarch/job/amd64/job/wordpress) | [`arm32v5`<br />![build status badge](https://doi-janky.infosiftr.net/job/multiarch/job/arm32v5/job/wordpress/badge/icon)](https://doi-janky.infosiftr.net/job/multiarch/job/arm32v5/job/wordpress) | [`arm32v6`<br />![build status badge](https://doi-janky.infosiftr.net/job/multiarch/job/arm32v6/job/wordpress/badge/icon)](https://doi-janky.infosiftr.net/job/multiarch/job/arm32v6/job/wordpress) | [`arm32v7`<br />![build status badge](https://doi-janky.infosiftr.net/job/multiarch/job/arm32v7/job/wordpress/badge/icon)](https://doi-janky.infosiftr.net/job/multiarch/job/arm32v7/job/wordpress) |
| [`arm64v8`<br />![build status badge](https://doi-janky.infosiftr.net/job/multiarch/job/arm64v8/job/wordpress/badge/icon)](https://doi-janky.infosiftr.net/job/multiarch/job/arm64v8/job/wordpress) | [`i386`<br />![build status badge](https://doi-janky.infosiftr.net/job/multiarch/job/i386/job/wordpress/badge/icon)](https://doi-janky.infosiftr.net/job/multiarch/job/i386/job/wordpress) | [`ppc64le`<br />![build status badge](https://doi-janky.infosiftr.net/job/multiarch/job/ppc64le/job/wordpress/badge/icon)](https://doi-janky.infosiftr.net/job/multiarch/job/ppc64le/job/wordpress) | [`s390x`<br />![build status badge](https://doi-janky.infosiftr.net/job/multiarch/job/s390x/job/wordpress/badge/icon)](https://doi-janky.infosiftr.net/job/multiarch/job/s390x/job/wordpress) |

<!-- THIS FILE IS GENERATED BY https://github.com/docker-library/docs/blob/master/generate-repo-stub-readme.sh -->
