#!/usr/bin/env perl
use Mojo::Base -strict, -signatures;

while (1) {
    my $out = `git pull 2>&1`;
    say "---> $out <---;
    `./app/builder.pl`;
    `git add .`;
    `git ci -m 'Rebuilt'`;
    `git push`;
    sleep 120;
}
