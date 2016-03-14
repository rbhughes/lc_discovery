lc_discovery (defunct)
---------
![lmkr_ggx](/lmkr_ggx.png?raw=true "lmkr_ggx")

This is the ruby-based prototype of a queue-based metadata collector for LMKR [GeoGraphix Discovery]. It has been/will be superseded by [discovery], which is essentially a node.js based iteration of the same thing.

**But what does it actually do?**

LMKR's GeoGraphix Discovery Suite is a premier interpretation software package used by geoscientists and engineers in the E&P industry. At the heart of every Discovery project is a SAP (formerly Sybase) SQLAnywhere database. Even a modest environment may have dozens of projects containing millions of well and production records, and they are typically distributed across several project servers.

If you had millions of rows in a database, you could connect with a client and query it much like any other app. However, if you have millions of rows in several different databases at unpredictable file paths on a Windows intranet with tricky security it gets harder. Locating and validating all the databases and constructing the connection strings is challenging enough, but that approach is too slow. The goal is near-real-time.

> This project attempted to "divide and conquer" the problem by engaging a scalable number of [Sidekiq] workers taking direction from a [Redis] queue to each run snippets of queries in parallel. A separate bootstrap-based Rails app provided the UI for the queue (and search functionality). It never matured enough for me to decide on a persistence layer, but I was leaning towards [Elasticsearch] or maybe even transient [RedisObjects].

**Why is it defunct?**

Keeping Ruby/Rails happy on a Windows environment proved too much of a chore. I eventually decided to give Node another try, and I also need to figure out some nasty RDBMS --> flattened doc with hierarchy +/- RDBMS problems.




[GeoGraphix Discovery]:http://www.lmkr.com/geographix
[ggx_monitor]:https://github.com/rbhughes/ggx_monitor
[discovery]:https://github.com/rbhughes/discovery
[Sidekiq]:http://sidekiq.org/
[Redis]:http://redis.io/
[Elasticsearch]:https://www.elastic.co/
[RedisObjects]:https://github.com/nateware/redis-objects



