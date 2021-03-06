CHPLCC = chpl
SOURCES := $(shell ls src/*chpl)
OBJ_DIR := obj
TARGET := chapel_project

$(TARGET): $(SOURCES)
	$(CHPLCC) -o $@ src/main.chpl

test_app: $(SOURCES)
	$(CHPLCC) -o test_app src/test_tree.chpl

$(OBJ_DIR):
	mkdir $(OBJ_DIR)

test_node_pool_app: $(SOURCES)
	$(CHPLCC) -o $@ src/test_node_pool.chpl

test_node_pool: test_node_pool_app
	./test_node_pool_app

clean:
	rm -rf $(TARGET) test_app obj

INPUTS := $(shell bin/inputs.py -d)
# re-make inputs dependencies every time - i need a better way to do this...
INPUTS_DUMMY := $(shell bin/inputs.py -D > test_inputs.D)
-include test_inputs.D
inputs: $(INPUTS)
	@echo -n "" # dummy command just so make doesn't whine

test: $(TARGET) inputs | $(OBJ_DIR)
	test/correctness.sh

benchmark: $(TARGET) inputs | $(OBJ_DIR)
	test/benchmark.sh

.PHONY: clean test

