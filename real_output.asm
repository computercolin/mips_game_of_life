
.data
fin:			.asciiz	"game_start.txt"
fout:			.asciiz	"game_step.txt"
aliveSymbol:		.ascii	"X"
deadSymbol: 		.ascii	"O"
m:			.word 	-1
n:			.word 	-1
# Marks end of static data, must go last
lastStaticAddr:		.word 0


.text
# address at lastStaticAddr 	-- game grid 1
# $s7 				-- game grid 2
la	$a0, lastStaticAddr		# grid storage address
jal	readGridFile

## choose starting address for grid2 ($s7)
la	$t0, m
lw	$t0, 0($t0)
la	$t1, n
lw	$t1, 0($t1)
mul	$t0, $t0, $t1			# num bytes = m*n
la	$t1, lastStaticAddr
add	$s7, $t0, $t1			# starting address for game grid 2
#TODO remove me
addi	$s7, $zero, 0x100100a0
addi	$sp, $sp, -4			# prime the stack and get started

runGrids:
	la	$a0, lastStaticAddr
	move	$a1, $s7
	jal	doGameStep
	# run grid two
	move	$a0, $s7
	la	$a1, lastStaticAddr
	jal	doGameStep
	j	runGrids




# takes: 2 arguments, address of current grid, address of fallow grid
doGameStep:
	# $s0 = current game grid
	# $s1 = fallow game grid
	move	$s0, $a0
	move	$s1, $a1
# $s3 = y_ind
# $s4 = y_limit
outerLoopSetup:
	move	$s3, $zero		# y = 0
	lw	$s4, m			# y_lim = m
	addi	$s4, $s4, -1		# y_lim = m-1
outerLoopCheck:
	bgt	$s3, $s4, exitLoop	# branch out of loop if y > (m-1) -- converse of (y < m)_p
outerLoopBody:
	j	innerLoopSetup
outerLoopIncrement:
	addi	$s3, $s3, 1
	j	outerLoopCheck
exitLoop:
	move	$a0, $s1
	sw	$ra, 0($sp)		# preserve our return address
	addi	$sp, $sp, -4
	jal	outputGridFile		# step is over, out it!
	addi	$sp, $sp, 4
	lw	$ra, 0($sp)		# restore our return address
	jr	$ra
# $s5 = x_ind
# $s6 = x_limit
innerLoopSetup:
	move	$s5, $zero		# x = 0
	lw	$s6, n			# x_lim = n
innerLoopCheck:
	blt	$s5, $s6, innerLoopBody	# x < n; keep looping
	j	outerLoopIncrement
innerLoopBody:	
	move	$s2, $zero		# $s2 = number of live neighbors
	move	$a0, $s5		# arg0 = x
	move	$a1, $s3		# arg1 = y
	
	sw	$ra, 0($sp)		# preserve our return address
	addi	$sp, $sp, -4
	
	addi	$a2, $zero, -1		# x_offset
	addi	$a3, $zero, -1		# y_offset
	jal	getNeighbor
	add	$s2, $s2, $v0		# $s2 += neighbor_life_state

	addi	$a2, $zero, 0		# x_offset
	addi	$a3, $zero, -1		# y_offset
	jal	getNeighbor
	add	$s2, $s2, $v0		# $s2 += neighbor_life_state	

	addi	$a2, $zero, 1		# x_offset
	addi	$a3, $zero, -1		# y_offset
	jal	getNeighbor
	add	$s2, $s2, $v0		# $s2 += neighbor_life_state

	addi	$a2, $zero, 1		# x_offset
	addi	$a3, $zero, 0		# y_offset
	jal	getNeighbor
	add	$s2, $s2, $v0		# $s2 += neighbor_life_state

	addi	$a2, $zero, 1		# x_offset
	addi	$a3, $zero, 1		# y_offset
	jal	getNeighbor
	add	$s2, $s2, $v0		# $s2 += neighbor_life_state

	addi	$a2, $zero, 0		# x_offset
	addi	$a3, $zero, 1		# y_offset
	jal	getNeighbor
	add	$s2, $s2, $v0		# $s2 += neighbor_life_state

	addi	$a2, $zero, -1		# x_offset
	addi	$a3, $zero, 1		# y_offset
	jal	getNeighbor
	add	$s2, $s2, $v0		# $s2 += neighbor_life_state

	addi	$a2, $zero, -1		# x_offset
	addi	$a3, $zero, 0		# y_offset
	jal	getNeighbor
	add	$s2, $s2, $v0		# $s2 += neighbor_life_state

	addi	$sp, $sp, 4
	lw	$ra, 0($sp)		# restore our return address

	move	$a2, $s0		# start address of grid
	sw	$ra, 0($sp)		# preserve our return address
	addi	$sp, $sp, -4
	jal	loadReturnIsAlive	# are we alive?
	addi	$sp, $sp, 4
	lw	$ra, 0($sp)		# restore our return address
	
	bne	$v0, $zero, liveDieQuestionForLiveCells
liveDieQuestionForDeadCells:
	addi	$t0, $zero, 3		# $t0 = 3
	seq	$a3, $v0, $t0		# if 3 live neighbors, we live
	move	$a2, $s1		# start address of grid
	sw	$ra, 0($sp)		# preserve our return address
	addi	$sp, $sp, -4
	jal	storeAliveState		# store our state ($a3)
	addi	$sp, $sp, 4
	lw	$ra, 0($sp)		# restore our return address
	j	innerLoopIncrement	# next
liveDieQuestionForLiveCells:
	addi	$t0, $zero, 2
	beq	$s2, $t0, liveAndNext	# 2 neighbors? live
	addi	$t0, $zero, 3
	beq	$s2, $t0, liveAndNext	# 3 neighbors? live
dieAndNext:
	move	$a2, $s1		# start address of grid
	move	$a3, $zero

	sw	$ra, 0($sp)		# preserve our return address
	addi	$sp, $sp, -4
	jal	storeAliveState		# store our dead state ($a3)
	addi	$sp, $sp, 4	
	lw	$ra, 0($sp)		# restore our return address
	
	j	innerLoopIncrement	# next
liveAndNext:
	move	$a2, $s1		# start address of grid
	addi	$a3, $zero, 1
	
	sw	$ra, 0($sp)		# preserve our return address
	addi	$sp, $sp, -4
	jal	storeAliveState		# store our live state ($a3)
	addi	$sp, $sp, 4
	lw	$ra, 0($sp)		# restore our return address
innerLoopIncrement:
	addi	$s5, $s5, 1
	j	innerLoopCheck
	



# takes: 4 args, x, y, xOffset, yOffset, will return alive or dead
# requires: $s0 is starting address of game grid
# requires: labels "n" and "m" point to static data for # grid rows and columns
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
checkNeighborAlive:
	move	$a2, $s0
	
	sw	$ra, 0($sp)		# preserve our return address
	addi	$sp, $sp, -4
	jal	loadReturnIsAlive
	addi	$sp, $sp, 4
	lw	$ra, 0($sp)		# restore our return address
	
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
	j	checkNeighborAlive
tooSmallY:
	move	$a1, $t0
	addi	$a1, $a1, -1
	j	checkNeighborAlive




# takes: 4 args, x, y, starting address of game grid, alive state
# requires: label "n" points to static data for # grid columns
storeAliveState:
	sw	$ra, 0($sp)		# preserve our return address
	addi	$sp, $sp, -4
	jal	loadCellMemAddress
	addi	$sp, $sp, 4
	lw	$ra, 0($sp)		# restore our return address

	beqz	$a3, hesDeadJim
	lb	$a0, aliveSymbol
	j	storeValue
hesDeadJim:
	lb	$a0, deadSymbol
storeValue:
	sb	$a0, 0($v0)
	jr	$ra	



# takes: 3 args, x, y, starting address of game grid
# returns: alive/dead status of cell [1 or 0]
# requires: label "n" points to static data for # grid columns
loadReturnIsAlive:
	sw	$ra, 0($sp)		# we're more than two levels deep, store return address
	addi	$sp, $sp, -4
	jal	loadCellMemAddress
	addi	$sp, $sp, 4
	lw	$ra, 0($sp)		# restore our return address

	lbu	$v0, 0($v0)		# load the appropriate value from memory
	la	$v1, aliveSymbol	# load the alive symbol value ('X')
	lbu	$v1, 0($v1)
	seq	$v0, $v0, $v1		# Is that an 'X' in memory?
	
	jr	$ra



# takes: 3 args, x, y, starting address of game grid
# returns: memory address of cell
# requires: label "n" points to static data for # grid columns
loadCellMemAddress:
	# load(y*n + x + startAddr)
	lw	$t0, n			# load n
	mul	$v0, $t0, $a1		# y * n
	add	$v0, $v0, $a0		# + x
	add	$v0, $v0, $a2		# + startAddr
	jr	$ra


# takes: 1 arg, starting address of game grid
outputGridFile:
	move	$t1, $a0		# store grid mem address

	# Open file for writing
	li	$v0,  13		# syscall for open file
	la	$a0,  fout		# file name
	li	$a1,  1			# file I/O type: writing (0 for read)
	li	$a2,  0			# file I/O mode (not needed for writing)
	syscall
	move	$s6,  $v0		# Save the file descriptor

	# Write dimensions to the file
	li	$v0,  15		# syscall: write to file
	move	$a0,  $s6		# file descriptor
	la	$a1,  m			# out buffer: m
	li	$a2,  1			# write 1 byte
	syscall
	li	$v0,  15		# syscall: write to file
	la	$a1,  n			# out buffer: n
	li	$a2,  1			# write 1 byte	
	syscall

	# Write grid to file
	li	$v0,  15		# syscall: write to file
	move	$a0,  $s6		# file descriptor
	move	$a1,  $t1		# buffer from which to write
	lbu	$t0, m
	lbu	$a2, n			# num cells = m*n
	mul	$a2, $a2, $t0		# bytes to write = num cells
	syscall

	# Close the file
	li	$v0,  16		# syscall: close file
	move	$a0,  $s6		# file descriptor
	syscall
	jr	$ra


# takes: 1 arg, starting address of game grid
readGridFile:
	move	$t1, $a0		# store grid mem address

	# Open file for writing
	li	$v0,  13		# syscall for open file
	la	$a0,  fin		# file name
	li	$a1,  0			# file I/O type: 0 for read
	li	$a2,  0			# file I/O mode -- ignored
	syscall
	move	$s6,  $v0		# Save the file descriptor

	# Read dimensions from file
	li	$v0,  14		# syscall: read from file
	move	$a0,  $s6		# file descriptor
	la	$a1,  m			# input buffer: m
	sw	$zero, 0($a1)		# clear high order bits of m
	li	$a2,  1			# read 1 byte	
	syscall
	li	$v0,  14		# syscall: read from file
	la	$a1,  n			# out buffer: n
	sw	$zero, 0($a1)		# clear high order bits of n
	li	$a2,  1			# read 1 byte
	syscall

	# Write grid to file
	li	$v0,  14		# syscall: read from file
	move	$a0,  $s6		# file descriptor
	move	$a1,  $t1		# buffer in which to store
	lbu	$t0, m
	lbu	$a2, n			# num cells = m*n
	mul	$a2, $a2, $t0		# bytes to read = num cells
	syscall

	# Close the file
	li	$v0,  16		# syscall: close file
	move	$a0,  $s6		# file descriptor
	syscall
	jr	$ra