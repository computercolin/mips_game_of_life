
.data
fout:		.asciiz "game_step.txt"
liveChar:	.asciiz "X"
headChar: 	.asciiz "O"
m			.byte 3
n			.byte 3
initWorld:	.asciiz "XOXOXXOOX"

.text

# This file currently loads an initial world through a hardcoded array in the top of this file. 
# It could also load an array from an outside file if we figure out how to do that.

# Place Initial Array in Memory

# Perform cellular automata

# Output Memory Procedure

for row=0; row < m; row++
{
	for col=0; col < n...
	{
		count = 0
		if (above alive)
			count +1
		if (right alive)
			count +1
		if (left alive)
			count +1
		if (below alive)
			count +1
		if (alive) {
			if (0 or 1) {
				dead
			}
			else if (2 or 3) {
				live
			}
			else if (4) {
				dead
			}
		} else (dead) { 
			if (3) {
				live
			}
		}


# takes 4 args, x, y, xOffset, yOffset, will return alive or dead
# requires that $s0 is starting address for grid in memory
getNeighbor:
	lw 	$t0,  m
	add 	$a0, $a0, $a2
	bgt	$a0, $t0, tooLargeX
	blt	$a0, $zero, tooSmallX
getNeighborY:
	lw 	$t0,  n
	add 	$a1, $a1, $a3
	bgt	$a1, $t0, tooLargeY
	blt	$a0, $zero, tooSmallY
checkNeighborPulse:
	move	$a2, $s0
	jal	loadReturnPulse
	jr	$ra
tooLargeX:
	move	$a0, $zero
	j	getNeighborY
tooSmallX:
	move	$a0, $t0
	addi	$a0, $a0, -1
	j	getNeighborY
tooLargeY:
	move	$a1, $zero
	j	checkNeighborPulse
tooSmallY:
	move	$a1, $t0
	addi	$a1, $a1, -1
	j	checkNeighborPulse
	


loadReturnPulse:
	addr = start + y*n + x
	lw	$t0, n
	mul	



# Open file for writing
li	$v0,  13	# syscall for open file
la	$a0,  fout	# file name
li	$a1,  1		# file I/O type: writing (0 for read)
li	$a2,  0		# file I/O mode (not needed for writing)
syscall
move	$s6,  $v0	# Save the file descriptor

# Write to the file
li	$v0,  15		# syscall: write to file
move	$a0,  $s6	# file descriptor
la	$a1,  buffer	# buffer from which to write
li	$a2,  44		# hardcoded buffer length
syscall

# Close the file
li	$v0,  16		# syscall: close file
move	$a0,  $s6	# file descriptor
syscall

# Repeat almost everything




# Output Memory Procedure
			# $a0 = numRows
			# $a1 = numCols
			# $a2 = starting address of the grid

			
#Structure of Assembly File ( in thoughts of joe meyer)
	# 1) place initial array in memory (either through reading an outside file(harder) or through a hardcoded array in assmembly (easier))
	# 2) perform cellular automata function to generate new world array
	# 3) open file to write
	# 4) write to file
	# 5) close the file
	# 6) jump to 2)