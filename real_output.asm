
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
# Open file to write

# Write to File

# Close File

# Repeat almost everything
