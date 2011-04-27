CHPLCC=chpl

hello: src/main.chpl
	chpl -o hello src/main.chpl
