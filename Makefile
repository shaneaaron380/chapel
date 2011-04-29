CHPLCC=chpl
INPUTS := $(shell ls src/*chpl)

chapel_project: $(INPUTS)
	chpl -o chapel_project src/main.chpl

test_app: $(INPUTS)
	chpl -o test_app src/test_tree.chpl

test: test_app
	./test_app

.PHONY: clean test

clean:
	rm chapel_project
