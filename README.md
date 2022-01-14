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

If your using the Alma Analytics Api, edit `.env` Replace the value for `ALMA_API_KEY` with a real key with appropriate permissions. 
If you're processing a csv file, a real API KEY isn't necessary.

Build the image
```
$ docker-compose build
```

Install the gems
```
$ docker-compose run --rm web bundle install
```

To run the script to use the Alma API:
```
$ docker-compose run --rm web bundle exec ruby get_print_holdings.rb
```

To run the script to process a csv, edit the last three lines of  `process_print_holdings.csv` to reference your csv file(s).

Then run
```
$ docker-compose run --rm web bundle exec ruby process_print_holdings.rb
```
