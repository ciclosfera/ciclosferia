#!/usr/bin/env perl
use Mojo::Base -strict, -signatures;
use Mojo::File;
use Mojo::Template;
use Text::Markdown;
use DateTime;
use FindBin;
use Data::Dump qw/pp/;

my $root_dir     = Mojo::File->new("$FindBin::Bin/../docs/");
my $template_dir = Mojo::File->new("$FindBin::Bin/templates/");
my $content_dir  = Mojo::File->new("$FindBin::Bin/../content/");
my $images_dir   = $content_dir->child('image/');

my $events     = read_source('event');
my $pages      = read_source('page');
my $expositors = read_source('expositor');

my $template = get_template('event');
$events->each(sub($e, $idx){
    my $dest_dir = $root_dir->child('event', $e->{slug});
    $dest_dir->make_path;

    my $dest = $dest_dir->child('index.html');
    say 'Event ', $e->{slug}, ': ', $dest;
    $dest->spurt($template->process($e));
});

sub get_template($name) {
    my $mt = Mojo::Template->new(vars => 1);
    $mt->parse($template_dir->child("$name.html.ep")->slurp);
    $mt;
}

sub read_source($type) {
    my $dir = $content_dir->child($type . '/');
    $dir->list->map(sub($file){ read_content($file, $type) });
}

sub read_content($file, $type) {
    my $out = { slug => $file->basename, type => $type };
    $out->{slug} =~ s/\..+$//;

    if ( exists $out->{at} && $out->{at} =~ m|(\d+)/(\d+)/(\d{4})\s+(\d+):(\d+)| ) {
        $out->{start_at} = DateTime->new(
            day       => $1,
            month     => $2,
            year      => $3,
            hour      => $4,
            minute    => $5,
            time_zone => 'Europe/Madrid'
        );

        if ( my $dur = exists $out->{duration} && $out->{duration} ) {
            $out->{end_at} = $out->{start_at}->clone->add( minutes => $dur );
        }
    }

    my $on_head = 1;
    for my $line ( split(/\n/, $file->slurp ) ) {
        if ( $on_head && $line =~ /([^\s:]+)\s*:\s*(.+?)\s*$/ ) {
            $out->{meta}{lc($1)} = $2;
        }
        elsif ( $on_head && $line =~ /^\s*\-+\s*$/ ) {
            $on_head = 0;
        }
        else {
            $on_head = 0;
            $out->{src} .= "$line\n";
        }
    }

    $out->{body} = Text::Markdown->new->markdown( $out->{src} );

    $out;
}
