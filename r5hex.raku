#!/usr/bin/env raku

use Red;
use Digest::MD5;

##############
# CLI handling

unit sub MAIN(
    Str  $file,                      #= Path to file containing hashes to be loaded
    Str  :d(:$db)   = 'hashes.db',   #= Database file path
    Str  :i(:$ip)   = 'localhost',   #= Bind to this address
    UInt :p(:$port) = 9988,          #= Bind to this port
);

##########
# DB Setup

model MD5Entry is table<md5entry> {
    has Int $!id        is serial;
    has Str $.hexdigest is unique;
    has Str $.plain     is column is rw = "";
}

red-defaults 'SQLite', :database($db);
MD5Entry.^create-table(:if-not-exists);

for $file.IO.lines.grep(/<[a..z A..Z 0..9]> ** 32/) -> $hexdigest {
    try MD5Entry.^create(:$hexdigest);
}
unless MD5Entry.^all.grep(!*.plain) {
    say "All hashes are already cracked, exiting...";
    exit;
}
say "Loaded {MD5Entry.^all.elems} hashes";

#################
# UDP Client loop

given IO::Socket::Async.bind-udp($ip, $port) -> $udp-sock {
    say "Listening on udp://$ip:$port, Database file is $db";

    $udp-sock.Supply(:datagram).tap: -> $c {
        my $caddr = "{$c.hostname}:{$c.port}";

        given $c.data.gist {
            when /^GIMME\n?$/ {
                if MD5Entry.^all.grep(!*.plain).pick -> $entry {
                    $udp-sock.print-to: $c.hostname, $c.port, $entry.hexdigest;
                    say "{$entry.hexdigest} [$caddr]";
                }
            }

            when /$<hexdigest> = <[a..z A..Z 0..9]> ** 32 \s $<plain> = .+/  {
                my ($hexdigest, $plain) = $<hexdigest>.Str, $<plain>.Str;
                say "[$caddr] '$hexdigest' => '$plain'";

                if md5($plain).map({sprintf("%02x", $_)}).join ~~ rx:i/$hexdigest/ {
                    try {
                        my $entry    = MD5Entry.^load(:$hexdigest);
                        $entry.plain = $plain;
                        $entry.^save;
                        $udp-sock.print-to: $c.hostname, $c.port, "Thanks !\n";
                        say "Thanks [$caddr]";
                        exit unless MD5Entry.^all.grep(!*.plain);
                    }
                }
            }
        }
    }
}

################
# CTRL-C to exit

react whenever signal(SIGINT) {
    say "\rBye !";
    done
}
