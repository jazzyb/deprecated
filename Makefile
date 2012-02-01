LIB_FILES = lib/view.js
TARGET = lib/all.js

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

clean:
	rm -rf lib/
