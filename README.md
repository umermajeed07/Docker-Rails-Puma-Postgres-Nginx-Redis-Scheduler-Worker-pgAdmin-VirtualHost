# Ruby on Rails Docker
This file introduce usage of our Docker images. 

## Dependencies
- Images build against **Redis**, **NGINX**, **Scheduler**, **Worker**, **pgAdmin** and **Postgres**. 

## DATABASE YML 
Replace the below config in the config/database.yml file

```
development:
    adapter: postgresql
    encoding: unicode
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
    host: <%= ENV['POSTGRES_HOST'] %>
    username: <%= ENV['POSTGRES_USER'] %>
    password: <%= ENV['POSTGRES_PASSWORD'] %>
    database: <%= ENV['POSTGRES_DB'] %>
    port: <%= ENV['POSTGRES_PORT'] %>
```

## ENV variables
In default you need pass database setup in following env variables:

* `WEB_IMAGE` = docker image name (use ruby:v1)
* `POSTGRES_HOST` = ip to your database server (use service name of postgres)
* `POSTGRES_PORT` = port of postgres database (default: 5432)
* `POSTGRES_DB` = name of your database
* `POSTGRES_USER` = user name to your postgres server
* `POSTGRES_PASSWORD` = postgres
* `REDIS_HOST` = hostname of redis server (use service name of redis)
* `REDIS_PORT` = port of redis server (default: 6379)
* `DATA_PATH` = path to folder to mount volumes (i.e linux: /home/ubuntu/volumes-mount-data, windows: C:\volumes-mount-data)


## Sample ENV variables Values

```
    WEB_IMAGE=ruby:v1
    POSTGRES_HOST=postgres
    POSTGRES_PORT=5432
    POSTGRES_DB=database_name
    POSTGRES_USER=postgres
    POSTGRES_PASSWORD=postgres
    REDIS_HOST=redis
    REDIS_PORT=6379
    DATA_PATH=/home/ubuntu/volumes-mount-data
```

## Volume Mount Folder

* Create volume-mount-data folder.
* Create `sql-data`, `postgres-data`, `redis-data` and `pgadmin-data` folders inside `volumes-mount-data` folder.
* For linux assign respective permissions and user groups if needed.
* Add sql dump in sql-data folder for importing database. (If need to import database on initial docker startup)

```
chmod 777 -R volumes-mount-data

```


## Add NGINX conf
Create `nginx.conf` file in config folder and paste the below content into the file, and change the project public path below

* File: `nginx.conf`

```
upstream rails-app {
  server web:3000;
}

server {
    listen 80;
    server_name app.my-app.test;

    root /home/ubuntu/projects/app-project/public; # project path

    location / {
        try_files $uri @rails-app;
    }

    location @rails-app {
        proxy_pass http://rails-app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```


## Add below in development.rb

```
config.hosts << "app.my-app.test"
```


## Change the following in the file

* `config/initializers/resque.rb` 'redis://localhost:6379/' => 'redis://redis:6379/'


## Add host in *hosts* file

* Windows Path: `c:\Windows\System32\Drivers\etc\`
* MacOS: `nano /private/etc/hosts`

```
127.0.0.1      app.my-app.test
::1            app.my-app.test
```

## Getting Started 

## MakeFile Way

* Build Image
```Bash
    make build
```

* Start Docker Containers to run App
```Bash
    make run-server
```

* View All Make Comands
```Bash
    make help
```

## OR

### Build image

```bash
docker build . -t image_name:version
```

## docker-compose way
This way contains whole stack and migrations, so there are no additional steps. After you set .env file, you can manage whole stack simple by `docker-compose`

```Bash
docker-compose up -d                    # start and run containers in background
docker-compose up                       # start and run containers
docker-compose log -f                   # see all logs
docker-compose ps -a                    # see containers state
docker-compose restart service_name     # restart container
docker-compose down                     # stop whole stack
docker-compose down -v                  # stop whole stack and REMOVE data!!!
```

### Import Database
Import database into the database created from the sql dump obtained from server or locally, and run migrations using the app-migration service mentioned below.


### docker executing bash and running commands with containers for app service
```Bash
docker exec -it container_name bash     # running bash for specific service by container name
docker exec -t app_name rails db:migrate  # running rails command in app web service (sample command for migrating database)
```

### Running only migrations
```Bash
docker-compose up app-migration # execute in new window
```

### Access site
* http://app.my-app.test/
* http://localhost:5050 `# pgAdmin URL`