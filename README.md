## Setting Up Production Server

This is for Ubuntu 16.04.6 LTS on DigitalOcean.

### Install Erlang and Elixir

```bash
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt-get update
sudo apt-get install esl-erlang elixir=1.10.3-1
```

### Install node

```bash
curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get install nodejs
node -v # -> 12.x.x
```

### Make the dir

```bash
cd /srv/www
sudo mkdir logs.wwsac.com
sudo chown rockwell:rockwell logs.wwsac.com
cd logs.wwsac.com

# Clone the repo
git clone git@github.com:schrockwell/lumberyard.git
```

### Install deps

```bash
cd /srv/www/logs.wwsac.com/lumberyard
mix deps.get

cd assets
npm i
```

###  Make an `.env` file

```
MIX_ENV=prod
PORT=4000
DATABASE_URL=postgresql://...
SECRET_KEY_BASE=...
ADMIN_PASSWORD=...
```

Put the database cert into `priv/ca-certificate.crt`

### Compile and run

```
export $(cat .env | xargs)
mix local.rebar
mix compile

mkdir priv/static
npm run deploy --prefix ./assets
mix phx.digest

mix phx.server
```

## Setting up the database

With a DigitalOcean user `lumber` and database `lumber_prod`, to give access:

```sql
grant all privileges on database lumber_prod to lumber;
alter user lumber createdb;
```
