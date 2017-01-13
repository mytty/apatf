#!/usr/bin/perl -w

use strict;

require "mylev.pm";

my $s1 = "superduperteststring123456789";
my $s2 = "superduperlkjsstring123456789";

print lev($s1, $s2), "\n";
