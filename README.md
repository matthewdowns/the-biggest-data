# The Biggest Data

Experiment to record as much data as possible in a given amount of time using a distributed timeseries database.

## On your marks...

Install the following:

1. [Docker](https://docs.docker.com/get-docker) and [docker-compose](https://docs.docker.com/compose/install) installed
2. [Node.js](https://nodejs.org) (for running the data ingestion script)

An easy one to start with is [Node.js](https://nodejs.org)

## Get set...

Start the docker containers:
```sh
docker-compose up
```

Login your Grafana instance with _admin/admin_, and watch the pre-configured dashboard.

## Go!

_Note: Before starting, it is **crucial** that you have at least 100GB of free storage space available.
You should also close down any browsers, programs, or otherwise anything other than this program so that
no external factors will affect your results._

Run the ingestion script:
```sh
npm start
```

At this point, a very large amount of randomized data will be ingested into
the distributed timeseries database. Depending on the source language used,
the entire process can take between 5 and 10 minutes.
