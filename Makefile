all: ex

ex: 
	emcc Projet/src/ex.ll --js-library libraries/p5-wrap.js -s EXPORTED_FUNCTIONS="['_my_draw','_my_setup']" -o foo.js

mandelbrot: 
	emcc Projet/src/mandelbrot.ll --js-library libraries/p5-wrap.js -s EXPORTED_FUNCTIONS="['_my_draw','_my_setup']" -o foo.js

.PHONY: clean

clean:
	rm -f foo.js *~
