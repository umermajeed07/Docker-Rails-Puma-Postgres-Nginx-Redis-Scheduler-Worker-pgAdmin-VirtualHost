#!/bin/bash -l
set -e

# Start doing anything after postgres is ready!
while ! PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -d "${POSTGRES_DB}" -U "${POSTGRES_USER}" --command="SELECT 1">/dev/null 2>&1; do
  echo "waiting for ${POSTGRES_HOST} "
  sleep 1
done

function install() {
  echo "RUNNING MIGRATIONS"
  bundle exec rake db:migrate RAILS_ENV=development
}


function server() {
  bundle exec puma --dir "${RAILS_DIR}" -e development -p 3000 -C "${RAILS_DIR}/config/puma.rb"
}

function worker() {
  bundle exec rake resque:work
}

function scheduler() {
  bundle exec rake resque:scheduler 
}

case "$1" in
  "install")
    install
    ;;
  "server")
    server
    ;;
  "worker")
    worker
    ;;
  "scheduler")
    scheduler
    ;;
  *)
    echo "Unknown Action"
    exit 1
    ;;
esac
