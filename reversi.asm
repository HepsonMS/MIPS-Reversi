# A MIPS Program for playing the Game of Reversi
# Alexander L. Hayes
# Computer Architecture 3340.001

# MIT License

# Copyright (c) 2017 Alexander L. Hayes, Henry Forson, Hepson Sanchez, and Jonathan Dubon

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



# The game will be played on a board which looks somewhat like this:
		#   1 2 3 4 5 6 7 8
		# 1| | | | | | | | |
		# 2| | | | | | | | |
		# 3| | | | | | | | |
		# 4| | | |O|X| | | |
		# 5| | | |X|O| | | |
		# 6| | | | | | | | |
		# 7| | | | | | | | |
		# 8| | | | | | | | |

.data

	# Main Menu
	TitleAndMenuOptions: .asciiz "     MIPS REVERSI\n0) New Game\n1) Instructions\n2) Exit Game\n"
	# Game Instructions
	GameInstructions: .asciiz "\n\nInstructions\nReversi is a game where opponents flip tiles until there are no further moves.\nPlay by typing the horizontal and vertical coordinates, or 404 to return to main menu.\n"

	# Board Segments
	BoardPieceA: .asciiz "\n   1 2 3 4 5 6 7 8\n"
	BoardPieceB: .asciiz " 1|"
	BoardPieceC: .asciiz " 2|"
	BoardPieceD: .asciiz " 3|"
	BoardPieceE: .asciiz " 4|"
	BoardPieceF: .asciiz " 5|"
	BoardPieceG: .asciiz " 6|"
	BoardPieceH: .asciiz " 7|"
	BoardPieceI: .asciiz " 8|"
	BoardRHS: .asciiz "\n"
	
	# X, O, and space
	X: .asciiz "X|"
	O: .asciiz "O|"
	SPACE: .asciiz " |"
	
	# Scoring strings
	XScoreMessage: .asciiz " points X; "
	OScoreMessage: .asciiz " points O\n"
	
	# Instructions
	EnterHorizontal:
		.asciiz "\nEnter the horizontal number (1-8): "
	EnterVertical:
		.asciiz "Enter the vertical letter (1-8): "
		
	# Error messages
	InvalidFirstMessage:
		.asciiz "\nINVALID! (enter 404 to exit)"
	DrawSymbolErrorMessage:
		.asciiz "\nError: Could not draw symbol with key:\n"
	
	# Arrays and structures needed to implement the game.

	Board: .word 0:256 # Reserve 64 * 4 == 256 in order to store the 64 board spaces.
	
	ValidNextMoves: .word 0:256 # Reserve potential board spaces that the human or computer can move to next.
	
.text


main:
	# Begin the Program, Order of Operations:
	#	0. Initialize an empty board.
	#	1. Draw the Board.
	#	2. User Chooses where to move. (update board)
	#	3. Computer Chooses where to move. (update board)
	#	4. Check for Game Over.
	#	5. Jump to Step 1.
	
	j MainMenu
	
MainMenu:
	# Greet the user, welcome them to the game.
	li $v0, 4				# Load 4 into $v0, print_string opcode.
	la $a0, TitleAndMenuOptions
	syscall
	
	# Get the user input.
	li $v0, 5				# Load 5 into $v0, read_int opcode.
	syscall
	beq $v0, $zero, InitializeBoard		# 0: Jump to InitializeBoard
	beq $v0, 1, InstructionsMenu		# 1: Jump to InstructionsMenu
	beq $v0, 2, ExitReversi			# 2: Jump to the Exit.
	j MainMenu				# Else: Return to main menu.
	
InstructionsMenu:
	# Give a brief overview of the instructions for playing Reversi, then return to the MainMenu.
	li $v0, 4
	la $a0, GameInstructions
	syscall
	j MainMenu

ResetBoard:
	# If the board is reset, fill each space with a 0, then reinitialize.
	# $t0 will be our index pointer.
	
	add $t0, $zero, $zero			# Start at 0
	ResetBoardLoop:
	sw $zero, Board($t0)
	addi $t0, $t0, 4
	beq $t0, 256, InitializeBoard		# Loop until 256, then initialize the board.
	j ResetBoardLoop			# Else loop

InitializeBoard:
	# Initialize an empty board at the start of the program.
	# Allocated words start at 0x00, so they will be considered open spaces until acted upon.
	
	addi $t1, $zero, 1			# Store 1 (X) into $t1
	addi $t2, $zero, 2			# Store 2 (O) into $t2
	
	# We need to put 2 into 28 (108) and 37 (144), and put 1 into 29 (112) and 36 (140).
	addi $t0, $zero, 108			# $t0 will be our pointer, start at 108.
	
	# Put the 2 into 108 and 144
	sw $t2, Board($t0)
	addi $t0, $zero, 144
	sw $t2, Board($t0)
	
	# Put the 1 into 112 and 140
	addi $t0, $zero, 112
	sw $t1, Board($t0)
	addi $t0, $zero, 140
	sw $t1, Board($t0)
	
	j DrawBoard				# Jump to DrawBoard (for consistency).
	
DrawBoard:
	# Draw the board for Reversi, 0 becomes a space, 1 becomes an X, and 2 becomes an O
	li $v0, 4				# Load 4 into $v0, print_string opcode.
	la $a0, BoardPieceA
	syscall
	
	la $a0, BoardPieceB
	syscall
	
	la $s0, Board				# Load address of Board into $s0
	li $s1, 0				# Use $s1 to keep track of the number of states we have visited so far.
	
	DrawBoardLoop:
	lw $a1, ($s0)
	jal DrawSymbol
	addi $s0, $s0, 4
	addi $s1, $s1, 4
	
	beq $s1, 32, DrawRHS1
	beq $s1, 64, DrawRHS2
	beq $s1, 96, DrawRHS3
	beq $s1, 128, DrawRHS4
	beq $s1, 160, DrawRHS5
	beq $s1, 192, DrawRHS6
	beq $s1, 224, DrawRHS7
	beq $s1, 256, DrawRHS8
	
	j DrawBoardLoop
	
	DrawRHS1:
		la $a0, BoardRHS
		syscall
		la $a0, BoardPieceC
		syscall
		j DrawBoardLoop
	DrawRHS2:
		la $a0, BoardRHS
		syscall
		la $a0, BoardPieceD
		syscall
		j DrawBoardLoop
	DrawRHS3:
		la $a0, BoardRHS
		syscall
		la $a0, BoardPieceE
		syscall
		j DrawBoardLoop
	DrawRHS4:
		la $a0, BoardRHS
		syscall
		la $a0, BoardPieceF
		syscall
		j DrawBoardLoop
	DrawRHS5:
		la $a0, BoardRHS
		syscall
		la $a0, BoardPieceG
		syscall
		j DrawBoardLoop
	DrawRHS6:
		la $a0, BoardRHS
		syscall
		la $a0, BoardPieceH
		syscall
		j DrawBoardLoop
	DrawRHS7:
		la $a0, BoardRHS
		syscall
		la $a0, BoardPieceI
		syscall
		j DrawBoardLoop
	DrawRHS8:
		la $a0, BoardRHS
		syscall
		j CalculateScoreAndPrint
		
CalculateScoreAndPrint:
	# Helper function to calculate the score of each player, and print them at the bottom of the board.
	#		$t0	Board address
	#		$t1	Number of states visited.
	#		$t4	X-Score
	#		$t5	O-Score
	#		$a1	Storage location for the word pulled from the Board.
	
	la $t0, Board				# Load address of Board into $t0
	li $t1, 0				# Use t1 to keep track of the number of states we have visited so far.
	
	add $t4, $zero, $zero			# X-Score:	$t4
	add $t5, $zero, $zero			# O-Score:	$t5
	
	CalculateScoreLoop:
	beq $t1, 256, FinishPrintingScores	# Check for out-of-bounds (occurs when $t0+=256 due to a piece at position 8x8)
		lw $a1, ($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, 4
	
	beq $a1, 1, Add1XScore			# $a1 == 1: add 1 to X-Score
	beq $a1, 2, Add1OScore			# $a1 == 2: add 1 to O-Score
	beq $t1, 256, FinishPrintingScores	# $t1 == 256: print and move on.
	j CalculateScoreLoop			# Else, loop
	
	Add1XScore:	addi $t4, $t4, 1
			j CalculateScoreLoop
	
	Add1OScore:	addi $t5, $t5 1
			j CalculateScoreLoop
	
	FinishPrintingScores:
	li $v0, 1				# Load 1 into $v0, print_int operator.
	add $a0, $t4, $zero			# Put $t4 into $a0 for printing
	syscall
	li $v0, 4				# Load 4 into $v0, print_string operator.
	la $a0, XScoreMessage			# Load the message into $a0.
	syscall
	
	li $v0, 1				# Load 1 into $v0, print_int operator
	add $a0, $t5, $zero			# Put $t5 into $a0 for printing.
	syscall
	li $v0, 4				# Load 4 into $v0, print_string operator.
	la $a0, OScoreMessage			# Load the message into $a0.
	syscall
	
	j UserChooseBoardPosition

DrawSymbol:
	# Helper function to draw a certain function depending on what the argument contains.
	#		$a0 will contain the symbol to be printed (X, O, " ")
	#		$a1 contains the element found at a memory location on a board (either 0, 1, 2)
	# 		$v0 should already contain the print_string opcode.
	beq $a1, $zero, DrawSpace
	beq $a1, 1, DrawX
	beq $a1, 2, DrawO
	
	# Error checking if symbol is out of range.
	bgt $a1, 2, DrawSymbolError
	blt $a1, $zero, DrawSymbolError

	DrawX:		la $a0, X		# Print an X
			syscall
			jr $ra
	DrawO:		la $a0, O		# Print an O
			syscall
			jr $ra
	DrawSpace:	la $a0, SPACE		# Print a space (" ")
			syscall
			jr $ra
	DrawSymbolError:
			la $a0, DrawSymbolErrorMessage
			syscall
			li $v0, 1
			move $a0, $a1
			syscall
			j ExitReversi
			

ConvertXYToBoardIndex:
	# Board indices are stored in a 64-word array corresponding to the 64 positions on a Reversi Board.
	# Convert an X/Y Coordinate into a number which can be accessed more easily.
	
	# $a2 contains the Horizontal (X) Position (1-8)
	# $a3 contains the Vertical (Y) Position (1-8)
	# Returns: $v0: an integer representing the location in memory.
	
	addi $a3, $a3, -1
	sll $a3, $a3, 3
	add $v0, $a2, $a3
	jr $ra
	
IsOnBoard:
	# Verify that the coordinates entered are valid coordinates.
	# $a2 contains the Horizontal (X) Position (1-8)			$a2
	# $a3 contains the Vertical (Y) Position (1-8)			$a3
	# $t1 is a temporary register containing the truth of the statement	$t1
	# Returns: 0 (False) or 1 (True) in $v0 if the chosen move is valid.	$v0
	
	# Initialize $v0 at 1, it will be true unless violated.
	addi $v0, $zero, 1
	
	# X >= 1
	sge $t1, $a2, 1
	and $v0, $v0, $t1
	
	# X <= 8
	sle $t1, $a2, 8
	and $v0, $v0, $t1
	
	# Y >= 1
	sge $t1, $a3, 1
	and $v0, $v0, $t1
	
	# Y <= 8
	sle $t1, $a3, 8
	and $v0, $v0, $t1
	
	jr $ra

ClearValidNextMoves:
	# Clear the ValidNextMoves array between moves, or if a move was invalid.
	# $t0 will be our index pointer.
	
	add $t0, $zero, $zero					# Start at 0
	ClearValidNextMovesLoop:
	sw $zero, ValidNextMoves($t0)
	addi $t0, $t0, 4
	beq $t0, 256, JumpAfterClearingValidNextMoves		# Loop until 256, then jump back to where you were.
	j ClearValidNextMovesLoop				# Else loop
	
	JumpAfterClearingValidNextMoves:
	jr $ra

isValidMove:
	# Check whether a board position is a valid choice. Based somewhat on the "isValidMove" function in the Python code.
	# Returns 0 if the human player's move is invalid (IsOnBoard) and clears "ValidNextMoves."
	# If the move is valid, update ValidNextMoves
	
	# $a2: xstart (0-28)
	# $a3: ystart (0-224)
	
	addi $t3, $zero, 1				# X pieces represented by 1 on Board
	add $t0, $a2, $a3				# Add x and y coordinates from UserChooseBoardPosition
	lw $t2, Board($t0)				# Load item from Board at position calculated from x+y=$t0
	
	beq $t2, $zero, freeSpace			# If position is free, jump to freeSpace
	beq $t2, 1, NOTfreeSpace			# If position is already occupied by X
	beq $t2, 2, NOTfreeSpace			# If position is already occupied by O
	
	freeSpace:					
							# NEED TO CHECK WHETHER POSITION IS ADJACENT AND FLANKS OPPONENT'S PIECES (here)
							# If so, jump to validMove
							# Else, jump to InvalidChoice
		validMove:				# Store '1' for X at position x+y=$t0
		sw $t3, Board($t0)
		j DrawBoard
	NOTfreeSpace:					# Print error and ask the user again for a new coordinate
	j InvalidChoice
	
UserChooseBoardPosition:
	# Ask the user for the board position they wish to place a piece on.
	li $v0, 4				# Load 4 into $v0, print_string opcode.
	la $a0, EnterHorizontal			# Load address FirstMessage into $a0
	syscall
	
	# Get integer from the user:
	li $v0, 5				# Load 5 into $v0, read_int opcode
	syscall
	
	# Verify the number is not greater than 8 nor less than 1.
	beq $v0, 404, MainMenu
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
	beq $v0, 404, MainMenu
	blt $v0, 1, InvalidChoice
	bgt $v0, 8, InvalidChoice
	
	# Move the Y position from $v0 to $t1
	add $t1, $v0, $zero

	# Now that the vertical Position has been validated, perform some adjustments and put in $t1
	addi $t0, $t0, -1			# Offset by -1 (range is now 0-7)
	addi $t1, $t1, -1			# Offset by -1 (range is now 0-7)
	sll $t0, $t0, 2				# Multiply by 4 (because consecutive column positions differ by 4)
	sll $t1, $t1, 5				# Multiply by 32 (because consecutive row positions differ by 32)
	
	# $t0 is in [0,4,8,12,16,20,24,28], $t1 is in [0,32,64,96,128,160,192,224]. Add them together to get the board position.
	
	# Horizontal (X) in $t0
	# Vertical (Y) in $t1
	move $a2, $t0
	move $a3, $t1
	
	# Store the return address on the stack so we can get back here.
	#addi $sp, $sp, -4
	#sw $ra, 0($sp)
	j isValidMove
	
	#j DrawBoard
	
InvalidChoice:
	# The user entered an invalid Board Position, have them try again.
	li $v0, 4				# Loads 4 into $v0, print_string opcode.
	la $a0, InvalidFirstMessage		# Load address InvalidHorizontalMessage into $a0.
	syscall
	j UserChooseBoardPosition
	
ExitReversi:
	# Exit the game.
	li $v0, 10				# exit opcode
	syscall
