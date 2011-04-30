#! /usr/bin/env python

import sys,os,inspect
from subprocess import call,PIPE

INPUTS_DIR = 'inputs'
EXTENSION = 'txt'

def input_name_from_func_name(func_name):
	"""
	this is where we'll generate the cannonical output name from a function
	name.  right now that just means that we strip the 'make_' from the
	beginning of the function name, add INPUTS_DIR, and tack EXTENSION on to
	the end
	"""
	return os.path.join(INPUTS_DIR, ''.join(func_name.split('make_')[1:])) \
			+ '.%s' % EXTENSION

def this_func_input_name():
	"""
	when you're in a function like "make_test_input_10", this will generate the
	correct name for the input file that the function should generate.  so if
	you call this when you're in:
		
		make_test_input_10

	then it will return:

		inputs/test_input_10.txt

	(assuming INPUTS_DIR == 'inputs' and EXTENSION == 'txt'
	"""
	return input_name_from_func_name(inspect.stack()[1][3])

def get_functions():
	"""
	this just returns a list of all the functions that start with "make_"
	"""
	return [f for f in globals() if f.startswith('make_')]

def download(url, save_as):
	"""
	since many of our inputs are just downloaded from some url, this provides
	an easy wrapper around saving a url to a file
	"""
	if call(['wget', '-O', save_as, url], stderr = PIPE) != 0:
		raise Exception('could not download %s to %s' % (url, save_as))

def make_test_input_10():
	download(
		'http://www.cs.utexas.edu/users/akanksha/cs380p/assn5/input_10.dat',
		this_func_input_name())

def make_test_input_10_golden():
	download(
		'http://www.cs.utexas.edu/users/akanksha/cs380p/assn5/output_10.dat',
		this_func_input_name())

def make_test_input_50():
	download(
		'http://www.cs.utexas.edu/users/akanksha/cs380p/assn5/input_50.dat',
		this_func_input_name())

def make_test_input_50_golden():
	download(
		'http://www.cs.utexas.edu/users/akanksha/cs380p/assn5/output_50.dat',
		this_func_input_name())

def make_test_input_100():
	download(
		'http://www.cs.utexas.edu/users/akanksha/cs380p/assn5/input_1000.dat',
		this_func_input_name())

def make_test_input_100_golden():
	download(
		'http://www.cs.utexas.edu/users/akanksha/cs380p/assn5/output_1000.dat',
		this_func_input_name())

def make_test_input_1():
	download(
		'http://www.cs.utexas.edu/users/akanksha/cs380p/assn5/test_input_1_v2.in',
		this_func_input_name())

def make_test_input_2():
	download(
		'http://www.cs.utexas.edu/users/akanksha/cs380p/assn5/test_input_2_v2.in',
		this_func_input_name())

def make_test_input_3():
	download(
		'http://www.cs.utexas.edu/users/akanksha/cs380p/assn5/test_input_3_v2.in',
		this_func_input_name())

def make_test_input_4():
	download(
		'http://www.cs.utexas.edu/users/akanksha/cs380p/assn5/test_input_4_v2.in',
		this_func_input_name())

def Usage(ret_val = 0):
	sys.stderr.write("""
USAGE: %s [options]

OPTIONS:
	-D				print makefile dependencies
	-d				print list of all inputs files
	-f <function>	make output for specified funciton (see below)
	
If no arguments are given, then all outputs will be made.

MAKEFILE ADDITIONS:

In order to use this you'll probably need to add a couple lines to your
makefile:

INPUTS := $(shell %s -d)
# re-make inputs dependencies every time - i need a better way to do this...
INPUTS_DUMMY := $(shell %s -D > test_inputs.D)
-include test_inputs.D
inputs: $(INPUTS)
	@echo -n "" # dummy command just so make doesn't whine

AVAILABLE FUNCTIONS:

%s""" % (sys.argv[0], sys.argv[0], sys.argv[0], '\n'.join(get_functions())))
	sys.exit(ret_val)

def main():

	def make_dir():
		if not os.path.isdir(INPUTS_DIR):
			os.makedirs(INPUTS_DIR)

	if len(sys.argv) > 1:
		if sys.argv[1] == '-D':
			make_dir()
			for f in get_functions():
				print '%s:' % input_name_from_func_name(f)
				print '\t%s -f %s' % (sys.argv[0], f)
				print ''
			sys.exit(0)
		elif sys.argv[1] == '-d':
			for f in get_functions():
				print '%s' % input_name_from_func_name(f)
			sys.exit(0)
		elif sys.argv[1] == '-f':
			make_dir()
			if sys.argv[2] not in globals():
				Usage(1)
			globals()[sys.argv[2]]()
			sys.exit(0)
		else:
			Usage()

	make_dir()
	[ globals()[f]() for f in get_functions() ]

if __name__ == '__main__': main()
