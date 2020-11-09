	// Final Project Part 2 - Bomberman
	// Rafael Flores Souza, UCID: 30128094
output0:	.string "%.2f\t"
output1:	.string "\n"
output2:	.string "X "
output3:	.string	"* "
output4:	.string "$ "
output5:	.string "*\t"
output6:	.string "$\t"
output7:	.string "Test Number: %d\n"
output8:	.string  "Your name is: %s\n"
error0:		.string "Not enough arguments provided!\n"
error1:		.string "Height and Width have to be >=10\n"
input0:		.string "%d"
input1:		.string "%s"
	
	.balign	4                				// Adding 4 bytes of padding (to keep everything consistent)
	.global main             				// Making main global to the linker (OS)

	define(	base_r,		x19 )
	define( i_r,		x20 ) 
	define( j_r,		x21 )
	define( offset_r,	x22 )

	// Register offsets (for restoring them)
	reg_size = 8
	r19_offset = 16
	r20_offset = 24
	r21_offset = 32
	r22_offset = 40
	
	// CELL STRUCT {bool discovered, float value}
	cell_struct_size = 9
	discovered_offset = 0
	value_offset = 1

	// COORDINATE STRUCT {int xCoord, int yCoord}
	coord_struct_size = 8
	xcoord_offset = 0
	ycoord_offset = 4
	

	// Subroutine is in charge of providing a seed random function
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

	alloc = -(reg_size + reg_size + reg_size + reg_size + 16) & -16
	dealloc = -alloc
UncoveredBoard:	
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" amount of bytes
	mov	x29,	sp					// Making x29 point to sp
	
	// Storing callee registers
	str	x19,	[x29,	r19_offset]			// Storing register x19 into the stack
	str	x20,	[x29,	r20_offset]			// Storing register x20 into the stack
	str	x21,	[x29,	r21_offset]			// Storing register x21 into the stack
	str	x22,	[x29,	r22_offset]			// Storing register x22 into the stack

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

	// Restoring calle registers
	ldr	x19,	[x29,	r19_offset]			// Loadig value of x19 from stack
	ldr	x20,	[x29,	r20_offset]			// Loading value of x20 from stack
	ldr	x21,	[x29,	r21_offset]			// Loading value of x21 from stack
	ldr	x22,	[x29,	r22_offset]			// Loading value of x22 from stack

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

	alloc = -(reg_size + reg_size + reg_size + reg_size + coord_struct_size + double_range_bytes + coord_struct_size + neg_floats_size + coord_struct_size + 16) & -16
	dealloc = -alloc

	exit_tile_offset = 16
	double_range_size_offset = 24
	neg_floats_offset = 28
	rng_reward_offset = 32
	n_float_offset = 40
	
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

	mov	w0,	#0					// Moving 0 into w0
	ldr	x9,	=height					// Loading x9 with address of height
	ldr	w10,	[x9]					// Loading w10 with value of height
	sub	w10,	w10,	#1				// Subtracting w10 by one
	mov	w1,	w10					// Moving w10 into w1
	bl	IntRand						// Branch and link IntRand
	str	w0,	[x29, exit_tile_offset + xcoord_offset] // Store w0 into the stack (x-coord)

	mov	w0,	#0					// Move 0 into w0
	ldr	x9,	=width					// Load x9 with address of width
	ldr	w10,	[x9]					// Load value of width into w10
	sub	w10,	w10,	#1				// Subtracting one from w10
	mov	w1,	w10					// Move w10 into w1
	bl	IntRand						// Branch and link IntRand
	str	w0,	[x29, exit_tile_offset + ycoord_offset] // Store w0 into the stack (y-coord)
	
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

	// Populating the board with float-point random numbers and including the exit tile
	mov	i_r,	#0					// Move 0 into j_r
	mov	j_r,	#0					// Move 0 into i_r

	b init_test						// Branch init_test
init_loop:

	mov	j_r,	#0					// Move 0 into j_r
	b init_test2						// Branch init_test2
init_loop2:

	ldr	x14,	=width					// Load x14 with address of width
	ldrsw	x14,	[x14]					// Load x14 with value of width
	mul	x14,	i_r,	x14				// Multiply i_r by x14 and store it in x14
	add	x14,	x14,	j_r				// Add x14 and j_r and store it in x14
	mov	x15,	cell_struct_size			// Move cell_struct_size into x15
	mul	x14,	x14,	x15				// Multiply x14 and x15 and store the result in x14

	add	offset_r,	x14,	discovered_offset	// Add x14 and discovered_offset and store it in offset_r
	strb	wzr,	[base_r, offset_r]			// Store wzr into the address base_r + offest_r 

	add	offset_r,	x14,	value_offset		// Add x14 and value_offset and store it in offset_r

i_if1:	ldrsw	x9,	[x29, exit_tile_offset + xcoord_offset] // Load x9 with value from the stack at x29 + exit_tile_offset + xcoord_offset
	cmp	i_r,	x9					// Comparig i_r and x9
	b.ne	i_e1						// If i_r != x9, then branch to i_e1
	ldrsw	x9,	[x29, exit_tile_offset + ycoord_offset] // Load x9 with value from stack at x29 + exit_tile_offset + ycoord_offset
	cmp	j_r,	x9					// Comparing j_r and x9
	b.ne	i_e1						// If j_r != x9, then branch i_e1

	// Exit Tile coordinate

	mov	x9,	#100					// Move 100 into x9
	scvtf	d16,	x9					// Convert x9 into float and store the result in d16
	str	d16,	[base_r, offset_r]			// Store d16 onto the stack
	
	b	i_e_if1						// Branch to i_e_if1
i_e1:
	// Normal Tile Coordinate
	
	mov	w0,	#0					// Move 0 into w0
	bl	FloatRand					// Branch and link FloatRand
	str	d0,	[base_r, offset_r]			// Store d0 in the stack at base_r + offset_r

i_e_if1:	
	
	add	j_r,	j_r,	#1				// Increment j_r by one
init_test2:
	ldr	x14,	=width					// Load address of width into x14
	ldrsw	x14,	[x14]					// Load value of width into x14
	cmp	j_r,	x14					// Compare j_r and x14
	b.lt	init_loop2					// If j_r < x14, then branch init_loop2

	add	i_r,	i_r,	#1				// Increment i_r by one
init_test:
	ldr	x14,	=height					// Load x14 with address of height
	ldrsw	x14,	[x14]					// Load x14 with value of height
	cmp	i_r,	x14					// Compare i_r and x14
	b.lt	init_loop					// If i_r < x14, then branch init_loop

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

	// Populating board with negative float-numbers
	mov	i_r,	#0
init_loop4:

	// Getting random x-pos
	ldr	x9,	=height
	ldrsw	x9,	[x9]
	sub	x9,	x9,	#1
	mov	w0,	#0
	mov	w1,	w9
	bl	IntRand
	str	w0,	[x29,	n_float_offset + xcoord_offset]

	// Getting random y-pos
	ldr	x9,	=width
	ldrsw	x9,	[x9]
	sub	x9,	x9,	#1
	mov	w0,	#0
	mov	w1,	w9
	bl	IntRand
	str	w0,	[x29,	n_float_offset + ycoord_offset]

	// Computing offset
	ldrsw	x9,	[x29,	n_float_offset + xcoord_offset]
	ldrsw	x10,	[x29,	n_float_offset + ycoord_offset]
	ldr	x11,	=width
	ldrsw	x11,	[x11]

	mul	offset_r,	x9,	x11
	add	offset_r,	offset_r,	x10
	mov	x10,	cell_struct_size
	mul	offset_r,	offset_r,	x10
	add	offset_r,	offset_r,	value_offset	

	ldr	d16,	[base_r, offset_r]

	mov	x9,	0
	scvtf	d17,	x9
	fcmp	d16,	d17
	b.lt	init_loop4

	mov	x9,	100
	scvtf	d17,	x9

	fcmp	d16,	d17
	b.eq	init_loop4

	mov	x9,	75
	scvtf	d17,	x9

	fcmp	d16,	d17
	b.eq	init_loop4

	fneg	d16,	d16
	str	d16,	[base_r, offset_r]

	add	i_r,	i_r,	#1
init_test4:
	ldrsw	x9,	[x29,	neg_floats_offset]
	cmp	i_r,	x9
	b.lt	init_loop4
	

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
	It accepts the address of the board in x0
	Does not return anything
	Note: It displays the board as "hidden"	
	*/

	alloc = -(reg_size + reg_size + reg_size + reg_size + 16) & -16
	dealloc = -alloc
DisplayGame:
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" amount of bytes
	mov	x29,	sp					// Moving sp into x29

	// Storing calle-saved registers
	str	x19,	[x29,	r19_offset]			// Storing value of x19 in stack
	str	x20,	[x29,	r20_offset]			// Storing value of x20 in stack
	str	x21,	[x29,	r21_offset]			// Storing value of x21 in stack
	str	x22,	[x29,	r22_offset]			// Storing value of x22 in stack

	mov	base_r,	x0					// Move x0 into base_r (base of board)
	mov	i_r ,	#0					// Move 0 into i_r
	mov	j_r,	#0					// Move 0 into j_r

	b	disp_test					// Branch tp disp_test
disp_loop:

	mov	j_r,	#0					// Move 0 into j_r
	b	disp_test2					// Branch to disp_test2
disp_loop2:

	ldr	x14,	=width					// Load x14 with address of width
	ldr	x14,	[x14]					// Load x14 with value of width
	mul	offset_r,	i_r,	x14			// Multiply i_r and x14 and store the result in offset_r
	add	offset_r,	offset_r,	j_r		// Add offset_r and j_r 
	mov	x14,	cell_struct_size			// Move cell_struct_size into x14
	mul	offset_r,	offset_r,	x14		// Multiply offset_r by x14

	ldrsb	w14,	[base_r]				// Load w14 with value at base_r + offset_r							possible error HERE!
d_if1:	cmp	w14,	#1					// Compare w14 and 1
	b.eq	d_e_if1						// If w14 != 1, then brach to d_e_if1

	// Cell is Discovered
	ldr	x0,	=output2				// Load x0 with address of output2
	bl	printf						// Branch and link printf
	b	d_e_if1						// Branch to d_e_if1
d_e1:	// Cell is Undiscovered
	
	add	offset_r,	offset_r,	value_offset	// Add offset_r and value_offset

	ldr	d16,	[base_r, offset_r]			// Load d16 with value in stack at address base_r + offset_r

	// Checking if cell is a normal, exit, or double range 
	mov	x9,	#100					// Move 100 into x9
	scvtf	d17,	x9					// Converting x9 into a float
d2_if2: fcmp	d16,	d17					// Comparing d16 and d17					
	b.ne	d2_e1						// If d16 != d17, then branch to d2_e1

	// Print '*' because it is exit tile
	ldr	x0,	=output3				// Load x0 with address of output3
	b	d2_e_if2					// Branch to d2_e_if2
	
d2_e1:	mov	x9,	#75					// Move 75 into x9
	scvtf	d17,	x9					// Converting x9 into a float and storing it in d17
	fcmp	d16,	d17					// Comparing d16 and d17
	b.ne	d2_e2						// If d16 != d17, then branch to d2_e2

	// Printg '$' because it is double-range reward
	ldr	x0,	=output4				// Load x0 with address of output4
	b	d2_e_if2					// Branch to d2_e_if2
d2_e2:
	// Normal Tile
	ldr	x0,	=output1				// Load x0 with address of output1
d2_e_if2:	
	fmov	d0,	d16					// Move d16 into d0
	bl	printf						// Branch and likn printf
	
	ldr	x0,	=output0				// Load x0 with address of output0
	fmov	d0,	d16					// Move d16 into d0
	bl	printf						// Branch and link printf 
	
d_e_if1:	
	
	add	j_r,	j_r,	#1				// Increment j_r by one
disp_test2:
	ldr	x14,	=width					// Load x14 with address of width
	ldrsw	x14,	[x14]					// Load x14 with value of width
	cmp	j_r,	x14					// Compare x14 and j_r
	b.lt	disp_loop2					// If j_r < x14, then branch to disp_loop2

	ldr	x0,	=output1				// Load x0 with address of output1
	bl	printf						// Branch and link printf 
	
	add	i_r,	i_r,	#1				// Increment i_r by one
disp_test:	
	ldr	x14,	=height					// Load x14 with address of height
	ldrsw	x14,	[x14]					// Load x14 with value of height
	cmp	i_r,	x14					// Compare i_r and x14
	b.lt	disp_loop					// If i_r < x14, then branch disp_loop
	
	// Restoring calle-saved registers
	ldr	x19,	[x29,	r19_offset]			// Load value of x19 from stack
	ldr	x20,	[x29,	r20_offset]			// Load value of x20 from stack
	ldr	x21,	[x29,	r21_offset]			// Load value of x21 from stack
	ldr	x22,	[x29,	r22_offset]			// Load value of x22 from stack
	
	ldp 	x29,	x30,	[sp],	dealloc			// Restoring x29, x30, and deallocating memory
	ret							// Return to main
/*--------------------------------------------------------------*/	
	name_size = 8						// Size (in bytes) of name
	lives_size = 4						// Size (in bytes) of lives
	score_size = 4						// Size (in bytes) of score
	bombs_size = 4						// Size (in bytes) of bombs
	board_addr_size = 8					// Size (in bytes) of the board's address
	
	alloc = -(16 + name_size + lives_size + score_size + bombs_size + board_addr_size) & -16 // Total amount of bytes to allocate for stack frame of main (quadword aligned)
	dealloc = -alloc						      			 // Total amount of bytes to deallocate for the stack frame of main (quadword alignned) 	

	name_offset = 16					// Player Name offset
	lives_offset = 24					// Lives offset
	score_offset = 28					// Score offset
	bombs_offset = 32					// Bombs offset
	board_addr_offset = 36					// Board offset

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
	mov	w14,	w0					// Moving integer result w0 into w4

if_b:	cmp	w14,	#10					// Comparig x14 to #10
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
	str	wzr,	[x29,	score_offset]			// Initializing	score to 0
	
	// BOMBS
	mov	w14,	#3					// Moving 3 into w14
	str	w14,	[x29,	bombs_offset]			// Initializing bombs to 3

	// Seeding the rand() function
	bl	sRand						// Branch and link sRand
	
	// BOARD
	ldr	x9,	=height
	ldr	x10,	=width
	ldrsw	x14,	[x9]
	ldrsw	x15,	[x10]
	mul	x14,	x14,	x15
	mov	x11,	cell_struct_size
	mul	x14,	x14,	x11
	sub	x14,	xzr,	x14
	and	x14,	x14,	#-16
	add	sp,	sp,	x14

	// Storing base address of board
	mov	x14,	sp
	str	x14,	[x29,	board_addr_offset]

	
	// Initializing game board
	add	x0,	x29,	board_addr_offset	
	bl	InitializeGame

	add	x0,	x29,	board_addr_offset	
	bl	UncoveredBoard

	ldr	x0,	=output1
	bl	printf

	add	x0,	x29,	board_addr_offset
	bl	DisplayGame
	
	// Deallocating memory for the 2D board
	ldr	x9,	=height
	ldr	x10,	=width
	ldrsw	x14,	[x9]
	ldrsw	x15,	[x10]
	mul	x14,	x14,	x15
	mov	x11,	cell_struct_size
	mul	x14,	x14,	x11
	sub	x14,	xzr,	x14
	and	x14,	x14,	#-16
	sub	sp,	sp,	x14

	ldp	x29,	x30,	[sp],	dealloc  		// Deallocating 16 bytes memory previously allocated for subroutine main
	ret                     				// Returning to operating system

	.data                    				// Defining variables
height:		.int	0					// Height ~ int variable declared (initially zero)
width:		.int	0					// Width ~ in variable declared (initially zero)
seconds: 	.long	0                 			// Defining a long variable initialized to zero
	
	
