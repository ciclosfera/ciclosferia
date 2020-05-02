#!/usr/bin/env perl
use Mojo::Base -strict, -signatures;
use Mojo::File;
use Mojo::Template;
use FindBin;

my $template_dir   = Mojo::File->new("$FindBin::Bin/templates/");
my $content_dir    = Mojo::File->new("$FindBin::Bin/../content/");
my $events_dir     = $content_dir->child('event/');
my $pages_dir      = $content_dir->child('page/');
my $expositors_dir = $content_dir->child('expositor/');
my $images_dir     = $content_dir->child('image/');

$events_dir->list->each(sub($e,$i){
    say $e->basename;
})

