# A MIPS Demonstration program which asks the user for a board position and loads it into memory.
# Alexander L. Hayes
# Computer Architecture 3340.001

	#   12345678 
	#  +--------+
	# 1|        |
	# 2|        |
	# 3|        |
	# 4|        |
	# 5|        |
	# 6|        |
	# 7|        |
	# 8|        |
	#  +--------+

.data
	BoardPieceA: .asciiz "\n   12345678 \n  +--------+\n"
	BoardPieceB: .asciiz " 1|"
	BoardPieceC: .asciiz " 2|"
	BoardPieceD: .asciiz " 3|"
	BoardPieceE: .asciiz " 4|"
	BoardPieceF: .asciiz " 5|"
	BoardPieceG: .asciiz " 6|"
	BoardPieceH: .asciiz " 7|"
	BoardPieceI: .asciiz " 8|"
	BoardPieceJ: .asciiz "  +--------+\n"
	BoardRHS: .asciiz "|\n"
	
	X: .asciiz "X"
	O: .asciiz "O"
	SPACE: .asciiz " "
	
	EnterHorizontal:
		.asciiz "\nEnter the horizontal number (1-8): "
	InvalidFirstMessage:
		.asciiz "\nINVALID!."
	EnterVertical:
		.asciiz "Enter the vertical letter (1-8): "
	
	Board: .word 256 # Reserve 64 * 4 == 256 in order to store the 64 board spaces.
	
.text


main:
	# Begin the Program, Order of Operations:
	#	0. Initialize an empty board.
	#	1. Draw the Board.
	#	2. User Chooses where to move. (update board)
	#	3. Computer Chooses where to move. (update board)
	#	4. Check for Game Over.
	#	5. Jump to Step 1.
	
	# Initialize the Board before the main function begins.
	jal InitializeBoard

InitializeBoard:
	# Initialize an empty board at the start of the program.

	
	# Each word in board is initialized as a 0.
	# This is pretty much useless since everything starts out at zero.
	
	add $t0, $zero, $zero			# $t0 will be our pointer, start at 0 and loop to 256 (64 * 4)
	
	InitializeBoardLoop:

	#addi $t1, $zero, 0
	#sw $t1, Board($t0)
	sw $zero, Board($t0)
	addi $t0, $t0, 4			# Add 4 to the pointer ($t0) to move to the next word in memory.
	
	beq $t0, 256, DrawBoard			# Branch to DrawBoard when finished initializing the board.
	jal InitializeBoardLoop
	
DrawBoard:
	# Draw the board for Reversi, 0 becomes a space, 1 becomes an X, and 2 becomes an O
	# Redo most of this with a macro if you find the time. Use two A registers to keep track of position and increment by 32.
	li $v0, 4				# Load 4 into $v0, print_string opcode.
	la $a0, BoardPieceA
	syscall
	
	la $a0, BoardPieceB
	syscall
	add $t0, $zero, $zero
	FirstDrawBoardLoop:
	lw $a1, Board($t0)
	addi $t0, $t0, 4
	jal DrawSymbol
	bne $t0, 32, FirstDrawBoardLoop
	la $a0, BoardRHS
	syscall
	
	la $a0, BoardPieceC
	syscall
	addi $t0, $zero, 32
	SecondDrawBoardLoop:
	lw $a1, Board($t0)
	addi $t0, $t0, 4
	jal DrawSymbol
	bne $t0, 64, SecondDrawBoardLoop
	la $a0, BoardRHS
	syscall
	
	la $a0, BoardPieceD
	syscall
	addi $t0, $zero, 64
	ThirdDrawBoardLoop:
	lw $a1, Board($t0)
	addi $t0, $t0, 4
	jal DrawSymbol
	bne $t0, 96, ThirdDrawBoardLoop
	la $a0, BoardRHS
	syscall
	
	la $a0, BoardPieceE
	syscall
	addi $t0, $zero, 96
	FourthDrawBoardLoop:
	lw $a1, Board($t0)
	addi $t0, $t0, 4
	jal DrawSymbol
	bne $t0, 128, FourthDrawBoardLoop
	la $a0, BoardRHS
	syscall
	
	la $a0, BoardPieceF
	syscall
	addi $t0, $zero, 128
	FifthDrawBoardLoop:
	lw $a1, Board($t0)
	addi $t0, $t0, 4
	jal DrawSymbol
	bne $t0, 160, FifthDrawBoardLoop
	la $a0, BoardRHS
	syscall
	
	la $a0, BoardPieceG
	syscall
	addi $t0, $zero, 160
	SixthDrawBoardLoop:
	lw $a1, Board($t0)
	addi $t0, $t0, 4
	jal DrawSymbol
	bne $t0, 192, SixthDrawBoardLoop
	la $a0, BoardRHS
	syscall

	la $a0, BoardPieceH
	syscall
	addi $t0, $zero, 192
	SeventhDrawBoardLoop:
	lw $a1, Board($t0)
	addi $t0, $t0, 4
	jal DrawSymbol
	bne $t0, 224, SeventhDrawBoardLoop
	la $a0, BoardRHS
	syscall
	
	la $a0, BoardPieceI
	syscall
	addi $t0, $zero, 224
	EighthDrawBoardLoop:
	lw $a1, Board($t0)
	addi $t0, $t0, 4
	jal DrawSymbol
	bne $t0, 256, EighthDrawBoardLoop
	la $a0, BoardRHS
	syscall
	
	la $a0, BoardPieceJ
	syscall
	
	j UserChooseBoardPosition

DrawSymbol:
	# Helper function to draw a certain function depending on what the argument contains.
	beq $a1, $zero, DrawSpace
	beq $a1, 1, DrawX
	beq $a1, 2, DrawO
	jr $ra

	DrawX:
		la $a0, X
		syscall
		jr $ra
	DrawO:
		la $a0, O
		syscall
		jr $ra
	DrawSpace:
		la $a0, SPACE
		syscall
		jr $ra

UserChooseBoardPosition:
	# Ask the user for the board position they wish to place a piece on.
	li $v0, 4				# Load 4 into $v0, print_string opcode.
	la $a0, EnterHorizontal			# Load address FirstMessage into $a0
	syscall
	
	# Get integer from the user:
	li $v0, 5				# Load 5 into $v0, read_int opcode
	syscall
	
	# Verify the number is not greater than 8 nor less than 1.
	blt $v0, 1, InvalidChoice
	bgt $v0, 8, InvalidChoice
	
	# Now that the Horizontal Position has been validated, put it in $t0
	add $t0, $v0, $zero
	
	# Now get the vertical position.
	li $v0, 4				# Load 4 into $v0, print_string opcode.
	la $a0, EnterVertical			# Load address SecondMessage into $a0.
	syscall
	
	# Get integer from the user:
	li $v0, 5				# Load 5 into $v0, read_int opcode.
	syscall
	
	# Verify the number he or she chose is neither greater than 8 nor less than 1.
	blt $v0, 1, InvalidChoice
	bgt $v0, 8, InvalidChoice
	
	# Now that the vertical Position has been validated, perform some adjustments and put in $t1
	addi $t1, $v0, -1			# Offset by -1 (range is now 0-7)
	sll $t1, $t1, 3				# Multiply by 8
	
	# $t0 is in [1,2,3,4,5,6,7,8], $t1 is in [0,8,16,24,32,40,48,56]. Add them together to get the board position.
	
	# test: Print the position for testing purposes.
	li $v0, 1
	add $a0, $t0, $t1
	# /test
	syscall
	
	jal DrawBoard
	
InvalidChoice:
	# The user entered an invalid Board Position, have them try again.
	li $v0, 4				# Loads 4 into $v0, print_string opcode.
	la $a0, InvalidFirstMessage		# Load address InvalidHorizontalMessage into $a0.
	syscall
	jal UserChooseBoardPosition
