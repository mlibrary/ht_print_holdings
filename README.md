# ht_print_holdings

## Developer Setup
Clone the repository and cd into it
```
$ git clone git@github.com:mlibrary/ht_print_holdings.git
$ cd ht_print_holdings
```

Build the image
```
$ docker-compose build
```

Install the gems
```
$ docker-compose run --rm web bundle install
```

Edit the last three lines of `process_print_holdings.csv` (before the `tar.gz` step) to reference your csv file(s).

Then run
```
$ docker-compose run --rm web bundle exec ruby process_print_holdings.rb
```

