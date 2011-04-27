CHPLCC=chpl

chapel_project: src/main.chpl
	chpl -o chapel_project src/main.chpl

.PHONY: clean

clean:
	rm chapel_project
