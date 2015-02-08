lambdacms.org-base
==================

This repository contains the "base" [Yesod](http://yesodweb.com) application
for the LambdaCms-based [lambdacms.org](http://lambdacms.org) website.

All LambdaCms *extensions* (which are LambdaCms specific Yesod subsites) are
dependecies of this "base" app, and are hooked up from here.

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


## License

The files in this repository are MIT licensed, as specified in the
[LICENSE file](https://github.com/lambdacms/lambdacms.org-base/blob/master/LICENSE).
