#!/bin/sh

git pull
./app/builder.pl
git add .
git ci -m 'Rebuilt'
git push


