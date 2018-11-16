#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';
use FindBin;
use lib "$FindBin::Bin/lib";
use WebScraper;

print "url >>> ";

my $data = <STDIN>;
my $result = scrape($data, 'title');

my @result;
my $title;
my $url;
for (keys %$result) {
    push @result, "[$result->{$_}]\\($_\\)";
    $title = $result->{$_};
    $url = $_;
}

print `echo $result[0] | pbcopy`;
say "Copied!: [$title]($url)";
