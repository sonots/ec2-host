#!/bin/sh
bundle exec yardoc
rsync -au --delete doc/ /tmp/doc
git checkout gh-pages
rsync -au --delete /tmp/doc/ doc
