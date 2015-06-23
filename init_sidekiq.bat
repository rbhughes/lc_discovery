:: may need to define all sorts of ENV paths here?

::bundle exec sidekiq -r "./workers/*"
:: redis queue name = lc_discovery

bundle exec sidekiq -L "./tmp/sidekiq.log" -q lc_discovery -c 10 -r "./workers/launch_all.rb"

