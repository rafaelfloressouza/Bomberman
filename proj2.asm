	// Final Project Part 2 - Bomberman
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
output12:	.string "\nEnter x position or quit (q): "
output13:	.string "\nEnter y position or quit (q): "
output14:	.string "\nGame state not stored\nBye...\n"
output15:	.string "\nBoom!! You found %d double range reward(s) (apply to next bomb only) | stackable\n\n"
output16:	.string "Oops! You loose a life because score is <= 0\n\n"
output17:	.string "Total uncovered score of %.2f points\n\n"
output18:	.string "Lives: %d\nScore %.2f\nBombs: %d\n"
output19:	.string "\n\nCongratulations, you won!!\n\n"
output20:	.string "\n\nGame Over, You lose !!\n\n"
output21:	.string "Test Number: %f\n"
output22:	.string  "Your name is: %s\n"
error0:		.string "Not enough arguments provided!\n"
error1:		.string "Height and Width have to be >=10\n"
error2:		.string "\nThere is no leaderboard yet. Play the game to be added to it!\n"
input0:		.string "%d"
input1:		.string "%s"
file0:		.string "leaderboard.txt"
file_op0:	.string "r"
separator:	.string " "
leaderboard0:	.string "------------------LEADERBOARD------------------\n"
leaderboard1:	.string "Name\t\tScore\t\tTime Played\n"
leaderboard2:	.string "-----------------------------------------------\n"
leaderboard3:	.string "%-15s\t%4.2f\t\t%d\n"
test:		.string "%s\t%f\%d\n"
	.balign	4                				// Adding 4 bytes of padding (to keep everything consistent)
	.global main             				// Making main global to the linker (OS)

	define(	base_r,		x19 )				// Defining x19 as base_r
	define( i_r,		x20 ) 				// Defining x20 as i_r 
	define( j_r,		x21 )				// Defining x21 as j_r
	define( offset_r,	x22 )				// Defining x22 as offset_r
	define(	tmp_r,		x23 )				// Defining x23 as tmp_r
	define( offset2_r,	x24 )				// Definig x24 as offset2_r

	// Register offsets (for restoring them)
	reg_size = 8
	r19_offset = 16
	r20_offset = 24
	r21_offset = 32
	r22_offset = 40
	r23_offset = 48
	r24_offset = 56
	
	// CELL STRUCT {bool discovered, float value}
	cell_struct_size = 9
	discovered_offset = 0
	value_offset = 1

	// COORDINATE STRUCT {int xCoord, int yCoord}
	coord_struct_size = 8
	xcoord_offset = 0
	ycoord_offset = 4

	// PLAYER STRUCT
	player_struct_size = 20
	plyr_name_offset = 0
	scr_offset = 8
	time_plyd_offset = 16
	
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
	between the given lower_bound (w0) and upper_bound (w1)
	Returns the random number in w0
	*/
	l_bound_size = 4
	u_bound_size = 4

	alloc = -(16 + l_bound_size + u_bound_size) & -16
	dealloc = -alloc

	l_bound_offset = 16
	u_bound_offset = 20
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

/*
	mov	w10,	w14					// Moving w14 into w10 (number in range 0-upper_bound)

	// If lower_bound != 0
if_rand2:
	ldrsw	x14,	[x29,	l_bound_offset]
	cmp	x14,	#0
	b.eq	e_if_rand2
	
	ldrsw	x14,	[x29,	l_bound_offset]
	ldrsw	x15,	[x29,	u_bound_offset]
	sub	x14,	x15,	x14
	mov	x15,	#1
	b	test_b
loop_b:	
	lsl	x15,	x15,	#1
test_b:	cmp	x15,	x14
	b.le	loop_b
	
if_rand3:
	ldr	w11,	[x29,	l_bound_ofsset]
	cmp	w10,	w11
	b.ge	e_if_rand3
	
	and	w10,	w10,	w15
	ldr	w11,	[x29,	l_bound_offset]
	add	w14,	w11,	w10
e_if_rand3:

	mov	w10,	w14
	
e_if_rand2:	
	
	mov	w0,	w10
	*/
	
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
	Arguments -> x0: board's address, w1: lives, d0: score, w3: bombs	 
	Does not return anything
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

	mov	x13,	#1					// Moving #1 into x13
	lsl	tmp_r,	x13,	x11				// Left shit x13 by x11

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
	ldr	x9,	=db_reward_count			// Load x9 with address of db_reward_count
	ldrsw	x9,	[x9]					// Load x9 with value of db_reward_count
	cmp	x9,	#0					// Comparing x9 and #0
	b.le	csh_print_end					// If x9 <= 0, then branch csh_print_end
csh_print:
	ldr	x0,	=output15				// Load x0 whith address of string output15
	mov	x1,	x9					// Moving x9 into x1
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
	Argumets -> x0: lives, d0: score, x1: bombs
	Return -> Nothing
	*/

	lives_size = 4						// Size of local variable lives
	score_size= 8						// Size of local variable score
	bombs_size = 4						// Size of local variable bombs

	// Number of bytes to allocate for the stack frame (quadword aligned)
	alloc = -(16 + lives_size + score_size + bombs_size) & -16 
	dealloc = -alloc					// Number of bytes to deallocate for the stack frame (quadword aligned)

	lives_offset = 16					// Offset to get to variable lives
	score_offset = 20					// Offset to get to variable score
	bombs_offset = 28					// Offset to get to varialbe bombs

ExitGame:
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" amount of bytes	
	mov	x29,	sp					// Moving sp into x29

	str	x0,	[x29, lives_offset]			// Storing x0 in the stack (lives value)
	str	d0,	[x29, score_offset]			// Storing d0 in the stack (score value)
	str	x1,	[x29, bombs_offset]			// Storing x1 in the stack (bombs value)

	ldr	x9,	=exit_tile_f				// Load x9 with address of exit_tile_f
	ldrsb	w9,	[x9]					// Load x9 with value of exit_tile_f
	ldr	w10,	[x29, lives_offset]			// Load w10 with value of lives

	cmp	w9,	#1					// Comparing w9 and #1
	b.ne	exit_else					// If w9 != 1, then branch to exit_else
	cmp	w10,	#0					// Comparinng w10 and #0
	b.le	exit_else					// If w10 <= #0, then branch to exit_else
	ldr	w11,	[x29, bombs_offset]			// Load w11 with value of bombs
	cmp	w11,	#0					// Comapring w11 with #0
	b.eq	exit_else					// if w11 <= #0, then branch to exit_else
exit_if:
	ldr	x0,	=output19				// Load x0 with address of output19
	b	end_exit_if					// Branch end_exit_if
exit_else:	
	ldr	x0,	=output20				// Load x0 with address of output20
end_exit_if:	
	bl	printf						// Branch and link printf
	
	ldp	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallcoating "dealloc" amount of bytes
	ret							// Returning to main

	/*--------------------------------------------------------------*/

	/* 
	Subroutine is in charge of sorting he leaderboard array in descending order based on score
	Arguments: x0 -> base address of the leaderboard array
	Return:	 None
	*/
	
	player_size = 20					// Size of player struct

	// Number of bytes to allocate for the stack frame of subroutine (quadword aligned)
	alloc = -(16 + reg_size + reg_size + reg_size + reg_size + reg_size + reg_size + player_size) & -16
	dealloc = -alloc					// Number of bytes to deallocate

	player_offset = 64					// Offset to get the player struct
 	
SortLeaderBoard:
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

	// Computing offset for j
	mov	x9,	player_struct_size			// Move player_struct_size into x9
	mul	offset_r,	j_r,	x9			// Multiply j_r and x9 ~ Store result in offset_r	
	
	// Computing offset for j - 1
	sub	x10,	j_r,	#1				// Subtract j_r by 1 ~ Store result in x10
	mul	offset2_r,	x9,	x10			// Multiply x9 and x10 ~ Store result in offset2_r

	// Storing value of players[j] into our leaderboard (tmp var)
	ldr	x9,	[base_r, offset_r] 			// Load x9 with value at leaderboard[j].name
	str	x9,	[x29, player_offset]			// Store x9 into player.name
	add	offset_r,	offset_r,	scr_offset	// Adding offset_r and scr_offset
	ldr	d16,	[base_r, offset_r]			// Loading d16 with value at leaderboard[j].score
	str	d16,	[x29,	player_offset + scr_offset]	// Storing d16 into player.score
	sub	offset_r,	offset_r,	scr_offset	// Subtracting offset_r and scr_offset
	add	offset_r,	offset_r,	time_plyd_offset// Adding offset_r and time_plyd_offset
	ldrsw	x9,	[base_r, offset_r]			// Load x9 with value at leaderboard[j].timeplayed
	str	w9,	[x29, player_offset + time_plyd_offset]	// Storing w9 into player.timeplayed
	sub	offset_r,	offset_r,	time_plyd_offset// Subtracting offset_r and time_plyd_offset
	
	// Storing leaderboard[j - 1] to leaderboard[j]
	ldr	x9,	[base_r, offset2_r]			// Loading x9 with value at leaderboard[j-1].name
	str	x9,	[base_r, offset_r]			// Storing x9 at leaderboard[j].name
	add	offset_r,	offset_r,	scr_offset	// Adding offset_r by scr_offset
	add	offset2_r,	offset2_r,	scr_offset	// adding offset2_r by scr_offset
	ldr	d16,	[base_r, offset2_r]			// Loading d16 with value at leaerboard[j-1].score
	str	d16,	[base_r, offset_r]			// Storing d16 at leaderboard[j].score 
	sub	offset_r,	offset_r,	scr_offset	// Subtracting offset_r and scr_offset
	sub	offset2_r,	offset2_r,	scr_offset	// Subtracting offset2_r and scr_offset
	add	offset_r,	offset_r,	time_plyd_offset// Adding offset_r by time_plyd_offset
	add	offset2_r,	offset2_r,	time_plyd_offset// Adding offset2_r by time_plyd_offset
	ldrsw	x9,	[base_r, offset2_r]			// Load x9 with value at leaderboard[j-1].timeplayed	
	str	w9,	[base_r, offset_r]			// Storing value at leaderboard[j].timeplayed
	sub	offset_r,	offset_r,	time_plyd_offset// Subtracting offset_r by time_plyd_offset
	sub	offset2_r,	offset2_r,	time_plyd_offset// Subtracting offset2_r by time_plyd_offset

	// Storing player into leaderboard[j-1]
	ldr	x9,	[x29, player_offset]			// Load x9 with value at player.name
	str	x9,	[base_r, offset2_r]			// Storing x9 at leaderboard[j-1].name
	add	offset2_r,	offset2_r,	scr_offset	// Adding offset2_r by scr_offset
	ldr	d16,	[x29, player_offset + scr_offset] 	// Loading d16 with value at player.score
	str	d16,	[base_r, offset2_r]			// Storing d16 at leaderboard[j-1].score
	sub	offset2_r,	offset2_r,	scr_offset	// Subtracting offset2_r by scr_offset
	add	offset2_r,	offset2_r,	time_plyd_offset// Adding offset2_r by time_plyd_offset
	ldrsw	x9,	[x29, player_offset + time_plyd_offset]	// Loading x9 with value at player.timeplayed
	str	w9,	[base_r, offset2_r]			// Store w9 at leaderboard[j-1].timeplayed
	sub	offset2_r,	offset2_r,	time_plyd_offset// Subtracting offset2_r by time_plyd_offset

	sub	j_r,	j_r,	#1				// Subtracting j_r by one
sort_l_test2:
	cmp	j_r,	#0					// Comparing j_r and #0
	b.gt	sort_l_loop2					// If j_r > 0, then branch to sort_l_loop2
	

	add	i_r,	i_r,	#1				// Incrementing i_r by one
sort_l_test:		
	ldr	x9,	=no_players				// Loading x9 with address of no_players
	ldrsw	x9,	[x9]					// Loading x9 with value of no_players
	add	x9,	x9,	#1				// Incrementing x9 by one
	cmp	i_r,	x9					// Comparing i_r and x9
	b.lt	sort_l_loop					// If i_r < x9, then branch sort_l_loop
	
	// Restoring calle-saved registers
	ldr	x19,	[x29,	r19_offset]			// Load x19 from stack
	ldr	x20,	[x29,	r20_offset]			// Load x20 from stack
	ldr	x21,	[x29,	r21_offset]			// Load x21 from stack	
	ldr	x22,	[x29,	r22_offset]			// Load x22 from stack
	ldr	x22,	[x29,	r23_offset]			// Load x23 from stack
	ldr	x22,	[x29,	r24_offset]			// Load x24 from stack
	
	ldp	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallocating memory
	ret							// Returning to calling code

	/*--------------------------------------------------------------*/

	/*
	Subroutine is in charge of finding the number of players in the leaderboard.
	It opens the file "leaderboard.txt", and read the number of players
	Arguments: None
	Return:	w0 -> Number of players in leaderboard
	*/
	
	num_entries_size = 1
	fd_size = 4

	alloc = -(16 + num_entries_size + fd_size) & -16
	dealloc = -alloc

	num_entries_offset = 16
	fd_offset = 17

getLeaderboardSize:	
	stp	x29,	x30,	[sp, alloc]!
	mov	x29,	sp

	// Opening the file named leaderboard.txt
	mov	w0,	-100
	ldr	x1,	=file0
	mov	w2,	0
	mov	w3,	0
	mov	x8,	56
	svc	0

	// Checking for error
	str	w0,	[x29,	fd_offset]
	cmp	w0,	#0
	b.ge	open_ok1
	ldr	x0,	=error2
	bl	printf
	mov	w0,	-1
	ldp	x29,	x30,	[sp],	dealloc
	ret
	
open_ok1:

	ldr	w0,	[x29,	fd_offset]
	add	x1,	x29,	num_entries_offset
	mov	x2,	1
	mov	x8,	63
	svc	0

	// Closing file named leaderboard.txt
	ldr	w0,	[x29,	fd_offset]
	mov	x8,	57
	svc	0

	// Returning size of leaderboard
	ldrsb	w0,	[x29, num_entries_offset]
	sub	w0,	w0,	#48
	
	ldp	x29,	x30,	[sp],	dealloc
	ret

	/*--------------------------------------------------------------*/
	
	/*
	Subroutine in charge of opening leaderboard.txt and initializing
	the leaderboard array.
	Arguments -> x0: Address of leader board array
	*/

	FILE_ptr_size = 8
	line_no_size = 4
	cur_el_size = 4
	line_size = 50
	
	alloc = -(reg_size + reg_size + reg_size + reg_size + 16 + FILE_ptr_size + line_no_size + cur_el_size + line_size) & -16
	dealloc = -alloc

	FILE_ptr_offset = 48
	line_no_offset = 56
	cur_el_offset = 60
	line_offset = 64
	
InitializeLeaderboard:
	stp	x29,	x30,	[sp, alloc]!
	mov	x29,	sp

	// Storing callee-saved registers
	str	x19,	[x29,	r19_offset]
	str	x20,	[x29,	r20_offset]
	str	x21,	[x29,	r21_offset]
	str	x22,	[x29,	r22_offset]
	
	mov	base_r,	x0

	ldr	x0,	=file0
	ldr	x1,	=file_op0
	bl	fopen
	str	x0,	[x29, FILE_ptr_offset]
	cmp	x0,	#0
	b.ne	init_file_ok
	ldr	x0,	=error2
	bl	printf
	mov	w0,	#-1
	b	init_end
init_file_ok:	

	// Initializing variables
	str	xzr,	[x29, line_no_offset]
	str	wzr,	[x29,	cur_el_offset]

	b	init_file_test
init_file_loop:

	// Skipping first line in the file
	ldr	w9,	[x29, line_no_offset]
	cmp	w9,	#0
	b.eq	init_t

	// Calculating offset
	ldrsw	x9,	[x29, cur_el_offset]
	mov	x10,	player_struct_size
	mul	offset_r,	x9,	x10
	add	offset_r,	offset_r,	plyr_name_offset

	// Parsing the line from the file into 3 parts (Name, Score, and Time Played)
	// Name
	add	x0,	x29,	line_offset
	ldr	x1,	=separator
	bl	strtok
	bl	strdup
	str	x0,	[base_r, offset_r]

	// Score
	add	offset_r,	offset_r,	scr_offset
	mov	w0,	#0 // NULL
	ldr	x1,	=separator
	bl	strtok
	bl	atof
	str	d0,	[base_r, offset_r]

	// Time Played
	add	offset_r,	offset_r,	#8
	mov	w0,	#0 // NULL
	ldr	x1,	=separator
	bl	strtok
	bl	atoi
	str	w0,	[base_r, offset_r]

	// Increment current element by one
	ldrsw	x9,	[x29, cur_el_offset]
	add	x9,	x9,	#1
	str	w9,	[x29, cur_el_offset]
init_t:	
	// Incrementing the current line number
	ldr	w9,	[x29,	line_no_offset]
	add	w9,	w9,	#1
	str	w9,	[x29,	line_no_offset]
		
init_file_test:
	add	x0,	x29,	line_offset
	mov	w1,	#50
	ldr	x2,	[x29,	FILE_ptr_offset]
	bl	fgets
	cmp	w0,	#0
	b.ne	init_file_loop
	
init_end:
	
	// Restoring callee-saved registesrs
	ldr	x19,	[x29,	r19_offset]
	ldr	x20,	[x29,	r20_offset]
	ldr	x21,	[x29,	r21_offset]
	ldr	x22,	[x29,	r22_offset]
	
	ldp	x29,	x30,	[sp],	dealloc
	ret
	
	/*--------------------------------------------------------------*/

	alloc = -(reg_size + reg_size + reg_size + reg_size + 16) & -16
	dealloc = -alloc
 	
DisplayLeaderboard:
	stp	x29,	x30,	[sp, alloc]!
	mov	x29,	sp

	// Storing callee-saved registers
	str	x19,	[x29,	r19_offset]
	str	x20,	[x29,	r20_offset]
	str	x21,	[x29,	r21_offset]
	str	x22,	[x29,	r22_offset]

	mov	base_r,	x0

	// Printing title
	ldr	x0,	=leaderboard0
	bl	printf
	ldr	x0,	=leaderboard1
	bl	printf
	ldr	x0,	=leaderboard2
	bl	printf

	mov	i_r,	#0
	b	disp_l_test
disp_l_loop:
	
	// Computing offset
	mov	x9,	player_struct_size
	mul	offset_r,	i_r,	x9
	add	x9,	offset_r,	#8	
	add	x10,	offset_r,	#16

	// Printing Scores
	ldr	x0,	=leaderboard3
	ldr	x1,	[base_r, offset_r]
	ldr	d0,	[base_r, x9]
	ldr	w2,	[base_r, x10]
	bl	printf
	
	add	i_r,	i_r,	#1
disp_l_test:
	ldr	x9,	=no_players
	ldrsw	x9,	[x9]
	cmp	i_r,	x9
	b.lt	disp_l_loop

	// Printing new line
	ldr	x0,	=output1
	bl	printf
	
	// Restoring callee-saved registesrs
	ldr	x19,	[x29,	r19_offset]
	ldr	x20,	[x29,	r20_offset]
	ldr	x21,	[x29,	r21_offset]
	ldr	x22,	[x29,	r22_offset]
	
	ldp	x29, 	x30,	[sp],	dealloc
	ret

	/*--------------------------------------------------------------*/
	
UpdateLeaderboard:
	stp	x29,	x30,	[sp, -16]!
	mov	x29,	sp


	ldp	x29,	x30,	[sp], 16
	ret

	/*--------------------------------------------------------------*/
	
	name_size = 8						// Size (in bytes) of name
	lives_size = 4						// Size (in bytes) of lives
	score_size = 8						// Size (in bytes) of score
	bombs_size = 4						// Size (in bytes) of bombs
	board_addr_size = 8					// Size (in bytes) of the board's address
	player_arr_addr_size = 8				// Size (in bytes) of the array of player structs

	// Total amount of bytes to allocate for stack frame of main (quadword aligned)
	alloc = -(coord_struct_size + 16 + name_size + lives_size + score_size + bombs_size + board_addr_size + player_arr_addr_size) & -16 		
	dealloc = -alloc					// Total amount of bytes to deallocate for the stack frame of main (quadword alignned) 	

	name_offset = 16					// Player Name offset
	lives_offset = 24					// Lives offset
	score_offset = 28					// Score offset
	bombs_offset = 36					// Bombs offset
	board_addr_offset = 40					// Board offset
	bombPos_offset = 48					// Offset of bombPos struct
	player_arr_offset = 56
	
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

	// HEIGHT
	mov	i_r,	2					// Moving 2 into i_r
	ldr	x0,	[base_r, i_r, LSL 3]			// Loading x0 with address in base_r + (i_r * 8)
	bl	atoi						// Branch and link atoi
	mov	x14,	x0					// Moving integer result x0 into x14

if_b:	cmp	x14,	#10					// Comparig x14 to #10
	b.ge	e_if_b						// If x14 >= 10 thenn branch to e_if_b

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
	mov	w14,	#3					// Moving 3 into w14
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

	// Getting size of leaderboard
	bl	getLeaderboardSize				
	ldr	x9,	=no_players
	str	w0,	[x9]
	
	// Allocating memory for player struct array
	ldr	x9,	=no_players
	ldrsw	x9,	[x9]
	add	x9,	x9,	#1
	mov	x10,	player_struct_size
	mul	x9,	x9,	x10
	sub	x9,	xzr,	x9
	and	x9,	x9,	#-16
	add	sp,	sp,	x9
	mov	x9,	sp
	str	x9,	[x29, player_arr_offset]
	
	// Initializing leaderboard (from file)
	ldr	x0,	[x29, player_arr_offset]
	bl	InitializeLeaderboard

	// Printing uncovered board (for grading)
	ldr	x0,	[x29,	board_addr_offset]		// Adding x29 and board_addr_offset and storing result in x0
	bl	UncoveredBoard					// Branch and link UnocoveredBoard

	ldr	x0,	=output1				// Load x0 with address of output1
	bl	printf						// Branch and link printf

	// Asking player if he/she wants to see the leaderboard
	ldr	x0,	[x29, player_arr_offset]
	bl	DisplayLeaderboard				// Branch and link DisplayLeaderboard

main_loop:

	// Printing covered board
	ldr	x0,	[x29,	board_addr_offset]		// Loading x0 with board address
	ldr	x1,	[x29,	lives_offset]			// Loading x1 with lives value
	ldr	d0,	[x29,	score_offset]			// Loading d0 with score value
	ldr	x2,	[x29,	bombs_offset]			// Loadin x2 with bombs value
	bl	DisplayGame					// Branch and link DisplayGame

	// Asking for x-coordinate of bomb
	ldr	x0,	=output12				// Loadig x0 with address of output12
	bl	printf						// Branch and link

	mov	offset_r,	bombPos_offset			// Moving bombPos_offset into offset_r
	add	offset_r,	offset_r,	xcoord_offset	// Adding offset_r and xcoord_offset
	ldr	x0,	=input0					// Loading x0 with address of input0
	add	x1,	x29,	offset_r			// Addinng x29 and offset_r and storing result in x1
	bl	scanf						// Branch and link scanf

	// Asking for y-coordinate of bomb
	ldr	x0,	=output13				// Load x0 with address of output13
	bl	printf						// Branch and link printf

	mov	offset_r,	bombPos_offset			// Moving bombPos_offset into offset_r
	add	offset_r,	offset_r,	ycoord_offset	// Adding offset_r and ycoord_offset 
	ldr	x0,	=input0					// Loading x0 with address of input0
	add	x1,	x29,	offset_r			// Adding x29 and offset_r and storing result in x1
	bl	scanf						// Branch and link scanf

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
	
	// Printing covered board (one last time)
	ldr	x0,	[x29,	board_addr_offset]		// Adding x29 and board_addr_offset and storing result in x0
	ldr	x1,	[x29,	lives_offset]			// Load x1 with value of lives
	ldr	d0,	[x29,	score_offset]			// Load d0 with value of score
	ldr	x2,	[x29,	bombs_offset]			// load x2 with value of bombs
	bl	DisplayGame					// Branch and link DisplayGame

	ldr	x0,	[x29,	lives_offset]			// Load x9 with value of lives
	ldr	d0,	[x29,	score_offset]			// Load d0 with value of score 
	ldr	x1,	[x29,	bombs_offset]			// Load x1 with value of bombs
	bl	ExitGame					// Branch and link ExitGame

	// Asking play if he/she wants to see the leaderboard
	//bl	DisplayLeaderboard				// Branch and link DisplayLeaderboard

	// Deallocating memory for player struct
	ldr	x9,	=no_players
	ldrsw	x9,	[x9]
	add	x9,	x9,	#1
	mov	x10,	player_struct_size
	mul	x9,	x9,	x10
	sub	x9,	xzr,	x9
	and	x9,	x9,	#-16
	sub	sp,	sp,	x9
	
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
exit_tile_f:	.byte 	0					// Defining a byte variable initialized to zero (false)
no_players:	.int	0					// Defininng a int variable initialized to zero
	
	
