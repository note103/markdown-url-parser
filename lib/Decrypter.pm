package Decrypter;
use strict;
use warnings;
use feature 'say';

use parent 'Exporter';
our @EXPORT = qw/decrypt/;

our $VERSION = "0.01";

our $regex = qr!((goo\.gl|https?://t\.co|fb\.me|youtu\.be|amzn\.to|bit\.ly|ift\.tt|htn\.to)[^\s,;>\]]+)!;


sub decrypt {
    my $data = shift;
    my @data = @$data;

    my $data_pre; my $data_post; my $url;
    my @decrypted; my $decrypted_line;
    my $checker;

    for my $bookmark (@data) {
        chomp $bookmark;
        # say $bookmark;

        if ($bookmark =~ m!\A(.*)(http[^\s\]]+)(.*)\z!) {
            $data_pre = $1 //= '';
            $url = $2 //= '';
            $data_post = $3 //= '';

            if ($url =~ /$regex/) {
                $checker = LWP::UserAgent->new->get($url);
                $url = $checker->request->uri;
            }

            $decrypted_line = $data_pre.$url.$data_post;
            push @decrypted, $decrypted_line;
            # warn $decrypted_line;
        }
        else {
            say "Error.";
        }
    }

    return \@decrypted;
}


1;
