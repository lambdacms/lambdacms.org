The lambdacms.org website's code
================================

This repository contains all packages making up the
[lambdacms.org](http://lambdacms.org) website, which are:

* **`lambdacms-base`** -- a LambdaCms flavored [Yesod](http://yesodweb.com)
  application which will serve the site, acts as a host for the LambdaCms
  *extensions* (each usually providing their own admin interface) and
  contains the styling for the content types (mostly they are provided by the
  *extensions*). Hence this repository contains largely CSS code.
* **`lambdacmsorg-page`** -- *extension* providing the lambdacms.org specific "page"
  content type and accompanying admin interface section.
* **`lambdacmsorg-tutorial`** -- *extension* providing the lambdacms.org specific
  "tutorial" content type and accompanying admin interface section.

LambdaCms *extensions* are merely LambdaCms specific Yesod
subsites, and are dependecies of this "base" app. Apart from the *extensions*
that in this repository the lambdacms.org website also make use of:

* The [`lambdacms-core`](https://github.com/lambdacms/lambdacms) *extension*
  which provides the "core" LambdaCms admin interface functionality.

In the future we also plan to make use of
[`lambdacms-media`](https://github.com/lambdacms/lambdacms) *extension*,
providing media (pictures, etc.) management functionality.


## Install

For the lambdacms.org site we use
[`stack`](https://github.com/commercialhaskell/stack)
to greatly simplify the build/install process, while increasing the
reliability.

First make sure to have a recent version of
[`stack`](https://github.com/commercialhaskell/stack) installed.

This project assumes Postgres as a database. For instructions setting up
Postgress for the use with LambdaCms please refer to the
[README of lambdacms-core](https://github.com/lambdacms/lambdacms-core).
Without setting up Postgress the buld step will complain `pg_config` is
missing.


```bash
git clone https://github.com/lambdacms/lambdacms.org
cd lambdacms.org/lambdacmsorg-base

stack setup    ;# installs GHC 7.10 if not already installed
stack install  ;# builds and installs the lambdacmsorg website

lambdacmsorg   ;# starts the server
```

Now fire some requests at it by pointing your browser to:
[`http://localhost:3000/admin`](http://localhost:3000)


## License

The files in this repository are MIT licensed, as specified in the
[LICENSE file](https://github.com/lambdacms/lambdacms.org/blob/master/LICENSE).
