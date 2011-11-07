
.data
fout:		.asciiz "test.txt"
buffer:		.asciiz "The quick brown over jumps fox the lazy dog."
liveChar:	.asciiz "X"
headChar: 	.asciiz "O"
newLine:	.asciiz "\r\n"

.text
# Open file for writing
li	$v0,  13	# syscall for open file
la	$a0,  fout	# file name
li	$a1,  1		# file I/O type: writing (0 for read)
li	$a2,  0		# file I/O mode (not needed for writing)
syscall
move	$s6,  $v0	# Save the file descriptor

# Write to the file
li	$v0,  15	# syscall: write to file
move	$a0,  $s6	# file descriptor
la	$a1,  buffer	# buffer from which to write
li	$a2,  44	# hardcoded buffer length
syscall

# Close the file
li	$v0,  16	# syscall: close file
move	$a0,  $s6	# file descriptor
syscall

# Output Memory Procedure
			# $a0 = numRows
			# $a1 = numCols
			# $a2 = starting address of the grid
