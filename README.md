# ht_print_holdings

## Developer Setup
Clone the repository and cd into it
```
$ git clone git@github.com:mlibrary/ht_print_holdings.git
$ cd ht_print_holdings
```

Copy `.env-example` to `.env`
```
$ cp .env-example .env
```

Edit `.env` Replace the value for `ALMA_API_KEY` with a real key with appropriate permissions

Build the image
```
$ docker-compose build
```

Install the gems
```
$ docker-compose run --rm web bundle install
```

To run the script
```
$ docker-compose run --rm web bundle exec ruby get_print_holdings.rb
```
