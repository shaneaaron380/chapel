CHPLCC=chpl
INPUTS := $(shell ls src/*chpl)

chapel_project: $(INPUTS)
	chpl -o chapel_project src/main.chpl

.PHONY: clean

clean:
	rm chapel_project
