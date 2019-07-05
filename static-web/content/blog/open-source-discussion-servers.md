Title: Open Source Discussion Servers
Date: 2019-07-05

[Disqus](https://disqus.com/) is the market leader in hosted discussion
systems. But the source isn't available so you cannot host a Disqus server
yourself. In this article I briefly survey some open source systems providing
similar functionality. Whilst I'm generally a fan of using hosted services,
there are a few reasons for self hosting in this case:

- Learning: it can be instructive to figure out how things work.

- Cost: You pay for Disqus. There is a free tier, but this mean they get to serve
  adverts, which might be inappropriate for your use case.
  
- Privacy and security.

- Performance: You control how to scale your comments system with usage.

- Open source allows for fixing bugs and adding features and, at least for
  widely used software, some reassurance that serious security issues might be
  discovered quickly.


More discussion see e.g:

- <https://crunchify.com/its-time-say-goodbye-to-disqus-comment-system-on-crunchify/>
- <https://learninternetgrow.com/disqus-pros-cons/>
- <https://fedidat.com/530-blog-comments/>
- <https://news.ycombinator.com/item?id=18308087>
- <https://alternativeto.net/software/disqus/?license=opensource>
- Plenty more by searching...


At the time of writing I've deployed Isso, but I'm considering changing (hence
this article). Note that I haven't actually deployed any of the others, so I'm
just going on what I can glean from a fairly quick look at documentation and the
sources. Some of these offer paid, hosted versions.

None of these provide k8s config for deployment, although all at least have
Dockerfile(s), if not prebuilt images.


This is a quick list of things that caught my eye. It's not a comprehensive
feature by feature comparison.

## [Isso](https://posativ.org/isso/). 

- <https://github.com/posativ/isso>

- Python: my preferred language in the event I want to change things or fix
  bugs.
      
- Very simple to run and deploy, I took me just a couple of hours to build a
  Dockerfile, some Kubernetes manifests to deploy it; and client side
  configuration for my static site generation tool (I'm using
  [Pelican](https://blog.getpelican.com/) at the moment).
  
- SQLite persistence layer: This is touted as an advantage (and it's simple
  in the case of a single replica for the server). But:
      - The persistence isn't easy to scale.
      - Scaling the web api is problematic too - multiple process can only lock
        the whole database, and they all need access to same underlying file
        system. This also a reliability issue as well as a potential perfomance
        issue.
      - You can't really use hosted databases or your existing self-hosted
        database, so you're forced to deal with your own persistence scaling and
        backups etc.
      - Hard to update without downtime
      - This is [acknowledged](https://posativ.org/isso/faq/), with the suggested
        solution of using Disqus instead.

- Not event loop / asyncio based. I like to do python web apis on top of an
  event loop for performance reasons. To some extent it doesn't matter if you
  can scale as needed, but the persistence choice makes things tricky in this
  case.
        
- No oauth2 (or similar) option. Sometimes this is fine, but there are
  contexts where you want proper authnz and SSO. I might spend some time
  looking at what I can do via nginx config in front of the api.

## [Remark42](https://remark42.com/)

- Golang
- Oauth2 for some providers at least.
- Boltdb persistence (same issues as using SQLite).
 
      
## [Mouthful](https://github.com/vkuznecovas/mouthful)

- Choice of persistence layers.
- Golang (dep not modules).
- The last commit was 10 months ago, which is not necessarily a
  problem, but I'm a little wary of abandonware. 
- Auth with oauth2: <https://github.com/vkuznecovas/mouthful/blob/master/examples/configs/README.md#oauth-providers>


## [Schnack](https://github.com/schn4ck/schnack)

- SQLite persistence.
- Js / Node.
- Oauth2 config for various providers.


## [Commento](https://commento.io/)

- <https://github.com/adtac/commento>, which is a mirror of <https://gitlab.com/commento/commento>

- Hosted service available.

- Postgres persistence.
  
- Golang.

- Oauth2 / SSO support. [SSO docs](https://docs.commento.io/configuration/frontend/sso.html). 
  It looks like management of signing keys for Oauth2 involves a bit of manual UI cut'n'paste, but maybe this can be scripted.
      

## [Coral Talk](https://coralproject.net/talk/)

- <https://github.com/coralproject/talk>
- Javascript / Node.
- Mongodb and redis for persistence (maybe redis is a cache?).
- Hosted service available - <https://coralproject.net/pricing/>
- Authentication with some providers, and guidance for doing your own custom
  integration: <https://docs.coralproject.net/talk/integrating/authentication/>


### Conclusion

I've decided to rule out the systems based on SQLite or Boltdb. Unsurprisingly,
the systems providing hosted services generally seem more feature rich and
active. The quid pro quo is that they're generally more heavyweight and more
involved to get up and running. But still, my inclination is to chose between
Commento and Coral Talk. For the time being I'll deploy Commento, and see how it
goes.
