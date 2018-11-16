#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';
use FindBin;
use lib "$FindBin::Bin/lib";
use WebScraper;

# my $switch = 'markdown';
my $switch = 'scrapbox';

my @data = <DATA>;

my $result = scrape(\@data, 'title');
# my $result = scrape(\@data, 'body');

my @result;
my $title;

for (keys %$result) {
    if ($switch eq 'markdown') {
        push @result, "[$result->{$_}]($_)"
    }
    else {
        $title = $result->{$_};
        $title =~ s/\[(.+)\]/$1/g;
        push @result, "[$title $_]"
    }
}
say for @result;

__DATA__
https://www.google.co.jp/
https://twitter.com/
