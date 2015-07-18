lambdacms.org-base
==================

This repository contains the "base" [Yesod](http://yesodweb.com) application
for the LambdaCms-based [lambdacms.org](http://lambdacms.org) website.
A typical "base" app in a LambdaCms-site contains mainly the styling for the
content types which the *extensions* implement and provide admin interface
sections for. Hence this repository contains mostly CSS code.

All LambdaCms *extensions* (which are merely LambdaCms specific Yesod
subsites) are dependecies of this "base" app, and are wired-up up from here.

Currently it makes use of the following extensions:

* [`lambdacms-core`](https://github.com/lambdacms/lambdacms-core) --
  providing the core LambdaCms admin interface functionality.
* [`lambdacms.org-page`](https://github.com/lambdacms/lambdacms.org-page) --
  providing the lambdacms.org specific "page" content type and accompanying
  admin interface section.
* [`lambdacms.org-tutorial`](https://github.com/lambdacms/lambdacms.org-tutorial) --
  providing the lambdacms.org specific "tutorial" content type and accompanying
  admin interface section.

We plan to also make use of:

* [`lambdacms-media`](https://github.com/lambdacms/lambdacms-media) --
  providing media (pictures, etc.) management functionality.


## Installing

```
git clone https://github.com/lambdacms/lambdacms.org-page.git     lambdacmsorg-page
git clone https://github.com/lambdacms/lambdacms.org-tutorial.git lambdacmsorg-tutorial
git clone https://github.com/lambdacms/lambdacms.org-base.git     lambdacmsorg-base

cd lambdacms.org-base

stack setup    ;# installs GHC 7.10 if not already installed
stack install  ;# builds and installs the lambdacmsorg website

lambdacmsorg   ;# starts the server to serve the site

```

This project assumes Postgres as a database. For instructions setting up
Postgress for the use with LambdaCms please refer to the
[README of lambdacms-core](https://github.com/lambdacms/lambdacms-core).
Without setting up Postgress the buld step will complain `pg_config` is
missing.


## License

The files in this repository are MIT licensed, as specified in the
[LICENSE file](https://github.com/lambdacms/lambdacms.org-base/blob/master/LICENSE).
