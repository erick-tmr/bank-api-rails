# Bank API

## Proposition

This project exposes a Restful API to create accounts and transfers between them.

## How to use

This project is configured to use Docker and docker-compose.

You need to provide a `.env` file at the project root.

The required ENV vars are:
- DATABASE_NAME
- DATABASE_USER
- DATABASE_PASSWORD
- DATABASE_HOST
- DATABASE_PORT

A sample `.env` file:
```
DATABASE_NAME=my_db
DATABASE_USER=root
DATABASE_PASSWORD=pass123
DATABASE_HOST=database
DATABASE_PORT=3306
```

To run it:  
`docker-compose up -d --build`

It should start the app service and the database service.  
For the first time building the services, you should create the databases and migrate it:  
`docker-compose exec app rails db:create`  
`docker-compose exec app rails db:migrate`

The API is exposed in the Rails default port 3000.

## Endpoints

The API is versioned through the URL param.

### V1 Endpoints

#### Protected actions

To authenticate the request, set the `Authorization` header in the request with the JWT token.

Example:
```
curl -X GET \
  http://localhost:3000/v1/accounts/1 \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJhY2NvdW50X2lkIjozMCwiZXhwIjoxNjA2MjMyMDgyfQ.BFK6W9R6Rytbk8-Di2fEoE8cRTKztT0uQYVcepycbZE'
```

#### POST /v1/accounts

It creates an account. This is not protected.

Body:
```json
{
  "account": {
    "id": 1 (optional),
    "name": "string",
    "balance": "100,00"
  }
}
```
The `balance` field expects numbers in the following formats:
- 100 -> R$ 100,00
- "100,00" -> R$ 100,00
- "100_000" -> R$ 100000,00
- "1_000,00" -> R$ 1000,00
- -100 -> R$ -100,00
- "-100,00" -> R$ -100,00
- "-100_000" -> R$ -100000,00
- "-1_000,00" -> R$ -1000,00

Any digit after the second decimal point is ignored:

Example:  
"100,12345" -> R$ 100,12

Response format:
```json
{
  "account": {
    "id": 30,
    "balance_cents": 900012,
    "balance_humanized": "R$9.000,12",
    "name": "some name"
  },
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJhY2NvdW50X2lkIjozMCwiZXhwIjoxNjA2MjMyMDgyfQ.BFK6W9R6Rytbk8-Di2fEoE8cRTKztT0uQYVcepycbZE"
}
```

The `balance_cents` represent the balance as an integer value, in cents.  
The `balance_humanized` represent the balance with its currency representation.  
The `token` is a JWT token, it should be used as authentication to the protected requests.  

#### GET v1/accounts/:account_id

It returns the requested account, this action is protected.

Response format:  
```json
{
  "account": {
    "id": 1,
    "balance_cents": 124000,
    "balance_humanized": "R$1.240,00",
    "name": "some name"
  }
}
```

#### POST v1/transfers

It creates a transfer between source account and destination account. This action is protected.

Body format:  
```json
{
  "transfer": {
    "source_id": 13,
    "destination_id": 265,
    "value": "2500,00"
  }
}
```

The `value` field accepts numbers in the same format as the `balance` from accounts. Any digit after the second decimal point is ignored.

Response format:
```json
{
  "transfer": {
    "id": 24,
    "initial_balance_cents": 124000,
    "initial_balance_humanized": "R$1.240,00",
    "value_cents": 2500,
    "value_humanized": "R$25,00",
    "destination_id": 2,
    "source_id": 1
  }
}
```
The `initial_balance` represents the source account balance before the transfer.

## Tests

To run the test suite:
`docker-compose run app rspec`

The tests are executed in the app service container context.

## Project dependencies

The notable dependencies of the projects are the follow:

- jwt, a gem to handle JWT. The JWT is a simple way of providing basic authentication to the app.
- money-rails, a gem to handle money values that integrates with Rails. This gem provides a lot of interesting helpers to handle money value, it save the values as integer on the database, to prevent calculation errors of floats, also handles currencies and conversion, it gives a nice defaults when handling money values.
- rspec, behavior driven test. It provides a lot of goodies to work with Rails application, supported by a lot of others projects integration, it is the standard testing library in the Rails ecossystem.
- factory-bot, populate the database with dummy values. It is a nice tool to setup tests with some data to the DB, also is highly customizable, it makes integration tests a lot easier.
- pry-rails, debbuging tool. A simple debbuging tool, it has nice features over byebug, like code syntax highlighting.
- timecop, a gem to handle time in tests. Timecop is a tool to handle time dependendant code. It can freeze or mutate time to fit the test needs.
- annotate, a gem to annotate models with its columns. This gem is very helpful, it annotates the models with its columns names, since they are not present by default, it really helps to have that when using the models.
