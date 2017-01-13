// Include the Ruby headers and goodies
#include "ruby.h"

#define MIN3(a, b, c) ((a) < (b) ? ((a) < (c) ? (a) : (c)) : ((b) < (c) ? (b) : (c)))

// Defining a space for information and references about the module to be stored internally
VALUE Mylev = Qnil;

// Prototype for the initialization method
void Init_Mylev();

// Prototype for our method 
VALUE method_mydist(VALUE self, VALUE s1, VALUE s2);

// The initialization method for this module
void Init_Mylev() {
	Mylev = rb_define_module("Mylev");
	rb_define_singleton_method(Mylev, "mydist", method_mydist, 2);
}

VALUE method_mydist(VALUE self, VALUE s1, VALUE s2) {

    unsigned int s1len, s2len, x, y, lastdiag, olddiag;
    s1len = RSTRING_LEN(s1);
    s2len = RSTRING_LEN(s2);
    unsigned int column[s1len+1];
    for (y = 1; y <= s1len; y++)
        column[y] = y;
    for (x = 1; x <= s2len; x++) {
        column[0] = x;
        for (y = 1, lastdiag = x-1; y <= s1len; y++) {
            olddiag = column[y];
            column[y] = MIN3(column[y] + 1, column[y-1] + 1, lastdiag + (RSTRING_PTR(s1)[y-1] == RSTRING_PTR(s2)[x-1] ? 0 : 1));
            lastdiag = olddiag;
        }
    }

	return INT2NUM(column[s1len]);
}

