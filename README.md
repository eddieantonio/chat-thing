# Chat Thing
## Poorly documented, obligatory, long-polling chat thing in Node

# Install

Requires the following binaries:

 * `cofffe` -- `npm install -g coffeescript`
 * `up` -- `npm install -g up`

As well as the mongodb database client, mongodb.

Install package dependencies:

```sh
npm install
```

And setup the database:

```sh
mongo lib/setup-mongo.js
```

# Running

```sh
npm start
```

This will compile all CofffeeScript files and start the server with Up,
listening on port 3000.

