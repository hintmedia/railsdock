# Railsdock

A generic Dockerized Rails Development Environment

## Setup

* Clone the repo
* Copy `env-example` to `.env`
* Modify the `.env` to point to host directeries for each service on your machine. It defaults to the repo names at the same directory level as `railsdock`.
> Note: only keys that are needed for build or general environment should be added here. All other environment variables should be placed in service specific `.env` files.
* `docker-compose build` this will take awhile to build images for each service.
* Bring up the specific services you need for example: `docker-compose up ruby postgres`. `docker-compose config --services` will list currently available services.

## Misc Notes

### Database
`psql` is installed by default in the ruby container.

* Import postgres database dump(based on `docker-compose up ruby postgres` has been run at least and a database has been created)

```sh
docker ps | grep app
docker cp path/to/dump.sql NAME_FROM_PREVIOUS_STEP:dump.sql
docker-compose down
docker-compose run app bash #This starts ruby and any dependent containers.

psql -U postgres -h postgres YOUR_DEV_DATABASE_NAME < dump.sql
```

### Todo

There is a lot to do to make this project awesome. PRs wanted and welcomed.
