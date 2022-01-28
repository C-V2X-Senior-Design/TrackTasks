import os
import sys
import binascii
import struct


'''

High Level Idea: 

*** This script is called from ~/Desktop/barrage_jammer_detection.sh. ***

The idea here is that if a coordinate is within the bounds of
real_lb < real(complex_val) < real_ub, and 
imag_lb < complex_value(b) < imag_ub
then the energy at that point is too low (??) and the signal
is considered disconnected. 
Conversely, if a coordinate is beyond these bounds, then the
signal is connected. For now, we only care about whether the
connection is on or off, so this program serves to generate a 
square wave. 1 = On, 0 = Off. 

Future Work/Improvements: The algorithm proposed here considers 
L1 distance. Improvements will use L2 distance, i.e. dis/connect
is evaluated from the magnitude of a coordinate. 

'''


# Set file handle to stdout file descriptor
fh = sys.stdout 

# Set the threshold values to determine connect/disconnect (+0.5/-0.5 for now)
imag_ub = 0.5
imag_lb = -0.5
real_ub = 0.5
real_lb = -0.5 

# Initialize list to hold square wave values
sqw = [] 

# TODO: Block the process until the stdout from shell has output
# while stdout is empty, block

while (True): # replace 'True' with conditional for standard output buffer
	# pass
	# print("here~!")

	for line in fh: 
		# Extract header information from first four hex of line
		if line[0:4] == "7363":
			header = "pusch"
		elif line[0:4] == "6363":
			header = "pucch"

		# Left pad 'line' with 0s to be 16 hex digits in length for  
		# compatiblility with unhexlify
		line.zfill(16)


		# Convert hexadecimal to binary. '>' means big-endian,
		# 'ff' means convert to double-precision floating point 
		binary_pair = struct.unpack('>ff', binascii.unhexlify(line))

		# Compare coordinates of binary_pair to bounds to determine connectivity
		if (binary_pair.first > real_lb && binary_pair.first < real_ub):
			if (binary_pair.second > imag_lb && binary_pair.second < imag_ub):
				sqw.append(0)	# The data point indicates a disconnection, append 0 to sqw list
		else: 
			sqw.append(1)	# Connected



	# TODO: Get signal from shell that it has terminated epc, enb, and ue processes
	# and prepare a graceful shutdown of python program


# TODO: Plot the graph 

