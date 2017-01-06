LEX=lex
YACC=bison
CFLAGS=-Wall
CC=gcc


all:parse

parse:grammar.c scanner.c type.c utils.c expr.c liste.c hachage.c
	$(CC) $(CFLAGS) -o $@ $^

grammar.c:grammar.y
	$(YACC) -t -d -o $@ --defines=grammar.tab.h $^

%.c:%.l
	$(LEX) -o $@ $^

test: parse
	@for i in `seq 1 30`; \
	do \
		./parse "../tst/test"$$i".c" > "../tst/resbis"$$i".txt"; \
	done; \
	bash script.sh

ex: parse
	./parse ex.c
	emcc ex.ll --js-library libraries/p5-wrap.js -s EXPORTED_FUNCTIONS="['_my_draw','_my_setup']" -o foo.js

mandelbrot: parse
	./parse mandelbrot.c
	emcc mandelbrot.ll --js-library libraries/p5-wrap.js -s EXPORTED_FUNCTIONS="['_my_draw','_my_setup']" -o foo.js


clean:
	rm -f grammar.c scanner.c *~ parse *.ll ../tst/*.ll ../tst/resbis* foo.js
