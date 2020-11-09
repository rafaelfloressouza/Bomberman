	// Final Project Part 2 - Bomberman
	// Rafael Flores Souza, UCID: 30128094
output0:	.string "%.2f\t"
output1:	.string "\n"
output3:	.string "Test Number: %.2f\n"
output4:	.string  "Your name is: %s\n"
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
	
	// CELL STRUCT
	cell_struct_size = 9
	discovered_offset = 0
	value_offset = 1

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
	mov	w17,	w16					// Move w16 into w17
	lsl	w16,	w16,	#1				// Shift left w16 by 1
test_a:	ldr	w15,	[x29,	u_bound_offset]			// Load value of upper bound into w15
	cmp	w16,	w15					// Compare w16 and w15 
	b.le	loop_a						// If w16 <= w15, then branch loop_a

	sub	w16,	w16,	#1				// Subtracting w16 by 1
	sub	w17,	w17,	#1				// Subtracting w15 by 1
	
	and	w14,	w14,	w16				// Anding w14 by w16

	ldr	w15,	[x29,	u_bound_offset]			// Loading value of upper bound into w15
if_rand:
	cmp	w14,	w15					// Comparig w14 and w15
	b.le	e_if_rand					// If w14 <= w15, then branch e_if_rand
	and	w14,	w14,	w17				// Else, anding w14 with w17
e_if_rand:	
	
	mov	w0,	w14					// Moving number in correct range into w0 (for returning)
	
	ldp	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallocating "dealoc" bytes
	ret							// Returning to main

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

	/*
	Subroutine display the 2D game board (uncovered)
	It accepts the address of the board in x0
	Does not return anything
	*/

	alloc = -(reg_size + reg_size + reg_size + reg_size + 16) & -16
	dealloc = -alloc
UncoveredBoard:
	stp	x29,	x30,	[sp, alloc]!
	mov	x29,	sp
	
	// Storing callee registers
	str	x19,	[x29,	r19_offset]
	str	x20,	[x29,	r20_offset]
	str	x21,	[x29,	r21_offset]
	str	x22,	[x29,	r22_offset]

	mov	base_r,	x0
	mov	i_r,	#0
	mov	j_r,	#0

	b	uboard_test
uboard_loop:

	mov	j_r,	#0
	b	uboard_test2
uboard_loop2:

	ldr	x14,	=width
	ldrsw	x14,	[x14]
	mul	offset_r,	i_r,	x14
	add	offset_r,	offset_r,	j_r
	mov	x15,	cell_struct_size
	mul	offset_r,	offset_r,	x15
	add	offset_r,	offset_r,	value_offset

	ldr	x0,	=output0
	ldr	d0,	[base_r, offset_r]
	bl	printf
	
	add	j_r,	j_r,	 #1
uboard_test2:
	ldr	x14,	=width
	ldrsw	x14,	[x14]
	cmp	j_r,	x14
	b.lt	uboard_loop2

	ldr	x0,	=output1
	bl	printf

	add	i_r,	i_r,	#1
uboard_test:
	ldr	x14,	=height
	ldrsw	x14,	[x14]
	cmp	i_r,	x14
	b.lt	uboard_loop

	// Restoring calle registers
	ldr	x19,	[x29,	r19_offset]
	ldr	x20,	[x29,	r20_offset]
	ldr	x21,	[x29,	r21_offset]
	ldr	x22,	[x29,	r22_offset]

	ldp 	x29,	x30,	[sp],	dealloc
	ret

	/*
	Subroutine initializes the 2D game board 
	It accepts the addres of the board in x0
	Does not return anything
	*/

	alloc = -(reg_size + reg_size + reg_size + reg_size + 16) & -16
	dealloc = -alloc
InitializeGame:
	stp	x29,	x30,	[sp, alloc]!
	mov	x29,	sp

	// Storing callee registers
	str	x19,	[x29,	r19_offset]
	str	x20,	[x29,	r20_offset]
	str	x21,	[x29,	r21_offset]
	str	x22,	[x29,	r22_offset]

	mov 	base_r,	x0
	mov	i_r,	#0
	mov	j_r,	#0

	b init_test
init_loop:

	mov	j_r,	#0
	b init_test2
init_loop2:

	ldr	x14,	=width
	ldrsw	x14,	[x14]
	mul	x14,	i_r,	x14
	add	x14,	x14,	j_r
	mov	x15,	cell_struct_size
	mul	x14,	x14,	x15

	add	offset_r,	x14,	discovered_offset
	strb	wzr,	[base_r, offset_r]

	add	offset_r,	x14,	value_offset
	
	mov	w0,	#0
	bl	FloatRand
	str	d0,	[base_r, offset_r]

	add	j_r,	j_r,	#1
init_test2:
	ldr	x14,	=width
	ldrsw	x14,	[x14]
	cmp	j_r,	x14
	b.lt	init_loop2

	add	i_r,	i_r,	#1
init_test:
	ldr	x14,	=height
	ldrsw	x14,	[x14]
	cmp	i_r,	x14
	b.lt	init_loop

	// Restoring calle registers
	ldr	x19,	[x29,	r19_offset]
	ldr	x20,	[x29,	r20_offset]
	ldr	x21,	[x29,	r21_offset]
	ldr	x22,	[x29,	r22_offset]

	ldp 	x29,	x30,	[sp],	dealloc
	ret

	/*
	Subroutine displays the 2D game board
	It accepts the address of the board in x0
	Does not return anything
	Note: It displays the board as "hidden"	
	*/
DisplayGame:
	stp	x29,	x30,	[sp, -16]!
		

		

	
	

	ldp 	x29,	x30,	[sp],	16
	ret
	

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
	
	
