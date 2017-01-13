#!/usr/bin/perl -w

use Inline C;
use List::MoreUtils qw( minmax );
use strict;

my $string1 = "testme123";
my $string2 = "testme321";
my @list = (length($string1), length($string2));
my ($min, $max) = minmax @list;

print mylev($string1, $string2)/$max, "\n";

__END__
__C__
#include <string.h>

#define MIN3(a, b, c) ((a) < (b) ? ((a) < (c) ? (a) : (c)) : ((b) < (c) ? (b) : (c)))

int mylev(char* s1, char* s2) {

    unsigned int s1len, s2len, x, y, lastdiag, olddiag;
    s1len = strlen(s1);
    s2len = strlen(s2);
    unsigned int column[s1len+1];
    for (y = 1; y <= s1len; y++)
        column[y] = y;
    for (x = 1; x <= s2len; x++) {
        column[0] = x;
        for (y = 1, lastdiag = x-1; y <= s1len; y++) {
            olddiag = column[y];
            column[y] = MIN3(column[y] + 1, column[y-1] + 1, lastdiag + (s1[y-1] == s2[x-1] ? 0 : 1));
            lastdiag = olddiag;
        }
    }

	return column[s1len];
}

