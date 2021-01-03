	// Final Project Part 2 ~ Bomberman
	// Rafael Flores Souza, UCID: 30128094
	
	/*
	Subroutine is in charge of providing a seed for the c functionn rand()
	Arguments: None
	Return:	 None
	*/

	seconds_size = 8					// Size of seconds local variable

	alloc = -(16 + seconds_size) & -16			// Number of bytes to allocate for stack frame of subroutine (quadword aligned)
	dealloc = -alloc					// Number of bytes to deallocate

	seconds_offset = 16					// Offset to get seconds local variable
	
	.global	sRand						// Making sRand visible to external compilation units
sRand:	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" number of bytes on the stack for the subroutine
	mov	x29,	sp					// Making x29 point to sp where sp is pointing

	add	x0,	x29,	seconds_offset      		// Loading address of seconds local variable into x0
	bl	time		         			// Calling function time
	add	x0,	x29,	seconds_offset			// Loading address of seconds local variable into x0
	bl	srand	         				// Calling srand function
	
	ldp	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallocating 16 bytes from the stack
	ret							// Returning to the calling code

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

	.global	IntRand						// Making function visible to other compilation units
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
	
	ldp	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallocating "dealloc" bytes
	ret							// Returning to calling code

	/*
	Subroutine is in charge of generating a float random number
	between 0.0 and 15.0 inclusive.
	Accepts an argument to determine if the number is negative or positive (w0)
	Returns the number in d0
	*/

	is_neg_size = 1						// Size of is_neg local var

	alloc = -(16 + is_neg_size) & -16			// Number of bytes to allocate for the stack frame of the subroutine (quadword aligned)
	dealloc = -alloc					// Number of bytes to deallocate

	is_neg_offset = 16					// Offset to get is_neg local var

	.global	FloatRand					// Making FloatRand visible to external compilation units
FloatRand:
	stp	x29,	x30,	[sp, alloc]!			// Allocating "alloc" number of bytes for the stack frame
	mov	x29,	sp					// Makig x29 point to where sp is pointing

	strb	w0,	[x29,	is_neg_offset]			// Storing w0 into the stack

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
	ldrsb	w9,	[x29,	is_neg_offset]			// Loading value of the is_neg (passed into the function) into w9
if_float_rannd2:
	cmp	w9,	#0					// Comparing w9 and #0
	b.eq	e_if_float_rand2				// If w9 == 0, then branch e_if_float_rand2
	fneg	d17,	d17					// Else negate d17 (make it negative)
e_if_float_rand2:	

	fmov	d0,	d17					// Moving d17 into d0 (returnig the value)
	
	ldp	x29,	x30,	[sp],	dealloc			// Restoring x29, x30 and deallocating memory
	ret							// Returning to calling code

