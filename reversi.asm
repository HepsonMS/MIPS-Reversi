# A MIPS Demonstration program which asks the user for a board position and loads it into memory.
# Alexander L. Hayes
# Computer Architecture 3340.001

.data
	EnterHorizontal:
		.asciiz "\nEnter the horizontal number (1-8): "
	InvalidFirstMessage:
		.asciiz "\nINVALID!."
	EnterVertical:
		.asciiz "Enter the vertical letter (1-8): "
	
	Board: .word 256 # Reserve 64 * 4 == 256 in order to store the 64 board spaces.
	
.text


main:
	# Begin the Program

	jal UserChooseBoardPosition
	

InitializeBoard:
	# Initialize an empty board at the start of the program.

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
	
	jal main
	
InvalidChoice:
	# The user entered an invalid Board Position, have them try again.
	li $v0, 4				# Loads 4 into $v0, print_string opcode.
	la $a0, InvalidFirstMessage		# Load address InvalidHorizontalMessage into $a0.
	syscall
	jal UserChooseBoardPosition