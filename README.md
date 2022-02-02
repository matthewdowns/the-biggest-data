# The Biggest Data

Experiment to record as much data as possible in a given amount of time using a distributed timeseries database.

## On your marks...

Install the following:

1. [Docker](https://docs.docker.com/get-docker) and [docker-compose](https://docs.docker.com/compose/install) installed
2. [Node.js](https://nodejs.org) (for running the data ingestion script)

## Get set...

Start the docker containers:
```sh
docker-compose up
```

Login your Grafana instance with _admin/admin_, and set up a dashboard.

## Go!

Run the ingestion script:
```sh
npm start
```

At this point, a very large amount of randomized data will be ingested into
the distributed timeseries database. The entire process can take up to 5 minutes.
