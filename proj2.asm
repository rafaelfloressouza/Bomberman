	// Final Project Part 2 ~ Bomberman
	// Rafael Flores Souza, UCID: 30128094
output0:	.string "%.2f\t"				
output1:	.string "\n"
output2:	.string "X "
output3:	.string	"* "
output4:	.string "$ "
output5:	.string "*\t"
output6:	.string "$\t"
output7:	.string "+ "
output8:	.string "- "
output9:	.string "Lives: %d\nScore %.2f\nBombs: %d\n"
output10:	.string "\nTotal negative entries %d/%d = %.2f%% less than 40%%"
output11:	.string "\nTotal reward entries %d/%d = %.2f%% less than 20%% (including exit tile)\n\n"
output12:	.string "\nEnter x position or quit (-1): "
output13:	.string "\nEnter y position or quit (-1): "
output14:	.string "\nGame state not stored\nBye...\n"
output15:	.string "\nBoom!! You found %d double range reward(s) ~ <= 9  will apply\n"
output16:	.string "Oops! You loose a life because score is <= 0\n\n"
output17:	.string "\nTotal uncovered score of %.2f points\n\n"
output18:	.string "Lives: %d\nScore %.2f\nBombs: %d\n"
output19:	.string "\n\nCongratulations, you won!!\n\n"
output20:	.string "\n\nGame Over, Not enough lives\n\n"
output21:	.string "\nYou found double range reward(s). However they dont apply to next move because\nyou found double range rewards on your last move\n"
output22:	.string "\nDo you want to see the leaderboard (YES -> 1 | NO -> 0)? "
output23:	.string "\nHow many records do you want to retrieve? "
output24:	.string "\n\nGame Over, Not enough bombs\n\n"
output25:	.string "\n\nGame Over, You left the game\n"
	
	// Error Strings
error0:		.string "Not enough arguments provided!\n"
error1:		.string "Height and Width have to be >=10\n"
error2:		.string "\nThere is no leaderboard yet. Play the game to be added to it!\n"
error3:		.string "\nFile leaderboard.txt could not be updated\n"
error4:		.string "Game Summary could not be recorded!\n"
error5:		.string "\nx position must be between >= -1 and < %d\n"
error6:		.string "\ny position must be between >= -1 and < %d\n"
error7:		.string "\nName of player should be <= 15\n"
error8:		.string "\nInsert 0 or 1\n"
error9:		.string "\nNumber of records have to be >= 1 and <= %d\n"
error10:	.string "The board is empty for now. Play the game!\n\n"
	
	// Input strings
input0:		.string "%d"
input1:		.string "%s"

	// File input/output strings 
file0:		.string "leaderboard.txt"
file1:		.string "game_summary.txt"
file_op0:	.string "r"
file_op1:	.string "w"
	
	// Tokenizing strings
separator:	.string " "
separator1:	.string "\n"
	
	// Strings for leaderboard
leaderboard0:	.string "------------------LEADERBOARD------------------\n"
leaderboard1:	.string "Name\t\tScore\t\tTime Played\n"
leaderboard2:	.string "-----------------------------------------------\n"
leaderboard3:	.string "%-15s\t%4.2f\t\t%d\n"
write0:		.string "%d\n"
write1:		.string "%s %.2f %d\n"

	// Strings for game summary
game_summary0:	.string "**********GAME_SUMMARY**********\n"
game_summary1:	.string "Player's Name: %s\n"
game_summary2:	.string "Score: %.2f\n"
game_summary3:	.string "Time played: %d\n"
game_summary4:	.string "*******************************\n"
	
	.balign	4                				// Adding 4 bytes of padding (to keep everything consistent)
	.global main             				// Making main global to the linker (OS)

	define(	base_r,		x19 )				// Defining x19 as base_r
	define( i_r,		x20 ) 				// Defining x20 as i_r 
	define( j_r,		x21 )				// Defining x21 as j_r
	define( offset_r,	x22 )				// Defining x22 as offset_r
	define(	tmp_r,		x23 )				// Defining x23 as tmp_r
	define( offset2_r,	x24 )				// Definig x24 as offset2_r

	// Register offsets (for restoring them)
	reg_size = 8						// Size of an X register
	r19_offset = 16						// Offset to get x19
	r20_offset = 24						// Offset to get x20
	r21_offset = 32						// Offset to get x21
	r22_offset = 40						// Offset to get x22
	r23_offset = 48						// Offset to get x23	
	r24_offset = 56						// Offset to get x24
	
	// CELL STRUCT {bool discovered, float value}
	cell_struct_size = 9					// Size of CELL struct	
	discovered_offset = 0					// Offset to get discovered		
	value_offset = 1					// Offset to get value

	// COORDINATE STRUCT {int xCoord, int yCoord}
	coord_struct_size = 8					// Size of COORDINATE struct
	xcoord_offset = 0					// Offset to get x
	ycoord_offset = 4					// Offset to get y

	// PLAYER STRUCT {char * name, float score, int time}
	player_struct_size = 20					// Size of PLAYER struct
	plyr_name_offset = 0					// Offset to get plyr_name	
	scr_offset = 8						// Offset to get scr
	time_plyd_offset = 16					// Offset to get time_plyd
	
	// Subroutine is in charge of providing a seed for
	// function random number.
sRand:	stp	x29,	x30,	[sp, -16]!			// Allocatinng 16 bytes onn the stack for the subroutine
	mov	x29,	sp					// Making x29 point to sp (done so sp is not changed)

	ldr	x0,	=seconds         			// Loading address of int variable seconds into register x0
	bl	time		         			// Callingy function time
	ldr	x14,	=seconds        			// Loading adress of int variable seconds into register 14
	ldr	x15, 	[x14]           			// Dereferencing address stored in register x14 into register x15
	mov	x0,	x15              			// Moving value stored in x15 into x0
	bl	srand	         				// Calling srand function
	
	ldp	x29,	x30,	[sp],	16			// Deallocating 16 bytes from the stack
	ret							// Returning to the operating system

	/*--------------------------------------------------------------*/

	/* 
	Subroutine is in charge of generating an integer random number
	between 0 and upper_bound (w1)
	Returns the random number in w0
	*/
	
	l_bound_size = 4					// Size of lower bound local var
	u_bound_size = 4					// Size of upper bound local var
	
	alloc = -(16 + l_bound_size + u_bound_size) & -16	// Number of bytes to allocate for the stack frame of the subroutine (quadword aligned)
	dealloc = -alloc					// Number of bytes to deallocate

	l_bound_offset = 16					// Offset to get the lower bound var
	u_bound_offset = 20					// Offset to get the upper bound var
IntRand:
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" bytes on the stack for the subroutine		
	mov	x29,	sp					// Making x29 point to where sp is pointing

	str	w0,	[x29,	l_bound_offset]			// Storing value in w0 into the stack
	str	w1,	[x29,	u_bound_offset]			// Storing value in w1 into the stack

	bl	rand						// Branch and link rand
	mov	w14,	w0					// mov	w0 into w14

	mov	w16,	#1					// Move 1 into w16
	mov	w17,	#1					// Move 1 into w16
	b test_a						// Branch test_a
loop_a:
	mov	w13,	w16					// Move w16 into w17
	lsl	w16,	w16,	#1				// Shift left w16 by 1
test_a:	ldr	w15,	[x29,	u_bound_offset]			// Load value of upper bound into w15
	cmp	w16,	w15					// Compare w16 and w15 
	b.le	loop_a						// If w16 <= w15, then branch loop_a

	sub	w16,	w16,	#1				// Subtracting w16 by 1
	sub	w13,	w13,	#1				// Subtracting w15 by 1
	
	and	w14,	w14,	w16				// Anding w14 by w16

	ldr	w15,	[x29,	u_bound_offset]			// Loading value of upper bound into w15
if_rand:
	cmp	w14,	w15					// Comparig w14 and w15
	b.le	e_if_rand					// If w14 <= w15, then branch e_if_rand
	and	w14,	w14,	w13				// Else, anding w14 with w17
e_if_rand:

	mov	w0,	w14					// Moving w14 into w0 (return value)
	
	ldp	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallocating "dealoc" bytes
	ret							// Returning to main
	
	/*--------------------------------------------------------------*/

	/*
	Subroutine is in charge of generating a float random number
	between 0.0 and 15.0 inclusive.
	Accepts an argument to determine if the number is negative or positive (w0)
	Return the number in d0
	*/
FloatRand:
	stp	x29,	x30,	[sp, -32]!			// Allocatinng 32 bytes for the stack frame
	mov	x29,	sp					// Makig x29 point to where sp is pointing

	strb	w0,	[x29,	16]				// Storing w0 into the stack

	// Generating a number between [0,1]
	bl	rand						// Branch and link rand
	mov	x10,	x0					// Moving x0 (res) into x10 
	mov	x9,	#2147483647				// Moving RAND_MAX into x9	
	scvtf	d16,	x9					// Converting x9 into a float value
	scvtf	d17,	x10					// Connverting x10 into a float value
	fdiv	d17,	d17,	d16				// Dividing d17 and d16
	
	// Generating a number betweenn [0,15]
	bl	rand						// Branch and link rand
	and	x9,	x0,	#15				// Making the result by 15
	scvtf	d18,	x9					// Converting it to a float

	// Adding the two numbers 	
	fadd	d17,	d17,	d18				// Adding d17 and d18

	// Checking if number exceeds 15.0
	mov	x9,	15					// Moving 15 into x9
	scvtf	d16,	x9					// Convertig x9 into a float
if_float_rand:
	fcmp	d17,	d16					// Comparinng d17 and d16
	b.le	e_if_float_rand					// If d17 <= 15.0, then branch e_if_float_rand
	fmov	d17,	d16					// Else Move d16 into d17
e_if_float_rand:	
	
	// Checking if number should be neg
	ldrsb	w9,	[x29,	16]				// Loading value of the argument (passed into the function) into w9
if_float_rannd2:
	cmp	w9,	#0					// Comparing w9 and #0
	b.eq	e_if_float_rand2				// If w9 == 0, then branch e_if_float_rand2
	fneg	d17,	d17					// Else negate d17 (make it negative)
e_if_float_rand2:	

	fmov	d0,	d17					// Moving d17 into d0 (returnig the value)
	
	ldp	x29,	x30,	[sp],	32			// Restoring x29, x30 and deallocating memory
	ret							// Returning to main

	/*--------------------------------------------------------------*/

	/*
	Subroutine display the 2D game board (uncovered)
	It accepts the address of the board in x0
	Does not return anything
	*/

	// Number of bytes to allocate for the stack frame of the subroutine (quadword aligned)
	alloc = -(reg_size + reg_size + reg_size + reg_size + reg_size + 16) & -16
	dealloc = -alloc					// Number of bytes to deallocate (quadword aligned)
UncoveredBoard:	
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" amount of bytes
	mov	x29,	sp					// Making x29 point to sp
	
	// Storing callee-saved registers
	str	x19,	[x29,	r19_offset]			// Storing register x19 into the stack
	str	x20,	[x29,	r20_offset]			// Storing register x20 into the stack
	str	x21,	[x29,	r21_offset]			// Storing register x21 into the stack
	str	x22,	[x29,	r22_offset]			// Storing register x22 into the stack
	str	x23,	[x29,	r23_offset]			// Storing register x23 into the stack

	mov	base_r,	x0					// Moving x0 into base_r
	mov	i_r,	#0					// Moving 0 into i_r
	mov	j_r,	#0					// Moving 0 into j_r

	b	uboard_test					// Branch to uboard_test
uboard_loop:

	mov	j_r,	#0					// Movig 0 into j_r
	b	uboard_test2					// Brahcn to uboard_test2
uboard_loop2:

	ldr	x14,	=width					// Loading x14 with address of width
	ldrsw	x14,	[x14]					// Loading value of width into x14
	mul	offset_r,	i_r,	x14			// Multiplyig i_r and x14 and storing it into offset_r
	add	offset_r,	offset_r,	j_r		// Adding offset_r and j_r
	mov	x15,	cell_struct_size			// Moving cell_struct_size into x15
	mul	offset_r,	offset_r,	x15		// Multiplying offset_r and x15
	add	offset_r,	offset_r,	value_offset	// Addinng offset_r and value_offset

	ldr	d16,	[base_r, offset_r]			// Loading register d16 with value at board[i][j]
	
	// Checking if cell is a normal, exit, or double range 
	mov	x9,	#100					// Moving 100 into x9
	scvtf	d17,	x9					// Converting x9 into a float and storing it in d17
u_if1:	fcmp	d16,	d17					// Comparing d16 and d17
	b.ne	u_e1						// If d16 != d17, then branch to u_e1

	// Print '*' because it is exit tile
	ldr	x0,	=output5				// Loading x0 with address of output5
	b	u_e_if1						// Branch to u_e_if1
	
u_e1:	mov	x9,	#75					// Moving 75 into x9
	scvtf	d17,	x9					// Converting x9 into float and storing it ind d17
	fcmp	d16,	d17					// Comparing d16 and d17
	b.ne	u_e2						// If d16 != d17, then branch to u_e2

	// Print '$' because it is double-range reward
	ldr	x0,	=output6				// Load register x0 with addres of output6
	b	u_e_if1						// Branch to u_e_if1
u_e2:
	// Normal Tile
	ldr	x0,	=output0				// Loading reigster with address of output0
u_e_if1:	
	fmov	d0,	d16					// Moving value of d16 into d0
	bl	printf						// Branch and link printf
	
	add	j_r,	j_r,	 #1				// Increment j_r by one
uboard_test2:
	ldr	x14,	=width					// Load register x14 with address of width
	ldrsw	x14,	[x14]					// Load value of width into register x14
	cmp	j_r,	x14					// Compare j_r and x14
	b.lt	uboard_loop2					// If j_r < x14, then branch to uboard_loop2

	ldr	x0,	=output1				// Loadig register x0 with address of output1
	bl	printf						// Branch and link printf

	add	i_r,	i_r,	#1				// Incrementing i_r by one
uboard_test:
	ldr	x14,	=height					// Loading register x14 with address of height
	ldrsw	x14,	[x14]					// Loading register x14 with value of height
	cmp	i_r,	x14					// Comparing i_r and x14
	b.lt	uboard_loop					// If i_r < x14, then branch uboard_loop

	// Printing percentage summary of negative and reward tiles
	ldr	x9,	=height					// Load x9 with address of height
	ldr	x10,	=width					// Load x10 with address of width
	ldrsw	x9,	[x9]					// Load x9 with value of height 
	ldrsw	x10,	[x10]					// Load x10 with value of width
	mul	tmp_r,	x10,	x9				// tmp_r contains the number of elements in the board				
	ldr	x10,	=neg_cells				// Load x10 with address of neg_cells
	ldrsw	x10,	[x10]					// Load x10 with value of neg_cells
	ldr	x11,	=db_cells				// Load x11 with address of db_cells
	ldrsw	x11,	[x11]					// Load x11 with value of db_cells

	scvtf	d16,	tmp_r					// d16 contains the number of elemets in the board
	scvtf	d17,	x10					// d17 contains the number of negative cells
	scvtf	d18,	x11					// d18 contains the number of double-range rewards

	fdiv	d17,	d17,	d16				// d17 contains the ratio of negative cells
	fdiv	d18,	d18,	d16				// d18 contais the ratio of double range rewards 

	mov	x9,	100					// Moving 100 into x9
	scvtf	d19,	x9					// Converting 100 into a float and storing it in d17
	fmul	d17,	d17,	d19				// Multiplying neg number ratio by 100
	fmul	d18,	d18,	d19				// Multiplying double-range reward ratio by 100


	// Printing information about negative cells
	ldr	x0,	=output10				// Loading x0 with address of output10
	ldr	x9,	=neg_cells				// Loading x9 with address of neg_cells
	ldrsw	x1,	[x9]					// Loading x1 with value of neg_cells
	mov	x2,	tmp_r					// Moving tmp_r into x2
	fmov	d0,	d17					// Moving d17 into d0
	bl	printf						// Branch and link printf

	// Printing information about double-range rewards
	ldr	x0,	=output11 				// Loading x0 with address of output11
	ldr	x9,	=db_cells				// Loading x9 with address of db_cells
	ldrsw	x1,	[x9]					// Loading x1 with value of db_cells
	mov	x2,	tmp_r					// Moving tmp_r into x2
	fmov	d0,	d18					// Moving d18 into d0
	bl	printf						// Branch and link printf
	
	// Restoring calle-saved registers
	ldr	x19,	[x29,	r19_offset]			// Loadig value of x19 from stack
	ldr	x20,	[x29,	r20_offset]			// Loading value of x20 from stack
	ldr	x21,	[x29,	r21_offset]			// Loading value of x21 from stack
	ldr	x22,	[x29,	r22_offset]			// Loading value of x22 from stack
	ldr	x23,	[x29,	r23_offset]			// Loading value of x23 from stack

	ldp 	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallocating memory
	ret							// Returning to main
	
	/*--------------------------------------------------------------*/

	/*
	Subroutine initializes the 2D game board 
	It accepts the addres of the board in x0
	Does not return anything
	*/
	
	double_range_bytes = 4					// Size (in bytes) of number of double range rewards.
	neg_floats_size = 4					// Size (in bytes) of number of negative floats.

	// Number of bytes to allocate for the stack frame of the subroutine (quadword aligned)
	alloc = -(double_range_bytes + neg_floats_size + coord_struct_size + coord_struct_size + reg_size + reg_size + reg_size + reg_size + coord_struct_size  + 16) & -16
	dealloc = -alloc					// Number of bytes to deallocate at the end (quadword aligned)

	exit_tile_offset = 48					// Struct to store x-coord and y-coordinates of exit cell
	double_range_size_offset = 56				// Number of double-range rewards to generate
	neg_floats_offset = 60					// Number of negative numbers to generate
	rng_reward_offset = 64					// Struct to store x-coord and y-coordinates of exit cell
	n_float_offset = 72					// Struct to store x-cood and y-coordinates of negative cells
	
InitializeGame:
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" amount of bytes 
	mov	x29,	sp					// Moving sp into x29

	// Storing callee registers
	str	x19,	[x29,	r19_offset]			// Storing x19 on the stack		
	str	x20,	[x29,	r20_offset]			// Storing x20 on the satck
	str	x21,	[x29,	r21_offset]			// Storing x21 on the stack
	str	x22,	[x29,	r22_offset]			// Storing x22 on the stack

	// Moving base addres of board into base_r
	mov	base_r,	x0					// Moving x0 into base_r

	// Getting random position for exit tile
	// x-coordinate
	mov	w0,	#0					// Move 0 into w0
	ldr	x9,	=height					// Load x9 with address of height
	ldrsw	x9,	[x9]					// Load x9 with value of height
	sub	x9,	x9,	#1				// Subtract x9 by one
	mov	w1,	w9					// Move w9 into w0
	bl	IntRand						// Branch ad link IntRand
	str	w0,	[x29, exit_tile_offset + xcoord_offset] // Storing w0 into stack ~ exit_tile_stuct.xcoord

	// y-coordinate
	mov	w0,	#0					// Move 0 into w0
	ldr	x9,	=width					// Load x9 with address of width
	ldrsw	x9,	[x9]					// Load x9 with value of width
	sub	x9,	x9,	#1				// Subtract x9 by one
	mov	w1,	w9					// Move w9 into w0
	bl	IntRand						// Branch and link IntRand
	str	w0,	[x29, exit_tile_offset + ycoord_offset] // Storing w0 into stack ~ exit_tile_strcut.ycoord

	// Adding exit-tile into the board
	ldrsw	x9,	[x29, exit_tile_offset + xcoord_offset] // Loading x9 with xcoordinate of exit-tile
	ldrsw	x10,	[x29, exit_tile_offset + ycoord_offset]	// Loading x10 with ycoordinate of exit-tile
	ldr	x11,	=width					// Loading x11 with address of width
	ldrsw	x11,	[x11]					// Loading x11 with value of width
	mul	offset_r,	x9,	x11			// Multiply x9 and x11 and store it in offset_r
	add	offset_r,	offset_r,	x10		// Add offset_r and x10
	mov	x11,	cell_struct_size			// Move cell_struct_size into x11
	mul	offset_r,	offset_r,	x11		// Multiply offset_r and x11
	add	offset_r,	offset_r,	value_offset	// Add offset_r and value_offset

	mov	x14,	#100					// Move 100 into x14
	scvtf	d16,	x14					// Coverting value in x14 into a float and storing result in d16
	str	d16,	[base_r, offset_r]			// Store d16 into base_r + offset_r
	
	// Populating board with positive-float point numbers
	mov	i_r,	#0					// Move 0 into i_r
	mov	j_r,	#0					// Move 0 into j_r
	b	init_test					// Branch to init_test
init_loop:

	mov	j_r,	#0					// Move 0 to j_r
	b	init_test2					// Branch to init_test2
init_loop2:

	// Calculating current offset
	ldr	x14,	=width					// Loading x14 with address of width
	ldrsw	x14,	[x14]					// Loading x14 with value of width
	mul	offset_r,	i_r,	x14			// Multiplying i_r and x14 and storing result in offset_r
	add	offset_r,	offset_r,	j_r		// Adding offset_r and j_r
	mov	x14,	cell_struct_size			// Moving cell_struct_size into x14
	mul	offset_r,	offset_r,	x14		// Multiplying offset_r by x14

	// Initializing current cell to undiscovered (zero)
	mov	w9,	#0					// Moving 0 into w9
	strb	w9,	[base_r, offset_r]			// Storying a byte from w9 into the stack						
	
	add	offset_r,	offset_r,	value_offset	// Addig offset_r and value_offset

	// Checking if current cell is exit tile
	ldr	d15,	[base_r, offset_r]			// Loading d15 with value of the current cell
	mov	x9,	100					// Moving 100 into x9
	scvtf	d17,	x9					// Converting value into x9 to a float and storing it in d17
norm_tile:
	fcmp	d15,	d17					// Comparing d15 and d17
	b.eq	end_norm_tile					// If d15 == d17, then branch to end_norm_tile
	
	mov	w0,	#0					// Moving 0 into w0
	bl	FloatRand					// Branch annd link FloatRand
	str	d0,	[base_r, offset_r]			// Store d0 into the current cell
end_norm_tile:	
	
	add 	j_r,	j_r,	#1				// Increment j_r by one
init_test2:
	ldr	x9,	=width					// Load x9 with address of width
	ldrsw	x9,	[x9]					// Load x9 with value of width
	cmp	j_r,	x9					// Comparing j_r and x9
	b.lt	init_loop2					// If j_r < x9, then branch to init_loop2
	
	add	i_r,	i_r,	#1				// Incrementing i_r by one
init_test:	
	ldr	x9,	=height					// Loading x9 with address of height
	ldrsw	x9,	[x9]					// Loading x9 with value of height
	cmp	i_r,	x9					// Comparing i_r and x9
	b.lt	init_loop					// If i_r < x9, then branch to init_loop

	// Calculating the number of range rewards to generate (< 20% of number of cells in the board)
	ldr	x14,	=height					// Loading x14 with address of height
	ldr	x15,	=width					// Loading x15 with address of width
	ldrsw	x14,	[x14]					// Loading x14 with value of height
	ldrsw	x15,	[x15]					// Loading x15 with value of width
	mul	x14,	x14,	x15				// Multiply x14 and x15 and store it in x14
	mov	x15,	#20					// Move 20 into x15
	mul	x14,	x14,	x15				// Multiply x14 by x15 and store it i x14
	mov	x15,	#100					// Move 100 into x15
	udiv	x14,	x14,	x15				// Unsigned division of x14 and x15 store in x14
	sub	x14,	x14,	#1				// Subract x14 by one
	str	w14,	[x29,	double_range_size_offset]	// Store w14 into the stack (# of double range rewards)
	ldr	x9,	=db_cells				// Loading address of db_cells into x9
	str	w14,	[x9]					// Storing number of double-range reward cells in db_cells

	// Populating the board with double-range rewards

	mov	i_r,	#0					// Move 0 into i_r
	b	init_test3					// Branch init_test3
init_loop3:

	// Getting x-coordinate 
	mov	w0,	#0					// Move 0 into w0
	ldr	x9,	=height					// Load x9 with address of height
	ldrsw	x9,	[x9]					// Load x9 with value of height
	sub	x9,	x9,	#1				// Subtract x9 by one
	mov	w1,	w9					// Move w9 into w1 
	bl	IntRand						// Branch and link IntRand
	str	w0,	[x29, rng_reward_offset + xcoord_offset]// Store w0 into stack at address x29 + rng_reward_offset + xcoord_offset
	
	// Getting y-coordinate
	mov	w0,	#0					// Move 0 into w0
	ldr	x9,	=width					// Load x9 with address of width
	ldrsw	x9,	[x9]					// Load x9 with value of width
	sub	x9,	x9,	#1				// Subtract x9 by one
	mov	w1,	w9					// Move w9 into w1
	bl	IntRand						// Branch and link IntRand
	str	w0,	[x29,rng_reward_offset + ycoord_offset] // Store w0 into stack at address x29 + rng_reward_offset + ycoord_offset

	// Making sure the random position generated is different from the exit tile's
i2_if2:
	ldr	w9,	[x29,rng_reward_offset + xcoord_offset] // Load w9 with value of x-coordinate of double range reward
	ldr	w10,	[x29,exit_tile_offset + xcoord_offset]	// Load w10 with value of x-coordiate of exit tile
	cmp	w9,	w10					// Comparing w9 and w10
	b.eq	i2_e2						// If w9 == w10, then branch i2_e2

	// Adding the reward into the board (x of reward is different from the exit tile's)
	ldrsw	x9,	[x29,rng_reward_offset + xcoord_offset] // Load w9 with value of y-coordinate of double range reward
	ldrsw	x10,	[x29,rng_reward_offset + ycoord_offset] // Load w10 with value of y-coordinate of exit tile
	ldr	x11,	=width					// Load x11 with address of width
	ldrsw	x11,	[x11]					// Load x11 with value of width
	mul	offset_r,	x9,	x11			// Multiply x9 and x11 and store result in offset_r
	add	offset_r,	offset_r,	x10		// Add offset_r and x10
	mov	x11,	#9					// Move 9 into x11 
	mul	offset_r,	offset_r,	x11		// Multiple offset_r by x11 
	add	offset_r,	offset_r,	value_offset	// Add offset_r and value_offset

	ldr	d17,	[base_r, offset_r]			// Load register d17 with value at address base_r + offset_r
	mov	x9,	#75					// Move 75 into x9
	scvtf	d16,	x9					// Converting x9 into a float and storing it in d16

	// Checking if the current random cell is not already a double range reward
	fcmp	d16,	d17					// Comparing d16 and d17
	b.eq	init_loop3					// If d16 == d17, thenn branch to init_loop
	str	d16,	[base_r, offset_r]			// Else, store d16 at base_r + offset_r
	
	b	i_e_if2						// Branch to i_e_if2
i2_e2:	
	ldr	w9,	[x29,rng_reward_offset + ycoord_offset] // Load w9 with y-coordinate of double range reward
	ldr	w10,	[x29,exit_tile_offset + ycoord_offset]	// Load w10 with y-coordinate of exit tile
	cmp	w9,	w10					// Compare w9 and w10
	b.eq	i2_e3						// If w9 != w10, then branch to i2_e3

	// Adding the reward into the board (y of reward is different from the exit tile's)

	ldrsw	x9,	[x29,rng_reward_offset + xcoord_offset] // Loading x9 with x-coordinate of double range reward
	ldrsw	x10,	[x29,rng_reward_offset + ycoord_offset]	// Loading x10 with y-coordinate of double range reward
	ldr	x11,	=width					// Load x11 with address of width
	ldrsw	x11,	[x11]					// Load x11 with value of width
	mul	offset_r,	x9,	x11			// Multiply x9 and x11 and store it in offset_r
	add	offset_r,	offset_r,	x10		// Add offset_r and x10
	mov	x11,	cell_struct_size			// Move cell_struct_size into x11 
	mul	offset_r,	offset_r,	x11		// Multiply x11 and offset_r
	add	offset_r,	offset_r,	value_offset	// add offset_r and value_offset

	ldr	d17,	[base_r, offset_r]			// Load d17 with value in base_r + offset_r
	mov	x9,	#75					// Move 75 into x9
	scvtf	d16,	x9					// Converting x9 into a float 

	// Checking if the current random cell is not already a double range reward
	fcmp	d16,	d17					// Comparing d16 and d17
	b.eq	init_loop3					// If d16 == d17, then brannch to init_loop3
	str	d16,	[base_r, offset_r]			// Else, store d16 into base_r + offset_r 

	b	i_e_if2						// Branch to i_e_if2
i2_e3:	b	init_loop3					// Branch to init_loop3
i_e_if2:
	add	i_r,	i_r,	#1				// Increment i_r by one
init_test3:	
	ldrsw	x9,	[x29,	double_range_size_offset]	// Load register x9 with value at x29 + double_range_size_offset
	cmp	i_r,	x9					// Comparing i_r and x9
	b.lt	init_loop3					// If i_r < x9, then branch to init_loop3

	// Calculating the number of negative float-values to generate
	ldr	x14,	=height					// Loading x14 with address of height
	ldr	x15,	=width					// Loading x15 with address of width
	ldrsw	x14,	[x14]					// Loading x14 with value of height
	ldrsw	x15,	[x15]					// Loading x15 with value of width
	mul	x14,	x14,	x15				// Multiply x14 and x15 and store it in x14
	mov	x15,	#40					// Move 40 into x15
	mul	x14,	x14,	x15				// Multiply x14 by x15 and store it i x14
	mov	x15,	#100					// Move 100 into x15
	udiv	x14,	x14,	x15				// Unsigned division of x14 and x15 store in x14
	sub	x14,	x14,	#1				// Subract x14 by one
	str	w14,	[x29,	neg_floats_offset]		// Store w14 into the stack (# of negative float numbers)
	ldr	x9,	=neg_cells				// Loading x9 with address of neg_cells
	str	w14,	[x9]					// Storing number of negative cells in neg_cells
	
	// Populating board with negative float-numbers
	mov	i_r,	#0					// Move 0 into i_r
init_loop4:

	// Getting random x-pos
	ldr	x9,	=height					// Load x9 with address of height
	ldrsw	x9,	[x9]					// Load x9 with value of height
	sub	x9,	x9,	#1				// Subtracting x9 by one
	mov	w0,	#0					// Movig 0 into w0
	mov	w1,	w9					// Moving w9 into w1
	bl	IntRand						// Branch and link IntRand
	str	w0,	[x29,	n_float_offset + xcoord_offset]	// Store w0 into x29 + n_float_offset + xcoord_offset

	// Getting random y-pos
	ldr	x9,	=width					// Load x9 with address of width
	ldrsw	x9,	[x9]					// Load x9 with value of width
	sub	x9,	x9,	#1				// Subtract x9 by one
	mov	w0,	#0					// Move 0 into w0
	mov	w1,	w9					// Move w9 into w1
	bl	IntRand						// Branch and link IntRand
	str	w0,	[x29,	n_float_offset + ycoord_offset] // Store w0 into x29 + n_float_offset + xcoord_offset

	// Computing offset
	ldrsw	x9,	[x29,	n_float_offset + xcoord_offset]	// Load x9 with value at x29 + n_float_offset + xcoord_offset
	ldrsw	x10,	[x29,	n_float_offset + ycoord_offset]	// Load x19 with value at x29 + n_float_offst + ycoord_offset
	ldr	x11,	=width					// Loading x11 with address of width
	ldrsw	x11,	[x11]					// Loading x11 with value of width

	mul	offset_r,	x9,	x11			// Multiplying x9 and x11 and storing result in offset_r
	add	offset_r,	offset_r,	x10		// Adding offset_r and x10 and storing result in offset_r
	mov	x10,	cell_struct_size			// Moving cell_struct_size to x10
	mul	offset_r,	offset_r,	x10		// Multiplyig offset_r and x10
	add	offset_r,	offset_r,	value_offset    // Adding offset_r and value_offset

	ldr	d16,	[base_r, offset_r]			// Loading d16 with value in base_r + offest_r (board[i][j])
	
	// Checking if the value is already negative
	mov	x9,	0					// Move 0 into x9					
	scvtf	d17,	x9					// Convert x9 into a float and store the result in d17
	fcmp	d16,	d17					// Comparing d16 and d17
	b.lt	init_loop4					// If d16 < d17, then branch to init_loop4

	// Checking if the value is the exit tile
	mov	x9,	100					// Move 100 into x9
	scvtf	d17,	x9					// Convert x9 into a float and store the result in d17
	fcmp	d16,	d17					// Comparing d16 and d17
	b.eq	init_loop4					// if d16 == d17, then branch init_loop4

	// Checking if the value is a double range reward
	mov	x9,	75					// Move 75 into x9
	scvtf	d17,	x9					// Convert x9 into a float and store the result in d17
	fcmp	d16,	d17					// Comparing d16 and d17
	b.eq	init_loop4					// If d16 == d17, then branch init_loop4

	// If it is a number that can be coverted into negative:
	fneg	d16,	d16					// Negating float-point value in d16
	str	d16,	[base_r, offset_r]			// Storing d16 into stack at address base_r + offset_r (board[i][j] = val)

	add	i_r,	i_r,	#1				// Increment i_f by one
init_test4:
	ldrsw	x9,	[x29,	neg_floats_offset]		// Load x9 with the number of negative numbers to be generated
	cmp	i_r,	x9					// Comparing i_r and x9
	b.lt	init_loop4					// If i_r < x9, then branch to init_loop4
	
	// Restoring calle registers
	ldr	x19,	[x29,	r19_offset]			// Loading x19 with value in stack
	ldr	x20,	[x29,	r20_offset]			// Loading x20 with value in stack
	ldr	x21,	[x29,	r21_offset]			// Loading x21 with value in stack
	ldr	x22,	[x29,	r22_offset]			// Loading x22 with value in stack

	ldp 	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallocating memory
	ret							// Returning to main

	/*--------------------------------------------------------------*/
	
	/*
	Subroutine displays the 2D game board
	Arguments -> x0: board's address, w1: lives, d0: score, w2: bombs	 
	Return:	None
	Note: It displays the board as "hidden"	
	*/

	lives_size = 4						// Size of lives local variable
	score_size = 8						// Size of score local variable
	bombs_size = 4						// Size of bombs local variable

	// Number of bytes to allocate for the stack frame of the subroutine (quadword aligned)
	alloc = -(lives_size + score_size + bombs_size + reg_size + reg_size + reg_size + reg_size + 16) & -16
	dealloc = -alloc					// Number of bytes to deallocate

	lives_offset = 48					// Offset to get value of lives
	score_offset = 52					// Offset to get value of score
	bombs_offset = 60					// Offset to get value of bombs
	
DisplayGame:
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" amount of bytes
	mov	x29,	sp					// Moving sp into x29

	// Storing calle-saved registers
	str	x19,	[x29,	r19_offset]			// Storing value of x19 in stack
	str	x20,	[x29,	r20_offset]			// Storing value of x20 in stack
	str	x21,	[x29,	r21_offset]			// Storing value of x21 in stack
	str	x22,	[x29,	r22_offset]			// Storing value of x22 in stack

	mov	base_r,	x0					// Move x0 into base_r (base of board)

	str	w1,	[x29, lives_offset]			// Storing w1 into lives local variable
	str	d0,	[x29, score_offset]			// Storing d0 into score local variable
	str	w2,	[x29, bombs_offset]			// Storing w2 into bombs local variable

	mov	i_r ,	#0					// Move 0 into i_r
	mov	j_r,	#0					// Move 0 into j_r

	b	disp_test					// Branch to disp_test
disp_loop:

	mov	j_r,	#0					// Move 0 into j_r
disp_loop2:

	ldr	x14,	=width					// Load x14 with address of width
	ldrsw	x14,	[x14]					// Load x14 with value of width
	mul	offset_r,	i_r,	x14			// Multiply i_r and x14 and store result in offset_r
	add	offset_r,	offset_r,	j_r		// Addinng offset_r and j_r
	mov	x14,	cell_struct_size			// Moving cell_struct_size into x14
	mul	offset_r,	offset_r,	x14		// Multiply offset_r and x14

	ldrsb	w9,	[base_r, offset_r]			// Load	w9 with discovered value of current cell

	cmp	w9,	wzr					// Comparing w9 with wzr
	b.ne	disp_discovered					// If w9 != 0, then branch to disp_discovered
disp_undiscovered:

	ldr	x0,	=output2				// Load x0 with address of output2
	bl	printf						// Branch and link printf
	b	end_disp					// Branch end_disp

disp_discovered:

	add	offset_r,	offset_r,	value_offset	// Adding offset_r and value_offset and storing result in offset_r
	ldr	d16,	[base_r, offset_r]			// Load d16 with value of current cell

	// Checking the type of cell
p_exit_cell:
	mov	x9,	100					// Move 100 into x9
	scvtf	d17,	x9					// Convert value in x9 into a float
	fcmp	d16,	d17					// Comparing d17 and d16
	b.ne	p_d_range_cell					// If d17 != d16, then branch to p_d_range_cell

	ldr	x0,	=output3				// Load x0 with address of output3
	bl	printf						// Branch and link printf
	b	end_disp					// Branch end_disp
		
p_d_range_cell:
	mov	x9,	75					// Move 75 into x9
	scvtf	d17,	x9					// Convert value in x9 into a float and store it in d17
	fcmp	d16,	d17					// Comparinng d16 and d17
	b.ne	p_normal_cell					// If d16 != d17, then branch to p_normal_cell

	ldr	x0,	=output4				// Load x0 with address of output4
	bl	printf						// Branch and link printf
	b	end_disp					// Branch end_disp

p_normal_cell:

	mov	x9,	0					// Move 0 into x9
	scvtf	d17,	x9					// Convert value in x9 into a float and store it in d17
	fcmp	d16,	d17					// Comparing d16 and d17
	b.lt	negative					// If d16 < d17 (0.0), then branch to negative 
positive:

	ldr	x0,	=output7				// Load x0 with the address of output7
	bl	printf						// Branch and link printf
	b 	end_disp					// Branch end_disp
	
negative:

	ldr	x0,	=output8				// Load x0 with address of output8
	bl	printf						// Branch and link printf

end_disp:
	
	add	j_r,	j_r,	#1				// Incrementing j_r by one
dis_test2:
	ldr	x9,	=width					// Load x9 with address of width
	ldrsw	x9,	[x9]					// Load x9 with value of width
	cmp	j_r,	x9					// Comparing j_r and x9
	b.lt	disp_loop2					// If j_r < x9, then branch to disp_loop2

	// Printing a new line
	ldr	x0,	=output1				// Load x0 with address of output1
	bl	printf						// Branch and link printf
	
	add	i_r,	i_r,	#1				// Incrementing i_r by one
disp_test:
	ldr	x9,	=height					// Load x9 with address of height
	ldrsw	x9,	[x9]					// Load x9 with value of height
	cmp	i_r,	x9					// Comparing i_r and x9
	b.lt	disp_loop					// If i_r < x9, then branch disp_loop

	// Printing summary of score, lives, and bombs
	ldr	x0,	=output18				// Load x0 with address of output18
	ldr	x1,	[x29, lives_offset]			// Load x1 with value of lives
	ldr	d0,	[x29, score_offset]			// Load d0 with value of score
	ldr	x2,	[x29, bombs_offset]			// Load x2 with value of x2
	bl	printf						// Branch and link printf

	// Restoring calle-saved registers
	ldr	x19,	[x29,	r19_offset]			// Load value of x19 from stack
	ldr	x20,	[x29,	r20_offset]			// Load value of x20 from stack
	ldr	x21,	[x29,	r21_offset]			// Load value of x21 from stack
	ldr	x22,	[x29,	r22_offset]			// Load value of x22 from stack
	
	ldp 	x29,	x30,	[sp],	dealloc			// Restoring x29, x30, and deallocating memory
	ret							// Return to main
	
	/*--------------------------------------------------------------*/

	/*
	Subroutine makes cells visible, updates double range reward count,
	and adds score of each cell into partial score.
	Arguments -> x0: Board address, x1: bombPos address and
	x2: partial score address
	Return: Nothing	
	*/

	dbl_rng_count_size = 4					// Size of local variable double range count
	par_score_addr = 8					// Size of the address of partial score variable
	org_act_y_size = 4					// Size of original actual y-coordinate

	// Number of bytes to allocate for the stack frame of the subroutine (quadword aligned)
	alloc = -((6 * reg_size) + 16 + coord_struct_size + dbl_rng_count_size + par_score_addr + org_act_y_size) & -16
	dealloc = -alloc					// Number of bytes to dealloc (quadword aligned)

	actual_coord_offset = 64				// Offset of actual coordiates struct local variable
	dbl_rng_count_offset = 72				// Offset of double range count local variable
	par_score_addr_offset = 76				// Offset of partial score address
	org_act_y_offset = 84					// Offset of orignial actual y cordinate 
CalculateScoreHelper:
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" amount of bytes
	mov	x29,	sp					// Moving sp into x29

	// Storing calle-saved registers
	str	x19,	[x29,	r19_offset]			// Store value of x19 in the stack
	str	x20,	[x29,	r20_offset]			// Store value of x20 in the stack
	str	x21,	[x29,	r21_offset]			// Store value of x21 in the stack
	str	x22,	[x29,	r22_offset]			// Store value of x22 in the stack
	str	x23,	[x29,	r23_offset]			// Store value of x23 in the stack
	str	x24,	[x29,	r24_offset]			// Store value of x24 in the stack

	// Storing the board's address in base_r
	mov	base_r,	x0					// Moving x0 into base_r

	// Making dbl_rng_count = db_reward_count
	ldr	x9,	=db_reward_count			// Load x9 with addres of db_reward_count
	ldrsw	x10,	[x9]					// Load x10 with value of db_reward_count
	str	w10,	[x29, dbl_rng_count_offset]		// Store w10 into dbl_rng_count local var
	str	wzr,	[x9]					// Storing 0 into db_reward_count

	// Finding actual bomb position
	ldrsw	x9,	[x1, xcoord_offset]			// Loading x9 with value of bombPos.xcoord
	ldrsw	x10,	[x1, ycoord_offset]			// Loading x10 with value of bombPos.ycoord
	ldrsw	x11,	[x29, dbl_rng_count_offset]		// Loading x11 with value of dbl_rng_count

	ldr	x15,	=reward_active				// Load x15 with address of reward_active
	ldrsb	w14,	[x15]					// Load w14 with value of reward_active
	cmp	w14,	#0					// Comparing w14 and 0
	b.eq	calc_e_if1					// If w14 == 0, then branch to calc_e_if1
calc_if1:
	strb	wzr,	[x15]					// Store wzr into address in x15
	mov	x11,	#0					// Move 0 into x11									
calc_e_if1:

	cmp	x11,	#9					// Compare x11 and 9
	b.le	calc_e_if2					// If x11 <= 9, then branch to calc_e_if2
calc_if2:
	mov	x11,	#9					// Move #9 into x11
calc_e_if2:	
	
	cmp	x11,	#0					// Compare x11 with #0
	b.le	calc_e_if3					// If x11 <= #0, then branch to calc_e_if3
calc_if3:
	ldr	x15,	=reward_active				// Load x15 with address of reward_active
	mov	w14,	#1					// Move #1 into w14
	strb	w14,	[x15]					// Store w14 into address in x15
calc_e_if3:

	mov	x13,	#1					// Moving #1 into x13
	lsl	tmp_r,	x13,	x11				// Left shift x13 by x11

	sub	x9,	x9,	tmp_r				// Subtract x9 and tmp_r and store  result in x9
	sub	x10,	x10,	tmp_r				// Structract x10 and tmp_r and store result in x10

	// Storing w9 into actual_coord.xcoord
	str	w9,	[x29, actual_coord_offset + xcoord_offset]

	// Storing w10 into actual_coord.ycoord
	str	w10,	[x29, actual_coord_offset + ycoord_offset]
	str	w10,	[x29, org_act_y_offset]			// Storing w10 into org_act_y_offset
	
	// Storing partial score address
	str	x2,	[x29,	par_score_addr_offset]		// Storing x2 into par_score_addr (address of partial score variable)
	
	// Computing partial score and discovering tiles
	mov	i_r,	#0					// Moving 0 into i_r
	mov	j_r,	#0					// Moving 0 into j_r
	b	csh_test					// Branch to csh_test
csh_loop:
	
	// Resetting the value of actual-y coordinate for the next iteration
	ldrsw	x9,	[x29, org_act_y_offset]			// Loading x9 with value of org_act_y

	// Storing value in w9 into actual_coord.ycoord
	str	w9,	[x29, actual_coord_offset + ycoord_offset]
	
	mov	j_r,	#0					// Moving 0 into j_r
	b	csh_test2					// Branch to csh_test2
csh_loop2:

	// Making sure tile is in the board
	// Load x9 with value actual_coord.xcoord
	ldrsw	x9,	[x29,	actual_coord_offset + xcoord_offset]

	// Load x10 with value actual_coord.ycoord
	ldrsw	x10,	[x29,	actual_coord_offset + ycoord_offset]
	ldr	x11,	=height					// Loading x11 with address of height
	ldrsw	x11,	[x11]					// Loading x11 with value of height
	ldr	x12,	=width					// Loading x12 with address of width
	ldrsw	x12,	[x12]					// Loading x12 with value of width

	cmp	x9,	#0					// Comparing x9 and #0
	b.lt	e_in_board					// If x9 < 0, then branch to e_in_board
	cmp	x9,	x11					// Comparing x9 and x11
	b.ge	e_in_board					// If x9 >= x11, then branch to e_in_board
	cmp	x10,	#0					// Comparing x10 annd #0
	b.lt	e_in_board					// If x10 < 0, then branch to e_in_board 
	cmp	x10,	x12					// Comparing x10 and x12 
	b.ge	e_in_board					// If x10 >= 12, then branch to e_in_board
in_board:	

	// Calculating the offset
	ldr	x9,	=width					// Loading x9 with address of width
	ldrsw	x9,	[x9]					// Loading x9 with value of width

	// Loading x10 with value actual_coord.xcoord
	ldrsw	x10,	[x29, actual_coord_offset + xcoord_offset]

	// Loading x11 with value of actual_coord.ycoord
	ldrsw	x11,	[x29, actual_coord_offset + ycoord_offset]		

	mul	offset_r,	x10,	x9			// Multiplying x10 and x9
	add	offset_r,	offset_r,	x11		// Adding offset_r and x11
	mov	x12,	cell_struct_size			// Moving cell_struct_size into x12
	mul	offset_r,	offset_r,	x12		// Multiplying offset_r with x12

	// Adding offset_r and discovered_offset and storing result in offset2_r
	add	offset2_r,	offset_r,	discovered_offset

	// Adding offset_r and value_offset
	add	offset_r,	offset_r,	value_offset			

	ldr	d16,	[base_r, offset_r]			// Loading d16 with value of current cell
	mov	x9,	75					// Movig 75 into x9
	scvtf	d17,	x9					// Converting value in x9 to a float and storing it in d17

	//If double range reward
	fcmp	d16,	d17					// Comparing d16 and d17
	b.eq	db_rng						// If d16 == d17, then branch to db_rng

	mov	x9,	100					// Moving 100 into x9
	scvtf	d17,	x9					// Converting value in x9 into a float and storing it in d17
	
	// If exit tile
	fcmp	d16,	d17					// Comparig d16 and d17
	b.eq	ext						// If d16 == d17, then branch to ext
		
	// Else normal tile
	b nrm							// Brannch to nrm

db_rng:
	ldrsb	w9,	[base_r, offset2_r]			// Load w9 with discovered value of the current cell
	cmp	w9,	#1					// Comparing w9 and #1
	b.eq	end_comparison					// If w9 == #1, then branch to end_comparison

	ldr	x10,	=db_reward_count			// Load x10 with address of db_reward_count
	ldrsw	x11,	[x10]					// Load x11 with value of db_reward_count
	add	x11,	x11,	#1				// Incrementing x11 by one
	str	w11,	[x10]					// Storing w11 back to db_reward_count

	b	end_comparison					// Branch end_comparison
ext:
	ldr	x10,	=exit_tile_f				// Load x10 with address of exit_tile_f 
	mov	w11,	#1					// Moving #1 into w11	
	strb	w11,	[x10]					// Storing w11 into x10 (exit_tile_f address)

	b	end_comparison					// Branch to end_comparison
nrm:	
	ldrsb	w9,	[base_r, offset2_r]			// Load w9 with discovered value of current cell	
	cmp	w9,	#1					// Comparing w9 and #1
	b.eq	end_comparison					// If w9 == #1, then branch to end_comparison

	ldr	x10,	[x29, par_score_addr_offset]		// Load x10 with address of partial score var
	ldr	d16,	[x10]					// Loading d16 with value of partial score
	ldr	d17,	[base_r, offset_r]			// Loading d17 with value of current cell
	fadd	d16,	d16,	d17				// Adding d16 and d17 ~ Storing result in d16
	str	d16,	[x10]					// Storing d16 into partial score var

end_comparison:

	// Making current cell visible
	mov	w9,	#1					// Moving #1 into w9
	strb	w9,	[base_r, offset2_r]			// Storing w9 into the current cell's discovered variable

e_in_board:	

	// Incrementing actual y-pos by one

	// Loading x9 with value of actual_coord.ycoord
	ldrsw	x9,	[x29, actual_coord_offset + ycoord_offset]
	add	x9,	x9,	#1				// Incrementing x9 by one

	// Storing w9 into actual_coord.ycoord
	str	w9,	[x29, actual_coord_offset + ycoord_offset]

	add	j_r,	j_r,	#1				// Incrementing j_r by one
csh_test2:	
	lsl	x9,	tmp_r,	#1				// Left shift tmp_r by #1 ~ Store result in x9
	cmp	j_r,	x9					// Comparing j_r and x9
	b.le	csh_loop2					// If j_r <= x9, then branch csh_loop2

	// Incrementing actual x-pos by one

	// Loading x10 with value of actual_coord.xcoord
	ldrsw	x10,	[x29, actual_coord_offset + xcoord_offset]
	
	add	x10,	x10,	#1				// Incrementing x10 by one

	// Storing w10 into actual_coord.xcoord
	str	w10,	[x29, actual_coord_offset + xcoord_offset]
	
	add	i_r,	i_r,	#1				// Incrementing i_r by one
csh_test:	
	lsl	x9,	tmp_r,	#1				// Left shift tmp_r by #1 ~ Store result in x9
	cmp	i_r,	x9					// Comparing i_r and x9
	b.le	csh_loop					// If i_r <= x9, then brach csh_loop

	// Printing message if double-range rewards were found
	ldr	x9,	=db_reward_count				// Load x9 with value of dbl_rng_count 
	ldrsw	x9,	[x9]
	cmp	x9,	#0					// Comparing w9 and #0
	b.le	csh_print_end					// If w9 <= 0, then branch csh_print_end
csh_print:

	ldr	x15,	=reward_active				// Load x15 with address of reward_active
	ldrsb	w14,	[x15]					// Load w14 with value of reward_active
	cmp	w14,	#0					// Comparing w14 with 0
	b.eq	other_csh					// If w14 == 0, then branch too other_csh
		
	ldr	x0,	=output21				// Load x0 whith address of string output15
	bl	printf						// Branch and link printf

	b	csh_print_end					// Branch to csh_print_end
other_csh:	

	ldr	x0,	=output15				// Load x0 whith address of string output15
	mov	x1,	x9					// Moving w9 into w1
	bl	printf						// Branch and link printf
	
csh_print_end:	
	
	// Restoring calle-saved registers
	ldr	x19,	[x29,	r19_offset]			// Load value of x19 from stack
	ldr	x20,	[x29,	r20_offset]			// Load value of x20 from stack
	ldr	x21,	[x29,	r21_offset]			// Load value of x21 from stack
	ldr	x22,	[x29,	r22_offset]			// Load value of x22 from stack
	ldr	x23,	[x29,	r23_offset]			// Load value of x23 from stack
	ldr	x24,	[x29,	r24_offset]			// Load value of x24 from stack

	ldp	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallocating "dealloc" amount of bytes
	ret							// Returning to main
		
	/*--------------------------------------------------------------*/

	/*
	Subroutine calculates the score after a bomb is placed and "explodes" (it reveals cells as well)
	Arguments: x0: address of board, d0: address of score, x1: lives address,
	x2: bombs address, and x3: bombsPos address
	Return: Nothing	
	*/

	addr_size = 8						// Size (in bytes) of an address
	part_score_size = 8					// Size of partial score variable

	alloc = -((addr_size * 5) + 16 + part_score_size) & -16 // Number of bytes to allocate for the stack frame of the function (quadword aligned)
	dealloc = -alloc					// Number of bytes to deallocate  (quadword aligned)

	board_addr_offset = 16					// Offset of board address
	score_addr_offset = 24					// Offset of score address 
	lives_addr_offset = 32					// Offset of lives address
	bombs_addr_offset = 40					// Offset of bombs address
	bomPos_addr_offset= 48					// Offset of bomPos struct address (Coord struct)
	part_score_offset = 56
	
CalculateScore:
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" amount of bytes and storing x29,x30
	mov	x29,	sp					// Moving sp into x29

	// Storing all arguments in the stack
	str	x0,	[x29, board_addr_offset]		// Storing x0 into the board_addr local var 
	str	x1,	[x29, score_addr_offset]		// Storing x1 into the score_addr local var
	str	x2,	[x29, lives_addr_offset]		// Storing x2 into the lives_addr local var
	str	x3,	[x29, bombs_addr_offset]		// Storing x3 into the bombs_addr local var
	str	x4,	[x29, bomPos_addr_offset]		// Storing x4 into the bombPos_addr local var

	// Decrementing the number of bombs by one
	ldr	x10,	[x29, bombs_addr_offset]		// Loading x10 with bombs' var addr
	ldr	w9,	[x10]					// Loading w9 with value of bombs 
	sub	w9,	w9,	#1				// Subtracting w9 by one
	str	w9,	[x10]					// Storing result back into bomb's var addr

	// Initializing partial score variable
	mov	x10,	#0					// Move 0 into x10
	scvtf	d16,	x10					// Converting value in x10 into a float and storing it in d16
	str	d16,	[x29, part_score_offset]		// Storinng d16 into partial score local variable
	
	// Calling CalculateScoreHelper
	ldr	x0,	[x29,	board_addr_offset]		// Load x0 with board's address
	ldr	x1,	[x29,	bomPos_addr_offset]		// Load x1 with bombPos' address
	add	x2,	x29,	part_score_offset		// Load x2 with address of partial score variable
	bl	CalculateScoreHelper				// Branch and link CalculateScoreHelper

	// Printing results of bomb explosion
	ldr	d16,	[x29, part_score_offset]		// Load d16 with value of partial score
	ldr	x10,	[x29, score_addr_offset]		// Load x10 with address of score
	ldr	d17,	[x10]					// Load d17 with value of score
	mov	x12,	#1					// Move #1 into x12
	mov	x13,	#1000					// Move #1000 into x13
	scvtf	d18,	x12					// Converting value in x12 into a float and storing it in d18
	scvtf	d19,	x13					// Converting value in x13 into a float and storing it in d19
	fdiv	d18,	d18,	d19				// Dividing d18 by d19 and storing result in d18
	fadd	d16,	d17,	d16				// Adding d17 and d16 ~ Storing result in d16
	fcmp	d16,	d18					// Comparing d16 and d18
	b.gt	cs_e1						// If d16 > d18, then branch to cs_e1
cs_if:
	// Making score equal to zero
	mov	x9,	#0					// Move 0 into x9
	scvtf	d16,	x9					// Converting value in x9 to a float and storing result in d16
	str	d16,	[x10]					// Storing d16 into x10

	// Decrementig lives by one
	ldr	x14,	[x29, lives_addr_offset]		// Loading x14 with address of lives
	ldr	w15,	[x14]					// Loading w15 with value of lives
	sub	w15,	w15,	#1				// Subtracting w15 by one
	str	w15,	[x14]					// Storing w15 into address in x14

	// Informing player about losing a life	
	ldr	x0,	=output16				// Load x0 with address of output16
	bl	printf						// Branch and link printf
	
	b	cs_e_if						// Branch to cs_e_if
cs_e1:	

	ldr	d16,	[x29, part_score_offset]		// Load d16 with value of partial score
	ldr	x9,	[x29, score_addr_offset]		// Load x9 with address of score var
	ldr	d17,	[x9]					// Load d17 with value of score

	fadd	d17,	d17,	d16				// Add d17 and d16 ~ Store result in d17
	str	d17,	[x9]					// Store d17 into address in x9 (score)
	
	// Printing partial score
	ldr	x0,	=output17				// Load x0 with address of output17
	fmov	d0,	d16					// Moving d16 into d0
	bl	printf 						// Branch and link printf
		
cs_e_if:	

	ldp	x29,	x30,	[sp],	dealloc			// Restore x29, x30 and deallocate "dealloc" amount of bytes
	ret							// Return to main

	/*--------------------------------------------------------------*/

	/*
	Subroutine prints correct "game over" message and logs results in a file
	Arguments -> x0: lives, d0: score, w1: bombs, x2: name, w3: time played
	Return -> Nothing
	*/
	
	define( exit_tile_found_r,	w9 )			// Defining w9 as exit_tile_found_r
	define( lives_r,		w10 )			// Defining w10 as lives_r
	define( bombs_r,		w11 )			// Defining w11 as bombs_r
	
	lives_size = 4						// Size of local variable lives
	score_size = 8						// Size of local variable score
	bombs_size = 4						// Size of local variable bombs
	name_size = 8						// Size of local variable name
	time_size = 4						// Size of local variable time

	// Number of bytes to allocate for the stack frame (quadword aligned)
	alloc = -(16 + lives_size + score_size + bombs_size + name_size + time_size) & -16 
	dealloc = -alloc					// Number of bytes to deallocate for the stack frame (quadword aligned)

	lives_offset = 16					// Offset to get to variable lives
	score_offset = 20					// Offset to get to variable score
	bombs_offset = 28					// Offset to get to varialbe bombs
	name_offset = 32					// Offset to get to variable name
	time_offset = 40					// Offset to get to variable time
	
ExitGame:
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" amount of bytes	
	mov	x29,	sp					// Moving sp into x29

	str	x0,	[x29, lives_offset]			// Storing x0 in the stack (lives value)
	str	d0,	[x29, score_offset]			// Storing d0 in the stack (score value)
	str	w1,	[x29, bombs_offset]			// Storing x1 in the stack (bombs value)
	str	x2,	[x29, name_offset]			// Store x2 in the stack (name value)
	str	w3,	[x29, time_offset]			// Store w3 in the stack (time value)

	ldr	x12,	=exit_tile_f				// Load x12 with address of exit_tile_f
	ldrsb	exit_tile_found_r,	[x12]			// Load exit_tile_found_r with value at address in x12
	ldr	lives_r,	[x29, lives_offset]		// Load lives_r with value of lives
	ldr	bombs_r,	[x29, bombs_offset]		// Load bombs_r with value of bombs

	cmp	exit_tile_found_r,	#1			// Comparing exit_tile_found_r with #1
	b.eq	exit_if						// If exit_tile_found_r == 1, then branch to exit_if 
	cmp	lives_r,	#0				// Comparing lives_r with #0
	b.eq	exit_else1					// If lives_r == 0, then branch to exit_else1
	cmp	bombs_r,	#0				// Comparing bombs_r with #0
	b.eq	exit_else2					// If bombs_r == 0, then branch to exist_else2
	b	exit_else3					// Else branch to exit_else3
exit_if:
	ldr	x0,	=output19				// Load x0 with address of output19 string
	b	e_exit_if					// Branch to e_exit_if
exit_else1:	
	ldr	x0,	=output20				// Load x0 with address of output20 string
	b	e_exit_if					// Branch to e_exit_if
exit_else2:
	ldr	x0,	=output24				// Load x0 with address of output24 string
	b	e_exit_if					// Branch to e_exit_if
exit_else3:	
	ldr	x0,	=output25				// Load x0 with address of output25
e_exit_if:
	bl	printf						// Branch and link printf

	// Logging game summary into a file
	ldr	x0,	[x29, name_offset]			// Load x0 with address of name
	ldr	d0,	[x29, score_offset]			// Load d0 with value of score
	ldr	w1,	[x29, time_offset]			// Load w1 with value of time played
	bl 	LogGameSummary					// Branch and link LogGameSummary
	
	ldp	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallcoating "dealloc" amount of bytes
	ret							// Returning to main

	/*--------------------------------------------------------------*/

	/*
	Subroutine compares two floats
	Arguments: x0 -> addres of first num, x1 -> address of second num
	Return:	1 (first num > second num) or 0 (first num <= second num) in w0
	*/

	define( a_addr_r,	x9 )				// Defining x9 as a_addr_r
	define( b_addr_r,	x10 )				// Defining x10 as b_addr_r
	define( a_val_r,	d16 )				// Defining d16 as a_val_r
	define( b_val_r,	d17 )				// Defining d17 as b_val_r

Comparator:		
	stp	x29,	x30,	[sp, -16]!			// Allocatinng 16 bytes and storing x29, x30
	mov	x29,	sp					// Move sp into x29
	
	mov	a_addr_r,	x0				// Move x0 into a_addr_r
	mov	b_addr_r,	x1				// Move x1 into b_addr_r

	ldr	a_val_r,	[a_addr_r]			// Load a_val_r with a
	ldr	b_val_r,	[b_addr_r]			// Load b_val_r with b

	fsub	d18,	a_val_r,	b_val_r			// Subtracting a and b ~ Storing result in s18
	fabs	d18,	d18					// Absolute value of s18
	
	mov	w11,	#1000					// Move 1000 into w11
	mov	w12,	#1					// Move 1 into w12
	scvtf	d19,	w11					// Converting w11 into d19
	scvtf	d20,	w12					// Converting w12 into d20
	fdiv	d19,	d20,	d19				// Divising d20 by d19 ~ Storing result in d19
	fcmp	d18,	d19					// Comparing d18 and d19
	b.gt	el1_cmp_if					// if d18 > d19, branch to el1_cmp_if
cmp_if:
	mov	w0,	#0					// Move 0 to w0
	
	b	e_cmp_if					// Branch to e_cmp_if
	
el1_cmp_if:
	fsub	d18,	a_val_r,	b_val_r			// Subracting a and b ~ Store result in s18
	fcmp	d18,	0.0					// Comparing s18 and 0.0		
	b.le	el2_cmp_if					// If s18 < 0.0, then branch to el2_cmp_if
	
	mov	w0,	#1					// Move #1 into w0
	b	e_cmp_if					// Branch to e_cmp_if
	
el2_cmp_if:
	
	mov	w0,	#0					// Move 0 into w0
	
e_cmp_if:	

	ldp	x29,	x30,	[sp],	16			// Restoring x29, x30 and deallocating memory
	ret							// Return to calling code
		
	/*--------------------------------------------------------------*/
	
	define( base_a_r,	x9 )				// Defining x9 as base_a_r
	define( base_b_r,	x10 )				// Defining x10 as base_b_r
	define( tmp_val_r,	x11 )				// Defining x11 as tmp_val_r
	define( tmp_val2_r,	x12 )				// Defining x12 as tmp_val2_r
	define( tmp_float_r,	d16 )				// Defining d16 as tmp_float_r
	define( tmp_float2_r,	d17 )				// Defininng d17 as tmp_float2_r

SwapPlayers:
	stp	x29,	x30,	[sp, -16]!			// Allocating 16 bytes and storing x29, x30
	mov	x29,	sp					// Move sp into x29

	mov	base_a_r,	x0				// Move x0 into base_a_r
	mov	base_b_r,	x1				// Move x1 into base_b_r

	// Swapping names
	ldr	tmp_val_r,	[base_a_r, plyr_name_offset]	// Load tmp_val_r with player's a name
	ldr	tmp_val2_r,	[base_b_r, plyr_name_offset]	// Load tmp_val2_r with player's b name
	str	tmp_val2_r,	[base_a_r, plyr_name_offset]	// Storing tmp_val2_r into player's a name
	str	tmp_val_r,	[base_b_r, plyr_name_offset]	// Storing tmp_val_r into player's b name

	// Swapping scores
	ldr	tmp_float_r,	[base_a_r, scr_offset]		// Load tmp_float_r with player's a score
	ldr	tmp_float2_r,	[base_b_r, scr_offset]		// Load tmp_float2_r with palyer's b score
	str	tmp_float2_r,	[base_a_r, scr_offset]		// Store tmp_float2_r into player's a score
	str	tmp_float_r,	[base_b_r, scr_offset]		// Store tmp_float_r into players's b score

	// Swapping time played
	ldrsw	tmp_val_r,	[base_a_r, time_plyd_offset]	// Load tmp_val_r with player's a time played
	ldrsw	tmp_val2_r,	[base_b_r, time_plyd_offset]	// Load tmp_val2_r with player's b time played
	str	w12,		[base_a_r, time_plyd_offset]	// Store w12 into player's a time played	
	str	w11,		[base_b_r, time_plyd_offset]	// Store w11 into player's b time played

	ldp	x29,	x30,	[sp],	16			// Restored x29, x30 and deallocating memory
	ret							// Return to calling code
	
	/*--------------------------------------------------------------*/
	
	/* 
	Subroutine is in charge of sorting he leaderboard array in descending order based on score
	Arguments: x0 -> base address of the leaderboard array
	Return:	 None
	*/
	
	// Number of bytes to allocate for the stack frame of subroutine (quadword aligned)
	alloc = -(16 + reg_size + reg_size + reg_size + reg_size + reg_size + reg_size) & -16
	dealloc = -alloc					// Number of bytes to deallocate
 	
SortLeaderboard:
	stp	x29,	x30,	[sp, alloc]!			// Allocating memory and storing x29, x30
	mov	x29,	sp					// Moving sp into x29

	// Storing calle-saved registers
	str	x19,	[x29,	r19_offset]			// Storing x19 in the stack
	str	x20,	[x29,	r20_offset]			// Storing x20 in the stack
	str	x21,	[x29,	r21_offset]			// Storing x21 in the stack
	str	x22,	[x29,	r22_offset]			// Storing x22 in the stack
	str	x23,	[x29,	r23_offset]			// Storing x23 in the stack
	str	x24,	[x29,	r24_offset]			// Storing x24 in the stack
	
	mov	base_r,	x0					// Move x0 into base_r
	
	mov	i_r,	#0					// Move 0 into i_r
	add	j_r,	i_r,	#1				// Move i_r + 1 into j_r
	b	sort_l_test					// Branch to sort_l_test
sort_l_loop:

	add	j_r,	i_r,	#1				// Move i_r + 1 into j_r
	b	sort_l_test2					// Branch sort_l_test2
sort_l_loop2:

	// Offset for j
	mov	x9,	player_struct_size			// Move player_struct_size into x9
	mul	offset_r,	j_r,	x9			// Multiplying j_r and x9 ~ Store result in offset_r
	
	// Offset for j-1
	mov	x9,	player_struct_size			// Move player struct size into x9
	sub	x10,	j_r,	#1				// Subtracting j_r by one ~ Store result in x10
	mul	offset2_r,	x10,	x9			// Multiply x10 and x9 ~ Store result in offset2_r

	add	offset_r,	offset_r,	scr_offset	// Add offset_r by scr_offset
	add	offset2_r,	offset2_r,	scr_offset	// Add offset2_r by scr_offset
	add	x0,	base_r,	offset_r			// Mov address of base_r + offset2_r into x0
	add	x1,	base_r,	offset2_r			// Move address of base_r + offset_r into x1
	bl	Comparator					// Branch and link comparator
	cmp	w0,	#0					// Compare w0 with 0
	b.eq	e_sort_if					// If w0 == #0, then branch to e_sort_if
sort_if:
	sub	offset_r,	offset_r,	scr_offset	// Subtracting offset_r by scr_offset
	sub	offset2_r,	offset2_r,	scr_offset	// Subtracting offste2_r by scr_offset
	add	x0,	base_r,	offset_r			// Moving address at base_r + offset_r into x0
	add	x1,	base_r,	offset2_r			// Moving address at base_r + offset2_r into x1
	bl	SwapPlayers					// Branch and link SwapPlayers
e_sort_if:

	sub	j_r,	j_r,	#1				// Subtracting j_r by one
sort_l_test2:
	cmp	j_r,	#0					// Comparing j_r and #0
	b.gt	sort_l_loop2					// If j_r > 0, then branch to sort_l_loop2
	
	add	i_r,	i_r,	#1				// Incrementing i_r by one
sort_l_test:		
	ldr	x9,	=no_players				// Loading x9 with address of no_players
	ldrsw	x9,	[x9]					// Loading x9 with value of no_players
	sub	x9,	x9,	#1
	cmp	i_r,	x9					// Comparing i_r and x9
	b.lt	sort_l_loop					// If i_r < x9, then branch sort_l_loop
	
	// Restoring calle-saved registers
	ldr	x19,	[x29,	r19_offset]			// Load x19 from stack
	ldr	x20,	[x29,	r20_offset]			// Load x20 from stack
	ldr	x21,	[x29,	r21_offset]			// Load x21 from stack	
	ldr	x22,	[x29,	r22_offset]			// Load x22 from stack
	ldr	x23,	[x29,	r23_offset]			// Load x23 from stack
	ldr	x24,	[x29,	r24_offset]			// Load x24 from stack
	
	ldp	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallocating memory
	ret							// Returning to calling code

	/*--------------------------------------------------------------*/

	/*
	Subroutine is in charge of finding the number of players in the leaderboard.
	It opens the file "leaderboard.txt", and read the number of players
	Arguments: None
	Return:	w0 -> Number of players in leaderboard
	*/
	
	num_entries_size = 25					// Size of num_entries local var
	fd_size = 4						// Size of file descriptor

	alloc = -(16 + num_entries_size + fd_size) & -16	// Number of bytes to allocate for the stack frame of the subroutine (quadword aligned)
	dealloc = -alloc					// Number of bytes to deallocate

	fd_offset = 16						// Offset to get the file descriptor
	num_entries_offset = 20					// Offset to get the number of entries 
						
getLeaderboardSize:	
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" number of bytes and storing x29, x30
	mov	x29,	sp					// Moving sp into x29

	// Opening the file named leaderboard.txt
	mov	w0,	-100					// Move -100 into w0
	ldr	x1,	=file0					// Loading x1 with address of file0 string
	mov	w2,	0					// Move 0 into w2
	mov	w3,	0					// Move 0 into w3
	mov	x8,	56					// Move 56 into w8 (openat)
	svc	0						// Service Call

	// Checking for error
	str	w0,	[x29,	fd_offset]			// Loading w0 with file descriptor
	cmp	w0,	#0					// Comparing w0 and 0
	b.ge	open_ok1					// If w0 >= 0, then branch to open_ok1
	ldr	x0,	=error2					// Load x0 with address of error2
	bl	printf						// Branch and link printf
	mov	w0,	0					// Move -1 into w0
	ldp	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallocating memory
	ret							// Returning to calling code
	
open_ok1:

	ldr	w0,	[x29,	fd_offset]			// Load w0 with file descriptor
	add	x1,	x29,	num_entries_offset		// Movig address of num_entries into x1
	mov	x2,	#25					// Moving #1 into x2
	mov	x8,	63					// Move x8 into 63 (read)
	svc	0						// Service Call

	// Calling strtok
	add	x0,	x29,	num_entries_offset		// Moving into x0 the address of num_entries buffer
	ldr	x1,	=separator1				// Loading x1 with addres of separator1 str
	bl	strtok						// Branch and link strtok 
	bl	atoi						// Branch and link atoi
	mov	w9,	w0					// Move w0 into w9
	
	// Closing file named leaderboard.txt
	ldr	w0,	[x29,	fd_offset]			// Load w0 with file descriptor
	mov	x8,	57					// Moving 57 into x8 (close)
	svc	0						// Service Call

	mov	w0,	w9					// Move w9 into w0
	
	ldp	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallocating memory
	ret							// Return to calling code

	/*--------------------------------------------------------------*/
	
	/*
	Subroutine in charge of opening leaderboard.txt and initializing
	the leaderboard array.
	Arguments -> x0: Address of leader board array
	*/

	FILE_ptr_size = 8					// Size of FILE * local var
	line_no_size = 4					// Size of line_no local var
	cur_el_size = 4						// Size of cur_el local var
	line_size = 50						// Size of line buffer

	// Number of bytes to allocate for the stack frame of the subroutine (quadword aligned)
	alloc = -(reg_size + reg_size + reg_size + reg_size + 16 + FILE_ptr_size + line_no_size + cur_el_size + line_size) & -16
	dealloc = -alloc					// Number of bytes to deallocate

	FILE_ptr_offset = 48					// Offset to get File *
	line_no_offset = 56					// Offset to get line_no
	cur_el_offset = 60					// Offset to get cur_el
	line_offset = 64					// Offset to get start address of line buffer
	
InitializeLeaderboard:
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" number of bytes and storing x29, x30
	mov	x29,	sp					// Moving sp into x29 

	// Storing callee-saved registers
	str	x19,	[x29,	r19_offset]			// Storing x19 in the stack
	str	x20,	[x29,	r20_offset]			// Storing x20 in the stack
	str	x21,	[x29,	r21_offset]			// Storing x21 in the stack
	str	x22,	[x29,	r22_offset]			// Storing x22 in the stack
	
	mov	base_r,	x0					// Move 0 into base_r

	ldr	x0,	=file0					// Load x0 with address of file0 string
	ldr	x1,	=file_op0				// Load x1 with address of file_op0
	bl	fopen						// Branch and link fopen
	str	x0,	[x29, FILE_ptr_offset]			// Store x0 into FILE_ptr
	cmp	x0,	#0					// Comparing x0 and #0
	b.ne	init_file_ok					// If x0 != 0, then branch to init_file_ok
	ldr	x0,	=error2					// Load x0 with address of error2 string
	bl	printf						// Branch and link printf
	mov	w0,	#-1					// Move -1 into w0 
	b	init_end					// Branch init_end
init_file_ok:	

	// Initializing variables
	str	xzr,	[x29, line_no_offset]			// Store zero into line_no
	str	wzr,	[x29,	cur_el_offset]			// Store zero into cur_el
	
	b	init_file_test					// Branch to init_file_test
init_file_loop:

	// Skipping first line in the file
	ldr	w9,	[x29, line_no_offset]			// Load w9 with value of line_no
	cmp	w9,	#0					// Comparing w9 with 0
	b.eq	init_t						// If w9 == 0, then branch to init_t

	// Calculating offset
	ldrsw	x9,	[x29, cur_el_offset]			// Load x9 with value of cur_el
	mov	x10,	player_struct_size			// Move player_struct_size into x10
	mul	offset_r,	x9,	x10			// Multiply x9 and x10 ~ Store result in offset_r
	add	offset_r,	offset_r,	plyr_name_offset// Add offset_r by plyr_name_offset

	// Parsing the line from the file into 3 parts (Name, Score, and Time Played)
	// Name
	add	x0,	x29,	line_offset			// Move address of line buffer into x0
	ldr	x1,	=separator				// Loading address of separator string
	bl	strtok						// Branch and linnk strtok
	bl	strdup						// Branch annd link strdup
	str	x0,	[base_r, offset_r]			// Store x0 into leaderboard[cur_el].name

	// Score
	add	offset_r,	offset_r,	scr_offset	// Add offset_r by scr_offset
	mov	w0,	#0 // NULL				// Move 0 into w0
	ldr	x1,	=separator				// Load x1 with address of separator
	bl	strtok						// Branch and link strtok
	bl	atof						// Branch and link atof
	str	d0,	[base_r, offset_r]			// Store d0 into leaderboard[cur_el].score

	// Time Played
	add	offset_r,	offset_r,	#8		// Add offset_r by 8
	mov	w0,	#0 // NULL				// Move 0 into w0
	ldr	x1,	=separator				// Load x1 with address of string separator
	bl	strtok						// Branch and link strtok
	bl	atoi						// Branch and link atoi
	str	w0,	[base_r, offset_r]			// Store w0 into leaderboard[cur_el].timeplayed

	// Increment current element by one
	ldrsw	x9,	[x29, cur_el_offset]			// Load x9 with value of cur_el
	add	x9,	x9,	#1				// Adding x9 by one
	str	w9,	[x29, cur_el_offset]			// Storing x9 into cur_el
init_t:	
	// Incrementing the current line number
	ldr	w9,	[x29,	line_no_offset]			// Load w9 with value of line_no
	add	w9,	w9,	#1				// Adding w9 by one
	str	w9,	[x29,	line_no_offset]			// Storing w9 into line_no
		
init_file_test:
	add	x0,	x29,	line_offset			// Movinng line buffer address into line_offset
	mov	w1,	#50					// Move 50 into w1 (size of buffer)
	ldr	x2,	[x29,	FILE_ptr_offset]		// Loading x2 with the FILE_ptr
	bl	fgets						// Branch and link fgets
	cmp	w0,	#0					// Comparing w0 and #0
	b.ne	init_file_loop					// If w0 != 0 (NULL), then branch to init_file_loop

	// Closing the file
	ldr	x0,	[x29, FILE_ptr_offset]			// Load x0 with FILE*
	bl	fclose						// Branch and link fclose
	
init_end:
	
	// Restoring callee-saved registesrs
	ldr	x19,	[x29,	r19_offset]			// Load x19 from stack
	ldr	x20,	[x29,	r20_offset]			// Load x20 from stack
	ldr	x21,	[x29,	r21_offset]			// Load x21 from stack
	ldr	x22,	[x29,	r22_offset]			// Load x22 frmo stack
	
	ldp	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallocating memory
	ret							// Returning to calling code
	
	/*--------------------------------------------------------------*/

	/*
	Subroutine is in charge of printing the leaderboard from the player array.
	It prints the name, score, and time played (in seconds) of each players.
	The players will be organized in descending order based on their scores.
	Arguments: x0 -> addr of player array, w1 -> number of top players to print
	Return: None
	*/

	num_rec_size = 4					// Size of num_rec var
	see_l_size = 4						// Size of see_l var

	// Number of bytes to allocate for the stack frame of the subroutine (quadword aligned)
	alloc = -(reg_size + reg_size + reg_size + reg_size + 16 + num_rec_size + see_l_size) & -16
	dealloc = -alloc					// Number of bytes to deallocate

	num_rec_offset = 48					// Offset to get num_rec
	see_l_offset = 52					// Offset to get see_l
	
DisplayLeaderboard:
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" number of bytes and storing x29, x30
	mov	x29,	sp					// Moving sp into x29

	// Storing callee-saved registers
	str	x19,	[x29, r19_offset]			// Store x19 in the stack
	str	x20,	[x29, r20_offset]			// Store x20 in the stack
	str	x21,	[x29, r21_offset]			// Store x21 in the stack
	str	x22,	[x29, r22_offset]			// Store x22 in the stack

	ldr	x9,	=no_players				// Load x9 with address of no_players
	ldr	w10,	[x9]					// Load w10 with value of no_players
	cmp	w10,	#0					// Compare w10 to 0
	b.ne	non_empty_l					// If w10 != 0, then branch to non_empty_l
	ldr	x0,	=error10				// Load x0 with address of error10
	bl	printf						// Branch and link printf
	b	disp_l_end					// Branch to disp_l_end
non_empty_l:	
	mov	base_r,	x0					// Move x0 into base_r
	b	disp_l_val1					// Branch to disp_l_val1
disp_error1:	

	ldr	x0,	=error8					// Load x0 with address of error8 string
	bl	printf						// Branch and link printf
	
disp_l_val1:	
	
	// Asking user if he/she wants to see the leaderboard
	ldr	x0,	=output22				// Load x0 with addres of output22 string
	bl	printf						// Branch and link printf
	ldr	x0,	=input0					// Load x0 with address of input0
	add	x1,	x29,	see_l_offset			// Move address of see_l into x1
	bl	scanf						// Branch and link scanf

	// Testing value
	ldr	w9,	[x29, see_l_offset]			// Load w9 with value of see_l
	cmp	w9,	#0					// Comparing w9 and #0 
	b.eq	end_l_val1					// If w9 == 0, then branch to end_l_val1
	cmp	w9,	#1					// Comparing w9 and #1
	b.eq	end_l_val1					// If w9 == 1, then branch to end_l_val1
	b	disp_error1					// Branch to disp_error1
end_l_val1:	

	// In case the player does not want to see the leaderboard
	cmp	w9,	#0					// Comparing w9 and #0
	b.eq	disp_l_end					// If w9 == 0, then branch to disp_l_end
	
	b	disp_l_val2					// Branch to disp_l_val2
disp_error2:	

	ldr	x0,	=error9					// Load x0 with address of error9 string
	ldr	x9,	=no_players				// Load x9 with address of no_players
	ldr	w1,	[x9]					// Load w1 with value of no_players
	bl	printf						// Branch and link printf
	
disp_l_val2:	
	
	// Asking user how many records to retrieve
	ldr	x0,	=output23				// Load x0 with address of output23 string
	bl	printf						// Branch and link printf
	ldr	x0,	=input0					// Load x0 with address of input0 string
	add	x1,	x29,	num_rec_offset			// Move address of num_rec into x1
	bl	scanf						// Branch and link scanf

	// Testing value
	ldr	w9,	[x29, num_rec_offset]			// Load w9 with value of num_rec
	cmp	w9,	#1					// Comparing w9 and #1
	b.lt	disp_error2					// If w9 < 1, then branch to disp_error2
	ldr	x10,	=no_players				// Load x10 with address of no_players
	ldr	w11,	[x10]					// Load w11 with value of no_players
	cmp	w9,	w11					// Comparing w9 and w11
	b.gt	disp_error2					// If w9 > w11, then branch to disp_error2

	// Printing title
	ldr	x0,	=leaderboard0				// Loading x0 with address of leaderboard0
	bl	printf						// Branch and link printf
	ldr	x0,	=leaderboard1				// Loading x0 with address of leaderboard1
	bl	printf						// Branch and link printf
	ldr	x0,	=leaderboard2				// Loading x0 with address of leaderboard2
	bl	printf						// Branch and link printf

	mov	i_r,	#0					// Move 0 into i_r
	b	disp_l_test					// Branch to disp_l_test
disp_l_loop:
	
	// Computing offset
	mov	x9,	player_struct_size			// Move player_struct_size into x9
	mul	offset_r,	i_r,	x9			// Multiply i_r by x9 ~ Store result in offset_r
	add	x9,	offset_r,	#8			// Adding offset_r and #8 ~ Store result in x9
	add	x10,	offset_r,	#16			// Adding offset_r and #16 ~ Store result in x10

	// Printing Scores
	ldr	x0,	=leaderboard3				// Load x0 with address of leaderboard3
	ldr	x1,	[base_r, offset_r]			// Load x1 with value at leaderboard[i].name
	ldr	d0,	[base_r, x9]				// Load d0 with value at leaderboard[i].score
	ldr	w2,	[base_r, x10]				// Load w2 with value at leadeboard[i].timeplayed
	bl	printf						// Branch and link printf
	
	add	i_r,	i_r,	#1				// Make j_r equal to i_r + 1
disp_l_test:
	ldrsw	x9,	[x29, num_rec_offset]			// Load x9 with value of num_rec
	cmp	i_r,	x9					// Compare i_r and x9
	b.lt	disp_l_loop					// If i_r < x9, then branch to disp_l_loop
	
	// Printing new line
	ldr	x0,	=output1				// Load x0 with address of output1
	bl	printf						// Branch and link printf

disp_l_end:	
	
	// Restoring callee-saved registers
	ldr	x19,	[x29, r19_offset]			// Load x19 from stack
	ldr	x20,	[x29, r20_offset]			// Load x20 from stack
	ldr	x21,	[x29, r21_offset]			// Load x21 from stack
	ldr	x22,	[x29, r22_offset]			// Load x22 from stack
	
	ldp	x29, 	x30,	[sp],	dealloc			// Restoring x29, x30 and deallocating memory
	ret							// Return to callign code

	/*--------------------------------------------------------------*/

	/* 
	Subroutine is in charge of updating the players/leaderboard array with the current player's data
	Arguments: x0 -> addr of leaderboar arr, x1 -> name, d0 -> score, w2 -> time played	
	Return:	None
	*/

	FILE_ptr_size = 8					// Size of FILE *					

	// Number of bytes to allocate for the stack frame of the subroutine (quadword aligned)
	alloc = -(16 + reg_size + reg_size + reg_size + reg_size + FILE_ptr_size) & -16
	dealloc = -alloc					// Number of bytes to deallocate

	FILE_ptr_offset = 48					// Offset to get FIlE *
	
UpdateLeaderboard:
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" number of bytes and storing x29, x30
	mov	x29,	sp					// Move sp into x29

	// Storing callee-saved registers
	str	x19,	[x29, r19_offset]			// Load x19 from stack
	str	x20,	[x29, r20_offset]			// Load x20 from stack
	str	x21,	[x29, r21_offset]			// Load x21 from stack
	str	x22,	[x29, r22_offset]			// Load x22 from stack
	
	mov	base_r,	x0					// Move x0 into base_r

	// Updating the leaderboard with data from the current player
	ldr	x9,	=no_players				// Load x9 with address of no_players
	ldrsw	x9,	[x9]					// Load x9 with value of no_players
	mov	x10,	player_struct_size			// Move player_struct_size into x10
	mul	x9,	x9,	x10				// Multiply x9 and x10 ~ Store result in x9
	str	x1,	[base_r, x9]				// Store x1 into base_r + x9 ~ leaderboard[size-1].name
	add	x9,	x9,	scr_offset			// Add x9 by scr_offset
	str	d0,	[base_r, x9]				// Store d0 into base_r + x9 ~ leaderboard[size-1].score
	sub	x9,	x9,	scr_offset			// Subtract x9 by scr_offset
	add	x9,	x9,	time_plyd_offset		// Add x9 by time_plyd_offset
	str	w2,	[base_r, x9]				// Store w2 into base_r + x9 ~ leaderboard[size-1].time_plyd

	// Incrementinng no_players by one
	ldr	x9,	=no_players				// Load x9 with address of no_players
	ldr	w10,	[x9]					// Load w10 with value of no_players
	add	w10,	w10,	#1				// Add w10 by one
	str	w10,	[x9]					// Store w10 in x9
	
	// Sorting the leaderboard
	mov	x0,	base_r					// Move base_r into x0
	bl	SortLeaderboard					// Branch and link SortLeaderboard 

	// Storing updated leaderboard into the text file
	ldr	x0,	=file0					// Load x0 with address of file0
	ldr	x1,	=file_op1				// Load x1 with address of file_op1
	bl	fopen						// Branch and link fopen
	str	x0,	[x29, FILE_ptr_offset]			// Store x0 into FILE_ptr
	cmp	x0,	#0					// Compare x0 and #0
	b.ne	update_file_ok					// If x0 != 0, then branch to update_file_ok 
	ldr	x0,	=error3					// Load x0 with address of error3
	bl	printf						// Branch and link printf
	mov	w0,	-1					// Move -1 into w0
	b	end_update_l					// Branch to end_update_l
update_file_ok:	

	ldr	x0,	[x29, FILE_ptr_offset]			// Load x0 with FILE_ptr
	ldr	x1,	=write0					// Load x1 with address of write0
	ldr	x9,	=no_players				// Load x9 with address of no_players
	ldr	w2,	[x9]					// Load w2 with value of no_players
	bl	fprintf						// Branch and link fprintf

	// Writting all data of players to file
	mov	i_r,	#0					// Move 0 into i_r
	b	update_f_test					// Branch to update_f_tes
update_f_loop:

	// Calculate the offset
	mov	x9,	player_struct_size			// Move player_struct_size into x9
	mul	offset_r,	i_r,	x9			// Multiply i_r and x9 ~ Store result in offset_r

	// Writting data
	ldr	x0,	[x29, FILE_ptr_offset]			// Load x0 with FILE_ptr
	ldr	x1,	=write1					// Load x1 with address of write1	
	ldr	x2,	[base_r, offset_r]			// Load x2 with leaderboard[i].name
	add	offset_r,	offset_r,	scr_offset	// Add offset_r by scr_offset
	ldr	d0,	[base_r, offset_r]			// Load d0 with leaderboard[i].score
	sub	offset_r,	offset_r,	scr_offset	// Subractinng offset_r by scr_offset
	add	offset_r,	offset_r,	time_plyd_offset// Adding offset_r by time_plyd_offset
	ldr	w3,	[base_r, offset_r]			// Loading w3 with leaderboard[i].timeplayed
	bl	fprintf						// Branch and link fprintf

	add	i_r,	i_r,	#1				// Increment i_r by one
update_f_test:
	ldr	x9,	=no_players				// Load x9 with address of no_players
	ldrsw	x9,	[x9]					// Load x9 with value of no_players
	cmp	i_r,	x9					// Comparing i_r with x9
	b.lt	update_f_loop					// If i_r < x9, then branch to update_f_loop

	// Closing file
	ldr	x0,	[x29, FILE_ptr_offset]			// Loading x0 with FILE_ptr
	bl	fclose						// Branch and link fclose
	
end_update_l:

	// Restoring callee-saved registers
	ldr	x19,	[x29, r19_offset]			// Load x19 from stack
	ldr	x20,	[x29, r20_offset]			// Load x20 from stack
	ldr	x21,	[x29, r21_offset]			// Load x21 from stack
	ldr	x22,	[x29, r22_offset]			// Load x22 from stack

	ldp	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallocating memory
	ret							// Return to calling code

	/*--------------------------------------------------------------*/

	/*
	Subroutine is in charge of logging the game summary of the current player
	into a file named game_summary.txt. It logs name, score, and timeplayed (secs)
	Arguments: x0 -> name, d0 -> score, w1 -> time played
	Return:	None
	*/
	
	FILE_ptr_size = 8					// Size of FILE* local var
	name_size = 8						// Size of name	local var
	score_size = 8						// Size of score local var
	time_plyd_size = 4					// Size of time_plyd local var

	// Number of bytes to allocate for stack frame of subroutine (quadwoard aligned)
	alloc = -(16 + FILE_ptr_size + name_size + score_size + time_plyd_size) & -16
	dealloc = -alloc					// Number of bytes to deallcate

	FILE_ptr_offset = 16					// Offset to get FILE *
	name_offset = 24					// Offset to get to name var
	score_offset = 32					// Offset to get to score var
	time_plyd_offset = 40					// Offset to get to time var
	
LogGameSummary:
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" number of bytes and storing x29, x30
	mov	x29,	sp					// Move sp into x29

	// Storing arguments
	str	x0,	[x29, name_offset]			// Store x0 in name
	str	d0,	[x29, score_offset]			// Store d0 in score 
	str	w1,	[x29, time_plyd_offset]			// Store w1 in time_plyd
	
	ldr	x0,	=file1					// Load x0 with address of file1 string
	ldr	x1,	=file_op1				// Load x1 with address of file_op1
	bl	fopen						// Branch and link fopen
	str	x0,	[x29, FILE_ptr_offset]			// Storing x0 in FILE_ptr
	cmp	x0,	#0					// Comparing x0 and #0
	b.ne	log_game_ok					// If x0 != 0, then branch to log_game_ok
	ldr	x0,	=error4					// Load x0 with address of error4 string
	bl	printf						// Branch and link printf
	mov	w0,	#-1					// Move -1 into w0 (to signify an error)
	b	log_game_end					// Branch to log_game_end
log_game_ok:	

	ldr	x0,	[x29, FILE_ptr_offset]			// Load x0 with FILE_ptr
	ldr	x1,	=game_summary0				// Load x1 with address of game_summary0 string
	bl	fprintf						// Branch and link fprintf

	ldr	x0,	[x29, FILE_ptr_offset]			// Load x0 with FILE_ptr
	ldr	x1,	=game_summary1				// Load x1 with address of game_summary1 string
	ldr	x2,	[x29, name_offset]			// Load x2 with name
	bl	fprintf						// Branch and link fprintf

	ldr	x0,	[x29, FILE_ptr_offset]			// Load x0 with FILE_ptr
	ldr	x1,	=game_summary2				// Load x1 with address of game_summary2 string
	ldr	d0,	[x29, score_offset]			// Load d0 with score
	bl	fprintf						// Branch and link fprintf 

	ldr	x0,	[x29, FILE_ptr_offset]			// Load x0 with FILE_ptr
	ldr	x1,	=game_summary3				// Load x1 with address of game_summary3 string
	ldr	w2,	[x29, time_plyd_offset]			// Load w2 with time_plyd		
	bl	fprintf						// Branch and link fprintf

	ldr	x0,	[x29, FILE_ptr_offset]			// Load x0 with FILE_ptr
	ldr	x1,	=game_summary4				// Load x1 with address of game_summary4 string
	bl	fprintf						// Branch and link fprintf

	ldr	x0,	[x29, FILE_ptr_offset]			// Load x0 with FILE_ptr
	bl	fclose 						// Branch and link fclose 

log_game_end:	
	
	ldp	x29,	x30,	[sp],	dealloc			// Restored x29, x30 and deallocate memory
	ret							// Return to calling code

	/*--------------------------------------------------------------*/
	
	name_size = 8						// Size (in bytes) of name
	lives_size = 4						// Size (in bytes) of lives
	score_size = 8						// Size (in bytes) of score
	bombs_size = 4						// Size (in bytes) of bombs
	board_addr_size = 8					// Size (in bytes) of the board's address
	player_arr_addr_size = 8				// Size (in bytes) of the array of player structs
	start_time_size = 4					// Size (in bytes) of the start time 
	end_time_size = 4					// Size (in bytes) of the start time

	// Total amount of bytes to allocate for stack frame of main (quadword aligned)
	alloc = -(coord_struct_size + 16 + name_size + lives_size + score_size + bombs_size + board_addr_size + player_arr_addr_size + start_time_size + end_time_size) & -16 		
	dealloc = -alloc					// Total amount of bytes to deallocate for the stack frame of main (quadword alignned) 	

	name_offset = 16					// Player Name offset
	lives_offset = 24					// Lives offset
	score_offset = 28					// Score offset
	bombs_offset = 36					// Bombs offset
	board_addr_offset = 40					// Board offset
	bombPos_offset = 48					// Offset of bombPos struct
	player_arr_offset = 56					// Offset of Player array addr
	start_time_offset = 64					// Offset to get start time
	end_time_offset = 68					// Offset to get end time
	
	// Main subroutine in charge of running all the code
main:	stp	x29,	x30,	[sp, alloc]!			// Alocating alloc bytes on the stack
	mov	x29,	sp              			// Making x29 "point" to sp

	// Checking that 3 elements where provided (Player Name, Board Height, Board Width)
	cmp	w0,	#4					// Comparing w0 with 4
if_a:	b.eq	e_if_a						// If w0 == 4, then branch to e_if_a
	ldr	x0,	=error0					// Load x0 with address of error0
	bl	printf						// Branch and Link printf
	ldp	x29,	x30,	[sp],	dealloc  		// Deallocating "aloc" bytes memory previously allocated for subroutine main
	ret                     				// Returning to OS
e_if_a:

	// PLAYER NAME 
	mov	base_r,	x1					// Moving x1 into base_r
	mov	i_r,	1					// Movig 1 into i_r
	ldr	x14,	[base_r, i_r, LSL 3]			// Loading x14 with address of string (argv1)
	str	x14,	[x29, name_offset]			// Storing the address in the stack
	mov	x0,	x14					// Move x14 into x0
	bl	strlen						// Branch and link strlen
	cmp	w0,	#15					// Comparing w0 to #15
	b.le	str_length_fine					// If w0 <= 15, then branch to str_length_fine
	ldr	x0,	=error7					// Load x0 with address of error7 string
	bl	printf						// Branch and link printf
	ldp	x29,	x30,	[sp],	dealloc			// Restore x29, x30 and deallocate memory
	ret							// Return to OS
str_length_fine:	

	// HEIGHT
	mov	i_r,	2					// Moving 2 into i_r
	ldr	x0,	[base_r, i_r, LSL 3]			// Loading x0 with address in base_r + (i_r * 8)
	bl	atoi						// Branch and link atoi
	mov	x14,	x0					// Moving integer result x0 into x14

if_b:	cmp	x14,	#10					// Comparig x14 to #10
	b.ge	e_if_b						// If x14 >= 10 then branch to e_if_b

	ldr	x0,	=error1					// Loading register x0 with address  of error1
	bl	printf						// Branch and link printf

	ldp	x29,	x30,	[sp],	dealloc			// Restorinng x29,x30 and deallocatig memory
	ret							// Returning to OS
e_if_b:	

	// Storing height into the stack
	ldr	x15,	=height					// Loading x15 with address of height
	str	w14,	[x15]					// Storing w14,	into address in x15

	// WIDTH
	mov	i_r,	3					// Moving 3 into i_r
	ldr	x0,	[base_r, i_r, LSL 3]			// Loadig x0 with address in base_r + (i_r * 8)
	bl 	atoi						// Branch and link atoi
	mov	w14,	w0					// Move integer result in w0 into w14

if_c:	cmp	w14,	#10					// Comparing w14 with 10
	b.ge	e_if_c						// If w14 >= 10, then branch e_if_c

	ldr	x0,	=error1					// Loading x0 with address of error1
	bl	printf						// Branch and link printf

	ldp	x29,	x30,	[sp],	dealloc			// Restoring x29,x30 and deallocating memory
	ret							// Returning to OS
e_if_c:	

	// Storing width into the stack
	ldr	x15, 	=width					// Loading x15 with the address of width
	str	w14,	[x15]					// Storig w14 into the address in x15
	
	// LIVES
	mov	w14,	#3					// Moving 3 into w14
	str	w14,	[x29, lives_offset]			// Initializing lives to 3

	// SCORE
	mov	x14,	#0					// Moving 0 into x14
	scvtf	d16,	x14					// Converting value in x14 to a float and storing it in d16
	str	d16,	[x29,	score_offset]			// Initializing	score to 0
	
	// BOMBS
	// Calculating the proportion of bombs based of the size of the board (3% of the area of the board)
	ldr 	x14,	=height					// Load x14 with address of height
	ldr	x15,	=width					// Load x15 with address of width
	ldrsw	x14,	[x14]					// Load x14 with value of height
	ldrsw 	x15,	[x15]					// Load x15 with value of width
	mov	x16, 	#3					// Move 3 into x16
	mul	x14,	x14,	x15				// Multiply x14 and x15 ~ Store result in x14
	mul	x14,	x14,	x16				// Multiply x14 and x16 ~ Store result in x14
	mov	x16,	#100					// Move 100 into x16
	udiv	x14,	x14,	x16				// Divide x14 by x16 ~ Store result in x14
	str	w14,	[x29,	bombs_offset]			// Initializing bombs to 3

	// Seeding the rand() function
	bl	sRand						// Branch and link sRand
	
	// BOARD
	ldr	x9,	=height					// Load x9 with address of height
	ldr	x10,	=width					// Load x10 with address of width
	ldrsw	x14,	[x9]					// Load x14 with value of height
	ldrsw	x15,	[x10]					// Load x15 with value of width
	mul	x14,	x14,	x15				// Multiplying x14 and x15 and storing result in x14
	mov	x11,	cell_struct_size			// Moving cell_struct_size into x11
	mul	x14,	x14,	x11				// Multiplying x14 and x11 and storing result in x14
	sub	x14,	xzr,	x14				// Subracting xzr and x14 (res -> -x14)
	and	x14,	x14,	#-16				// Anding x14 and -16 (quadword aligned)
	add	sp,	sp,	x14				// Add sp and x14 (allocating memory for the board)

	// Storing base address of board	
	mov	x14,	sp					// Moving sp into x14
	str	x14,	[x29,	board_addr_offset]		// Storing x14 in the stack at x29 + board_addr_offset

	// Initializing game board
	ldr	x14,	[x29,	board_addr_offset]
	mov	x0,	x14					// Adding x29 and board_addr_offset and storing result in x0
	bl	InitializeGame					// Branch and link InitializeGame
	
	// Getting size of leaderboard (using SVC)
	bl	getLeaderboardSize				// Branch and link getLeaderboardSize				
	ldr	x9,	=no_players				// Load x9 with address of no_players
	str	w0,	[x9]					// Store w0 into no_players (x9)

	// Allocating memory for player struct array
	ldr	x9,	=no_players				// Load x9 with address of no_players
	ldrsw	x9,	[x9]					// Load x9 with value of no_players
	add	x9,	x9,	#1				// Incrementing x9 by one
	mov	x10,	player_struct_size			// Moving player_struct_size into x10
	mul	x9,	x9,	x10				// Multiplying x9 and x10 ~ Store result in x9
	sub	x9,	xzr,	x9				// Negating x9
	and	x9,	x9,	#-16				// Anding x9 with -16 
	add	sp,	sp,	x9				// Adding x9 and sp (allocating memory)
	mov	x9,	sp					// Move sp into x9
	str	x9,	[x29, player_arr_offset]		// Store x9 into player_arr
		
	// Initializing leaderboard (from file)
	ldr	x0,	[x29, player_arr_offset]		// Load x0 with the address of the player_arr
	bl	InitializeLeaderboard				// Branch and link InitializeLeaderboard
	
	// Printing uncovered board (for grading)
	ldr	x0,	[x29,	board_addr_offset]		// Adding x29 and board_addr_offset and storing result in x0
	bl	UncoveredBoard					// Branch and link UnocoveredBoard

	ldr	x0,	=output1				// Load x0 with address of output1
	bl	printf						// Branch and link printf

	// Asking player if he/she wants to see the leaderboard
	ldr	x0,	[x29, player_arr_offset]
	bl	DisplayLeaderboard				// Branch and link DisplayLeaderboard

	// Getting start time of game
	mov	x0,	#0					// Move 0 (NULL) into x0
	bl	time						// Branch and link time
	str	w0,	[x29, start_time_offset]		// Store w0 into start_time
	
main_loop:

	// Printing covered board
	ldr	x0,	[x29,	board_addr_offset]		// Loading x0 with board address
	ldr	x1,	[x29,	lives_offset]			// Loading x1 with lives value
	ldr	d0,	[x29,	score_offset]			// Loading d0 with score value
	ldr	w2,	[x29,	bombs_offset]			// Loadin x2 with bombs value
	bl	DisplayGame					// Branch and link DisplayGame

	// Asking for x-coordinate and validating range
	b	main_val1					// Branch to main_val1
error_val1:	

	// Error if value is not in range
	ldr	x0,	=error5					// Load x0 with address of error5 string
	ldr	x9,	=height					// Load x9 with address of height
	ldrsw	x9,	[x9]					// Load x9 with value of height
	mov	x1,	x9					// Move x9 into x1
	bl	printf						// Branch and link printf
	
main_val1:

	// Prompting user
	ldr	x0,	=output12				// Loadig x0 with address of output12
	bl	printf						// Branch and link

	mov	offset_r,	bombPos_offset			// Moving bombPos_offset into offset_r
	add	offset_r,	offset_r,	xcoord_offset	// Adding offset_r and xcoord_offset
	ldr	x0,	=input0					// Loading x0 with address of input0
	add	x1,	x29,	offset_r			// Addinng x29 and offset_r and storing result in x1
	bl	scanf						// Branch and link scanf
main_test_val1:
	ldr	x9,	=height					// Load x9 with address of height
	ldrsw	x9,	[x9]					// Load x9 with value of height
	ldrsw	x10,	[x29, offset_r]				// Load x10 with value at coord.x
	cmp	x10,	#-1					// Comparing x10 and -1 
	b.lt	error_val1					// If x10 < -1, then branch to error_val1
	cmp	x10,	x9					// Comparing x10 and x9
	b.ge	error_val1					// If x10 >= x9, then branch to error_val1

	cmp	x10,	#-1					// Comparing x10 and -1		
	b.ne	continue1					// If x10 != -1, then branch to continue1
	b	end_main_loop					// Branch to end_main_loop
continue1:	
	
	// Asking for y-coordinate and validating range
	b	main_val2					// Branch to main_val2
error_val2:

	// Error if value is not in range
	ldr	x0,	=error6					// Load x0 with address of error6 string
	ldr	x9,	=width					// Load x9 with address of width
	ldrsw	x9,	[x9]					// Load x9 with value of width
	mov	x1,	x9					// Move x9 into x1
	bl	printf						// Branch and link printf

main_val2:	

	// Prompting user 
	ldr	x0,	=output13				// Load x0 with address of output13
	bl	printf						// Branch and link printf

	mov	offset_r,	bombPos_offset			// Moving bombPos_offset into offset_r
	add	offset_r,	offset_r,	ycoord_offset	// Adding offset_r and ycoord_offset 
	ldr	x0,	=input0					// Loading x0 with address of input0
	add	x1,	x29,	offset_r			// Adding x29 and offset_r and storing result in x1
	bl	scanf						// Branch and link scanf
main_test_val2:
	ldr	x9,	=width					// Load with address of width	
	ldrsw	x9,	[x9]					// Load x9 with value of width
	ldrsw	x10,	[x29, offset_r]				// Load x10 with value coord.y
	cmp	x10,	#-1					// Comparing x10 with -1
	b.lt	error_val2					// If x10 < -1, then branch to error_val2
	cmp	x10,	x9					// Comparing x10 and x9
	b.ge	error_val2					// If x10 >= x9, then branch to error_val2

	cmp	x10,	#-1					// Comparinng x10 and -1
	b.ne	continue2					// If x10 != -1, branch to continue2
	b	end_main_loop					// Branch to end_main_loop
continue2:

	// Calling calculate score
	ldr	x0,	[x29,	board_addr_offset]		// Loading x0 with board's address
	add	x1,	x29,	score_offset			// x1 -> score's address
	add	x2,	x29,	lives_offset			// x2 -> live's address
	add	x3,	x29,	bombs_offset			// x3 -> bombs's address 
	add	x4,	x29,	bombPos_offset			// x4 -> bombPos' address
	bl	CalculateScore					// Branch and link calculate score
		
main_test:
	ldrsw	x9,	[x29,	lives_offset]			// Loading x9 with lives value
	cmp 	x9,	#0					// Comparing x9 with 0
	b.le	end_main_loop					// If x9 <= 0, then branch end_main_loop
	ldr	x9,	=exit_tile_f				// Load x9 with address of exit_tile_f
	ldrsb	w10,	[x9]					// Load w10 with value of exit_tile_f
	cmp 	w10,	#1					// Comparing w10 and #1
	b.eq	end_main_loop					// If w10 == #1, then branch end_main_loop
	ldrsw	x9,	[x29,	bombs_offset]			// Load x9 with value of bombs
	cmp	x9,	#0					// Comparing x9 and #0
	b.le	end_main_loop					// If x9 <= #0, branch end_main_loop
	b	main_loop					// Branch to main_loop (if all comparisons above are false)
end_main_loop:	

	// Getting end time of game
	mov	x0,	#0					// Move 0 (NULL) into x0
	bl	time						// Branch and link time
	str	w0,	[x29, end_time_offset]			// Store w0 into end_time
	
	// Printing covered board (one last time)
	ldr	x0,	[x29, board_addr_offset]		// Adding x29 and board_addr_offset and storing result in x0
	ldr	x1,	[x29, lives_offset]			// Load x1 with value of lives
	ldr	d0,	[x29, score_offset]			// Load d0 with value of score
	ldr	w2,	[x29, bombs_offset]			// load x2 with value of bombs
	bl	DisplayGame					// Branch and link DisplayGame

	// Updating the leaderboard arr and file
	ldr	x0,	[x29, player_arr_offset]		// Load x0 with the player_array's address
	ldr	x1, 	[x29, name_offset]			// Load x1 with the name of the player
	ldr	d0,	[x29, score_offset]			// Load d0 with the score of the player
	ldr	w9,	[x29, start_time_offset]		// Load w9 with value of start_time
	ldr	w10,	[x29, end_time_offset]			// Load w10 with value of end_time
	sub	w2,	w10,	w9				// Moving end_time - start_time into w2
	bl UpdateLeaderboard					// Branch and link UpdateLeaderboard

	// Exiting the game
	ldr	x0,	[x29, lives_offset]			// Load x9 with value of lives
	ldr	d0,	[x29, score_offset]			// Load d0 with value of score 
	ldr	w1,	[x29, bombs_offset]			// Load x1 with value of bombs
	ldr	x2,	[x29, name_offset]			// Load x2 with address of name
	ldr	w9,	[x29, start_time_offset]		// Load w9 with value of start_time
	ldr	w10,	[x29, end_time_offset]			// Load	w10 with value of end_time
	sub	w3,	w10,	w9				// Moving end_time - start_time into w3
	bl	ExitGame					// Branch and link ExitGame
		
	// Asking player if he/she wants to see the leaderboard
	ldr	x0,	[x29, player_arr_offset]		// Load x0 with the address of the player array
	bl	DisplayLeaderboard				// Branch and link DisplayLeaderboard

	// Deallocating memory for player struct
	ldr	x9,	=no_players				// Loading x9 with address of no_players
	ldrsw	x9,	[x9]					// Loading x9 with value of no_players
	mov	x10,	player_struct_size			// Moving player_struct_size into x10
	mul	x9,	x9,	x10				// Multiplying x9 and x10 ~ Storing result in x9
	sub	x9,	xzr,	x9				// Negating x9
	and	x9,	x9,	#-16				// Anding x9 with -16
	sub	sp,	sp,	x9				// Subtracting sp by x9 (deallocating memory)
	
	// Deallocating memory for the 2D board
	ldr	x9,	=height					// Load x9 with address of height			
	ldr	x10,	=width					// Load x10 with address of width
	ldrsw	x14,	[x9]					// Load x14 with value of height 
	ldrsw	x15,	[x10]					// Load x15 with value of width
	mul	x14,	x14,	x15				// Multiplying x14 and x15 and storing result in x14
	mov	x11,	cell_struct_size			// Moving cell_struct_size into x11
	mul	x14,	x14,	x11				// Multiplying x14 and x11 and storing result in x14
	sub	x14,	xzr,	x14				// Subtracting 0 and x14
	and	x14,	x14,	#-16				// Anding x14 and -16 (quadword aligned)
	sub	sp,	sp,	x14				// Subtracting sp and x14 (deallocating memory)

	ldp	x29,	x30,	[sp],	dealloc  		// Deallocating "dealloc" bytes memory previously allocated for subroutine main
	ret                     				// Returning to operating system

	.data                    				// Defining variables
height:		.int	0					// Height ~ int variable declared (initially zero)
width:		.int	0					// Width ~ in variable declared (initially zero)
seconds: 	.long	0                 			// Defining a long variable initialized to zero
neg_cells:	.int	0					// Definig and int variable initialized to zero
db_cells:	.int 	0					// Defining an int variable initialized to zero
db_reward_count:.int	0					// Defining an int variable initialized to zero
exit_tile_f:	.byte 	0					// Defining a byte variable initialized to zero (boolean)
no_players:	.int	0					// Defininng a int variable initialized to zero
reward_active:	.byte	0					// Defining a byte variable initialized to zero (boolean)
	
	
