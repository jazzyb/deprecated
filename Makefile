SRC_FILES = src/view.coffee
LIB_FILES = lib/view.js
TARGET = lib/all.js

COMPILER = coffee
OBFUSCATER = java -jar bin/closure/compiler.jar
OPT_FLAGS = --compilation_level=ADVANCED_OPTIMIZATIONS
JS_FILES = $$(for js in $(LIB_FILES); do echo -n "--js=$$js "; done)

build: $(SRC_FILES)
	mkdir -p lib
	$(COMPILER) --bare --lint --output lib/ --compile src/
	bash -c '$(OBFUSCATER) $(OPT_FLAGS) $(JS_FILES) --js_output_file=$(TARGET)'

clean:
	rm -rf lib/
