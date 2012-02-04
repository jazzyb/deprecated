LIB_FILES = lib/view.js
TARGET = lib/forchess.js

COMPILER = coffee
CFLAGS = --bare --lint
OBFUSCATER = java -jar bin/closure/compiler.jar
OPT_FLAGS = --compilation_level=ADVANCED_OPTIMIZATIONS
JS_FILES = $$(for js in $(LIB_FILES); do echo -n "--js=$$js "; done)

lib/%.js: src/%.coffee
	$(COMPILER) $(CFLAGS) --output lib/ --compile $<

# calling bash here because I need a subshell to be called for JS_FILES
build: $(LIB_FILES)
	bash -c '$(OBFUSCATER) $(OPT_FLAGS) $(JS_FILES) --js_output_file=$(TARGET)'


TEST_FILES = test/js/test_view.js

test/js/test_%.js: test/coffee/test_%.coffee
	$(COMPILER) $(CFLAGS) --output test/js/ --compile $<

test: $(LIB_FILES) $(TEST_FILES)
	ln -sf test/index.html test.html


clean:
	rm -rf lib/ test.html test/js/
