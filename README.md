# Railsdock

A generic Dockerized Rails Development Environment

## Setup

* Clone the repo
* Run `id` and note the `uid` and `gid`
* Copy `env-example` to `.env`
* Update `RUBY_UID` and `RUBY_GID` in the `.env` with the values from previous step
* Update `APP_CODE_PATH_HOST` to point your Rails app. It defaults to a directory above `railsdock`.
> Note: only keys that are needed for build or general environment should be added here. All other environment variables should be placed in service specific `.env` files.
* `docker-compose build` this will take awhile to build images for each service.
* Bring up the specific services you need for example: `docker-compose up ruby postgres`. `docker-compose config --services` will list currently available services.

## Misc Notes

### Database
`psql` is installed by default in the ruby container.

* Import postgres database dump(This assumes a database has been created)

```sh
docker ps | grep app
docker cp path/to/dump.sql NAME_FROM_PREVIOUS_STEP:dump.sql
docker-compose down
docker-compose run ruby bash #This starts ruby and any dependent containers.

psql -U postgres -h postgres YOUR_DEV_DATABASE_NAME < dump.sql
```

### Todo

There is a lot to do to make this project awesome. PRs wanted and welcomed.
