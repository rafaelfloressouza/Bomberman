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
output19:	.string "Test Number: %f\n"
output20:	.string  "Your name is: %s\n"
error0:		.string "Not enough arguments provided!\n"
error1:		.string "Height and Width have to be >=10\n"
input0:		.string "%d"
input1:		.string "%s"
	
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
	and	x9,	x0,	0xF				// Making the result by 15
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

	alloc = -(reg_size + reg_size + reg_size + reg_size + reg_size + 16) & -16
	dealloc = -alloc
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
	
	double_range_bytes = 4
	neg_floats_size = 4

	alloc = -(double_range_bytes + neg_floats_size + coord_struct_size + coord_struct_size + reg_size + reg_size + reg_size + reg_size + coord_struct_size  + 16) & -16
	dealloc = -alloc

	exit_tile_offset = 48			// Struct to store x-coord and y-coordinates of exit cell
	double_range_size_offset = 56		// Number of double-range rewards to generate
	neg_floats_offset = 60			// Number of negative numbers to generate
	rng_reward_offset = 64			// Struct to store x-coord and y-coordinates of exit cell
	n_float_offset = 72			// Struct to store x-cood and y-coordinates of negative cells
	
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

	lives_size = 4
	score_size = 8
	bombs_size = 4
	
	alloc = -(lives_size + score_size + bombs_size + reg_size + reg_size + reg_size + reg_size + 16) & -16
	dealloc = -alloc

	lives_offset = 48
	score_offset = 52
	bombs_offset = 60
	
DisplayGame:
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" amount of bytes
	mov	x29,	sp					// Moving sp into x29

	// Storing calle-saved registers
	str	x19,	[x29,	r19_offset]			// Storing value of x19 in stack
	str	x20,	[x29,	r20_offset]			// Storing value of x20 in stack
	str	x21,	[x29,	r21_offset]			// Storing value of x21 in stack
	str	x22,	[x29,	r22_offset]			// Storing value of x22 in stack

	mov	base_r,	x0					// Move x0 into base_r (base of board)

	str	w1,	[x29, lives_offset]
	str	d0,	[x29, score_offset]
	str	w2,	[x29, bombs_offset]

	mov	i_r ,	#0					// Move 0 into i_r
	mov	j_r,	#0					// Move 0 into j_r

	b	disp_test
disp_loop:

	mov	j_r,	#0
disp_loop2:

	ldr	x14,	=width
	ldrsw	x14,	[x14]
	mul	offset_r,	i_r,	x14
	add	offset_r,	offset_r,	j_r
	mov	x14,	cell_struct_size
	mul	offset_r,	offset_r,	x14

	ldrsb	w9,	[base_r, offset_r]

	cmp	w9,	wzr
	b.ne	disp_discovered
disp_undiscovered:

	ldr	x0,	=output2
	bl	printf
	b	end_disp

disp_discovered:

	add	offset_r,	offset_r,	value_offset
	ldr	d16,	[base_r, offset_r]

	// Checking the type of cell
p_exit_cell:
	mov	x9,	100
	scvtf	d17,	x9
	fcmp	d16,	d17
	b.ne	p_d_range_cell

	ldr	x0,	=output3
	bl	printf
	b	end_disp
		
p_d_range_cell:
	mov	x9,	75
	scvtf	d17,	x9
	fcmp	d16,	d17
	b.ne	p_normal_cell

	ldr	x0,	=output4
	bl	printf
	b	end_disp

p_normal_cell:

	mov	x9,	0
	scvtf	d17,	x9
	fcmp	d16,	d17
	b.lt	negative
positive:

	ldr	x0,	=output7
	bl	printf
	b 	end_disp
	
negative:

	ldr	x0,	=output8
	bl	printf

end_disp:
	
	add	j_r,	j_r,	#1
dis_test2:
	ldr	x9,	=width
	ldrsw	x9,	[x9]
	cmp	j_r,	x9
	b.lt	disp_loop2

	// Printing a new line
	ldr	x0,	=output1
	bl	printf
	
	add	i_r,	i_r,	#1
disp_test:
	ldr	x9,	=height
	ldrsw	x9,	[x9]
	cmp	i_r,	x9
	b.lt	disp_loop

	// Printing summary of score, lives, and bombs
	ldr	x0,	=output18
	ldr	x1,	[x29, lives_offset]
	ldr	d0,	[x29, score_offset]
	ldr	x2,	[x29, bombs_offset]
	bl	printf

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

	dbl_rng_count_size = 4
	par_score_addr = 8
	org_act_y_size = 4
	
	alloc = -((6 * reg_size) + 16 + coord_struct_size + dbl_rng_count_size + par_score_addr + org_act_y_size) & -16
	dealloc = -alloc

	actual_coord_offset = 64
	dbl_rng_count_offset = 72
	par_score_addr_offset = 76
	org_act_y_offset = 84
CalculateScoreHelper:
	stp	x29,	x30,	[sp, alloc]!
	mov	x29,	sp

	// Storing calle-saved registers
	str	x19,	[x29,	r19_offset]			// Store value of x19 in the stack
	str	x20,	[x29,	r20_offset]			// Store value of x20 in the stack
	str	x21,	[x29,	r21_offset]			// Store value of x21 in the stack
	str	x22,	[x29,	r22_offset]			// Store value of x22 in the stack
	str	x23,	[x29,	r23_offset]			// Store value of x23 in the stack
	str	x24,	[x29,	r24_offset]			// Store value of x24 in the stack

	// Storing the board's address in base_r
	mov	base_r,	x0

	// Making dbl_rng_count = db_reward_count
	ldr	x9,	=db_reward_count
	ldrsw	x10,	[x9]
	str	w10,	[x29, dbl_rng_count_offset]
	str	wzr,	[x9]

	// Finding actual bomb position
	ldrsw	x9,	[x1, xcoord_offset]
	ldrsw	x10,	[x1, ycoord_offset]
	ldrsw	x11,	[x29, dbl_rng_count_offset]

	mov	x13,	#1
	lsl	tmp_r,	x13,	x11

	sub	x9,	x9,	tmp_r
	sub	x10,	x10,	tmp_r

	str	w9,	[x29, actual_coord_offset + xcoord_offset]
	str	w10,	[x29, actual_coord_offset + ycoord_offset]
	str	w10,	[x29, org_act_y_offset]
	
	// Storing partial score address
	str	x2,	[x29,	par_score_addr_offset]
	
	// Computing partial score and discovering tiles
	mov	i_r,	#0
	mov	j_r,	#0
	b	csh_test
csh_loop:
	
	// Resetting the value of actual-y coordinate for the next iteration
	ldrsw	x9,	[x29, org_act_y_offset]
	str	w9,	[x29, actual_coord_offset + ycoord_offset]
	mov	j_r,	#0
	b	csh_test2
csh_loop2:

	// Making sure tile is in the board
	ldrsw	x9,	[x29,	actual_coord_offset + xcoord_offset]
	ldrsw	x10,	[x29,	actual_coord_offset + ycoord_offset]
	ldr	x11,	=height
	ldrsw	x11,	[x11]
	ldr	x12,	=width
	ldrsw	x12,	[x12]

	cmp	x9,	#0
	b.lt	e_in_board
	cmp	x9,	x11
	b.ge	e_in_board
	cmp	x10,	#0
	b.lt	e_in_board
	cmp	x10,	x12
	b.ge	e_in_board
in_board:	

	// Calculating the offset
	ldr	x9,	=width							// Loading x9 with address of width
	ldrsw	x9,	[x9]							// Loading x9 with value of width
	ldrsw	x10,	[x29, actual_coord_offset + xcoord_offset]		// Loading x10 with value of actual x-coordinate
	ldrsw	x11,	[x29, actual_coord_offset + ycoord_offset]		// Loading x11 with value of actual y-coordinate

	mul	offset_r,	x10,	x9					// Multiplying x10 and x9
	add	offset_r,	offset_r,	x11				// Adding offset_r and x11
	mov	x12,	cell_struct_size					// Moving cell_struct_size into x12
	mul	offset_r,	offset_r,	x12				// Multiplying offset_r with x12
	add	offset2_r,	offset_r,	discovered_offset		// Adding offset_r and discovered_offset and storing result in offset2_r
	add	offset_r,	offset_r,	value_offset			// Adding offset_r and value_offset

	ldr	d16,	[base_r, offset_r]
	mov	x9,	75
	scvtf	d17,	x9

	//If double range reward
	fcmp	d16,	d17
	b.eq	db_rng

	mov	x9,	100
	scvtf	d17,	x9
	
	// If exit tile
	fcmp	d16,	d17
	b.eq	ext

	// Else normal tile
	b nrm

db_rng:
	ldrsb	w9,	[base_r, offset2_r]
	cmp	w9,	#1
	b.eq	end_comparison

	ldr	x10,	=db_reward_count
	ldrsw	x11,	[x10]
	add	x11,	x11,	#1
	str	w11,	[x10]

	b	end_comparison
ext:
	ldr	x10,	=exit_tile_f
	mov	w11,	#1
	strb	w11,	[x10]

	b	end_comparison
nrm:	
	ldrsb	w9,	[base_r, offset2_r]
	cmp	w9,	#1
	b.eq	end_comparison

	ldr	x10,	[x29, par_score_addr_offset]
	ldr	d16,	[x10]
	ldr	d17,	[base_r, offset_r]
	fadd	d16,	d16,	d17
	str	d16,	[x10]

end_comparison:

	// Making current cell visible
	mov	w9,	#1
	strb	w9,	[base_r, offset2_r]

e_in_board:	

	// Incrementing actual y-pos by one
	ldrsw	x9,	[x29, actual_coord_offset + ycoord_offset]
	add	x9,	x9,	#1
	str	w9,	[x29, actual_coord_offset + ycoord_offset]

	add	j_r,	j_r,	#1
csh_test2:	
	lsl	x9,	tmp_r,	#1
	cmp	j_r,	x9
	b.le	csh_loop2

	// Incrementing actual x-pos by one
	ldrsw	x10,	[x29, actual_coord_offset + xcoord_offset]
	add	x10,	x10,	#1
	str	w10,	[x29, actual_coord_offset + xcoord_offset]

	add	i_r,	i_r,	#1
csh_test:	
	lsl	x9,	tmp_r,	#1
	cmp	i_r,	x9
	b.le	csh_loop

	// Printing message if double-range rewards were found
	ldr	x9,	=db_reward_count
	ldrsw	x9,	[x9]
	cmp	x9,	#0
	b.le	csh_print_end
csh_print:
	ldr	x0,	=output15
	mov	x1,	x9
	bl	printf
csh_print_end:	
	
	// Restoring calle-saved registers
	ldr	x19,	[x29,	r19_offset]			// Load value of x19 from stack
	ldr	x20,	[x29,	r20_offset]			// Load value of x20 from stack
	ldr	x21,	[x29,	r21_offset]			// Load value of x21 from stack
	ldr	x22,	[x29,	r22_offset]			// Load value of x22 from stack
	ldr	x23,	[x29,	r23_offset]			// Load value of x23 from stack
	ldr	x24,	[x29,	r24_offset]			// Load value of x24 from stack

	ldp	x29,	x30,	[sp],	dealloc
	ret
		
	/*--------------------------------------------------------------*/

	/*
	Subroutine calculates the score after a bomb is placed and "explodes" (it reveals cells as well)
	Arguments: x0: address of board, d0: address of score, x1: lives address,
	x2: bombs address, and x3: bombsPos address
	Return: Nothing	
	*/

	addr_size = 8
	part_score_size = 8

	alloc = -((addr_size * 5) + 16 + part_score_size) & -16
	dealloc = -alloc

	board_addr_offset = 16					// Offset of board address
	score_addr_offset = 24					// Offset of score address 
	lives_addr_offset = 32					// Offset of lives address
	bombs_addr_offset = 40					// Offset of bombs address
	bomPos_addr_offset= 48					// Offset of bomPos struct address (Coord struct)
	part_score_offset = 56
	
CalculateScore:
	stp	x29,	x30,	[sp, alloc]!
	mov	x29,	sp

	// Storing all arguments in the stack
	str	x0,	[x29, board_addr_offset]
	str	x1,	[x29, score_addr_offset]
	str	x2,	[x29, lives_addr_offset]
	str	x3,	[x29, bombs_addr_offset]
	str	x4,	[x29, bomPos_addr_offset]

	// Decrementing the number of bombs by one
	ldr	x10,	[x29, bombs_addr_offset]
	ldr	w9,	[x10]
	sub	w9,	w9,	#1
	str	w9,	[x10]

	// Initializing partial score variable
	mov	x10,	#0
	scvtf	d16,	x10
	str	d16,	[x29, part_score_offset]
	
	// Calling CalculateScoreHelper
	ldr	x0,	[x29,	board_addr_offset]
	ldr	x1,	[x29,	bomPos_addr_offset]
	add	x2,	x29,	part_score_offset
	bl	CalculateScoreHelper


	// Printing results of bomb explosion
	ldr	d16,	[x29, part_score_offset]
	ldr	x10,	[x29, score_addr_offset]
	ldr	d17,	[x10]
	mov	x12,	#1
	mov	x13,	#1000
	scvtf	d18,	x12
	scvtf	d19,	x13
	fdiv	d18,	d18,	d19
	fadd	d16,	d17,	d16
	fcmp	d16,	d18
	b.gt	cs_e1
cs_if:
	// Making score equal to zero
	mov	x9,	#0
	scvtf	d16,	x9
	str	d16,	[x10]

	// Decrementig lives by one
	ldr	x14,	[x29, lives_addr_offset]
	ldr	w15,	[x14]
	sub	w15,	w15,	#1
	str	w15,	[x14]

	// Informing player about losing a life
	ldr	x0,	=output16
	bl	printf
	
	b	cs_e_if
cs_e1:	

	ldr	d16,	[x29, part_score_offset]
	ldr	x9,	[x29, score_addr_offset]
	ldr	d17,	[x9]
	
	// Printing partial score
	ldr	x0,	=output17
	fmov	d0,	d16

	fadd	d17,	d17,	d16
	str	d17,	[x9]
	
cs_e_if:	

	ldp	x29,	x30,	[sp],	dealloc	
	ret

	/*--------------------------------------------------------------*/

	/*
	Subroutine prints correct "game over" message and logs results in a file
	Argumets -> x0: lives, d0: score, x1: bombs
	Return -> Nothing
	*/

	lives_size = 4
	score_size= 8
	bombs_size = 4

	alloc = -(16 + lives_size + score_size + bombs_size) & -16
	dealloc = -alloc

	lives_offset = 16
	score_offset = 20
	bombs_offset = 28

ExitGame:
	stp	x29,	x30,	[sp, alloc]!
	mov	x29,	sp

	str	x0,	[x29, lives_offset]
	str	d0,	[x29, score_offset]
	str	x1,	[x29, bombs_offset]

	ldr	x9,	=exit_tile_f
	ldrsb	w9,	[x9]
	ldr	w10,	[x29, lives_offset]

	
exit_if:

exit_else1:

exit_else2:	
	

end_exit_if:	
	
	
	


	

	ldp	x29,	x30,	[sp],	dealloc
	ret

	/*--------------------------------------------------------------*/
DisplayLeaderboard:
	stp	x29,	x30,	[sp, -16]!
	mov	x29,	sp

	ldp	x29, 	x30,	[sp],	16
	ret
	
	/*--------------------------------------------------------------*/
	
	name_size = 8						// Size (in bytes) of name
	lives_size = 4						// Size (in bytes) of lives
	score_size = 8						// Size (in bytes) of score
	bombs_size = 4						// Size (in bytes) of bombs
	board_addr_size = 8					// Size (in bytes) of the board's address
	
	alloc = -(coord_struct_size + 16 + name_size + lives_size + score_size + bombs_size + board_addr_size) & -16 // Total amount of bytes to allocate for stack frame of main (quadword aligned)
	dealloc = -alloc						      			 			 		     // Total amount of bytes to deallocate for the stack frame of main (quadword alignned) 	

	name_offset = 16					// Player Name offset
	lives_offset = 24					// Lives offset
	score_offset = 28					// Score offset
	bombs_offset = 36					// Bombs offset
	board_addr_offset = 40					// Board offset
	bombPos_offset = 48					// Offset of bombPos struct 
	
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
	mov	x14,	#0
	scvtf	d16,	x14
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
	str	x14,	[x29,	board_addr_offset]		// Storinng x14 in the stack at x29 + board_addr_offset

	// Initializing game board
	ldr	x14,	[x29,	board_addr_offset]
	mov	x0,	x14					// Adding x29 and board_addr_offset and storing result in x0
	bl	InitializeGame					// Branch and link InitializeGame

	
	// Printing uncovered board (for grading)
	ldr	x0,	[x29,	board_addr_offset]		// Adding x29 and board_addr_offset and storing result in x0
	bl	UncoveredBoard					// Branch and link UnocoveredBoard

	ldr	x0,	=output1				// Load x0 with address of output1
	bl	printf						// Branch and link printf

	// Printing covered board
	ldr	x0,	[x29,	board_addr_offset]		// Adding x29 and board_addr_offset and storing result in x0
	ldr	x1,	[x29,	lives_offset]
	ldr	d0,	[x29,	score_offset]
	ldr	x2,	[x29,	bombs_offset]
	bl	DisplayGame					// Branch and link DisplayGame
	
	// Asking player if he/she wants to see the leaderboard
	bl	DisplayLeaderboard				// Branch and link DisplayLeaderboard	
main_loop:

	// Asking for x-coordinate of bomb
	ldr	x0,	=output12
	bl	printf

	mov	offset_r,	bombPos_offset
	add	offset_r,	offset_r,	xcoord_offset		
	ldr	x0,	=input0
	add	x1,	x29,	offset_r			
	bl	scanf

	// Asking for y-coordinate of bomb
	ldr	x0,	=output13
	bl	printf

	mov	offset_r,	bombPos_offset
	add	offset_r,	offset_r,	ycoord_offset		
	ldr	x0,	=input0
	add	x1,	x29,	offset_r			
	bl	scanf

	// Calling calculate score
	ldr	x0,	[x29,	board_addr_offset]
	add	x1,	x29,	score_offset
	add	x2,	x29,	lives_offset
	add	x3,	x29,	bombs_offset
	add	x4,	x29,	bombPos_offset
	bl	CalculateScore

	// Printing covered board
	ldr	x0,	[x29,	board_addr_offset]		// Adding x29 and board_addr_offset and storing result in x0
	ldr	x1,	[x29,	lives_offset]
	ldr	d0,	[x29,	score_offset]
	ldr	x2,	[x29,	bombs_offset]
	bl	DisplayGame					// Branch and link DisplayGame
		
main_test:
	ldrsw	x9,	[x29,	lives_offset]
	cmp 	x9,	#0
	b.le	end_main_loop
	ldr	x9,	=exit_tile_f
	ldrsb	w10,	[x9]
	cmp 	w10,	#1
	b.eq	end_main_loop
	ldrsw	x9,	[x29,	bombs_offset]
	cmp	x9,	#0
	b.lt	end_main_loop
	b	main_loop
end_main_loop:	

	// Asking play if he/she wants to see the leaderboard
	bl	DisplayLeaderboard				// Branch and link DisplayLeaderboard
	
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
	
	
