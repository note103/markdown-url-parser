package WebScraper;
use strict;
use warnings;
use feature 'say';

use Decrypter;

use Encode qw/encode decode find_encoding/;
use Encode::Guess qw/cp932 euc-jp/;
use LWP::UserAgent;
use LWP::Protocol::https;
use Try::Tiny;
use List::MoreUtils 'uniq';

use parent 'Exporter';
our @EXPORT = qw/scrape/;

our $VERSION = "0.01";

my $regex = $Decrypter::regex;

sub scrape {
    my $url_catch = shift;
    my $target = shift;

    my @material;
    my @urls;

    # 調査対象が単数か複数かチェック
    if (ref $url_catch eq 'ARRAY') {
        @material = @$url_catch;
    }
    else {
        push @material, $url_catch;
    }

    # URL確認
    for my $elem (@material) {
        chomp $elem;
        next if ($elem =~ /\A\z/);

        if ($elem =~ /$regex/) {
            $elem = "http://$1";
        }
        push @urls, $elem;
    }

    # 短縮URLを復号
    my $decrypted_data = decrypt(\@urls);
    @urls = @$decrypted_data;

    # URLが重複していたらカット
    @urls = uniq @urls;

    # スクレイピング
    my $agent = LWP::UserAgent->new;

    my %bookmark;
    for my $url (@urls) {

        my $res   = $agent->get($url);

        # 対象ページの文字コード確認
        my $content = $res->header('Content-Type');
        my @encode  = qw/utf-8 cp932 euc-jp/;
        my $char;
        for my $encode (@encode) {
            if ($content =~ /charset=['"]?($encode)/i) {
                $char = $1
            }
        }

        # 目的のデータを取得
        my $data_get;
        if ($target eq 'title') {
            $data_get = $res->title();
        }
        elsif ($target eq 'body') {
            $data_get = $res->decoded_content();
            $data_get = encode('utf-8', $data_get);
        }
        $data_get = "No $data_get" unless ($data_get);

        # 文字コードが判明していない場合の変換
        if (! $char) {
            my $decoder = Encode::Guess->guess($data_get);
            try {
                ref ($decoder) or die "Can't guess: $decoder";
                $data_get = $decoder->decode($data_get);
            }
            catch {
                $data_get = decode('utf-8', $data_get);
            };
            $data_get = encode('utf-8', $data_get);
        }

        # 出力用データ整形
        my $data_result;
        if ($target eq 'title') {
            $bookmark{$url} = $data_get;
        }
        elsif ($target eq 'body') {
            $bookmark{contents} = $data_get;
        }
    }
    return \%bookmark;
}


1;
