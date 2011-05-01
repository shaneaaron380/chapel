#! /usr/bin/env python

import sys,os

def Usage():
	print('USAGE: %s <output file> <golden output file>' % sys.argv[0])
	sys.exit(1)

def main():
	if sys.argv[1] == '-h' or sys.argv[1] == '--help' or len(sys.argv) != 3:
		Usage()

	def c(a, b):
		if float(a[0]) < float(b[0]):
			return -1
		elif float(a[0]) > float(b[0]):
			return 0
		else:
			if float(a[1]) < float(b[1]):
				return -1
			elif float(a[1]) > float(b[1]):
				return 1
			else:
				return 0

	o_file = open(sys.argv[1])
	o_len = int(o_file.readline())
	o = sorted([ (l.split()[0], l.split()[1]) for l in o_file ], cmp = c)

	g_file = open(sys.argv[2])
	g = ( i for i in sorted([ (l.split()[0], l.split()[1]) for l in g_file ],
		cmp = c) )

	def is_not_acceptable(a, b):
		p = 2 # precision
		if str(round(float(a[0]), p)) != str(round(float(b[0]), p)) or \
				str(round(float(a[1]), p)) != str(round(float(b[1]), p)):
			#print 'ERROR:', str(round(float(a[0]), p)), str(round(float(a[1]), p)), str(round(float(b[0]), p)), str(round(float(b[1]), p))
			sys.stderr.write('ERROR: %s != %s\n' % (str(a), str(b)))
			return 1
		else:
			return 0

	count = 0
	errors = 0
	for i in o:
		errors += is_not_acceptable(i, g.next())
		count += 1

	assert(count == o_len)

	print 'total mismatches: %d' % errors
		
	return

if __name__ == '__main__': main()
