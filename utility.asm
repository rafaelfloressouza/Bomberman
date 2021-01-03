	// Final Project Part 2 ~ Bombermann 
	// Rafael Flores Souza, UCID: 30128094

	/*
	Subroutine compares two floats
	Arguments: x0 -> addres of first num, x1 -> address of second num
	Return:	1 (first num > second num) or 0 (first num <= second num) in w0
	*/

	define( a_addr_r,	x9 )				// Defining x9 as a_addr_r
	define( b_addr_r,	x10 )				// Defining x10 as b_addr_r
	define( a_val_r,	d16 )				// Defining d16 as a_val_r
	define( b_val_r,	d17 )				// Defining d17 as b_val_r

	.global	Comparator					// Making Compartor visible to external compilation units
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

	/*
	Subroutine is in charge of swapping the values of two player structs
	Arguments: x0 -> Address of first struct, x1 -> Address of second struct
	Return:	None
	*/
	
	define( base_a_r,	x9 )				// Defining x9 as base_a_r
	define( base_b_r,	x10 )				// Defining x10 as base_b_r
	define( tmp_val_r,	x11 )				// Defining x11 as tmp_val_r
	define( tmp_val2_r,	x12 )				// Defining x12 as tmp_val2_r
	define( tmp_float_r,	d16 )				// Defining d16 as tmp_float_r
	define( tmp_float2_r,	d17 )				// Defininng d17 as tmp_float2_r

	.global SwapPlayers					// Making SwapPlayers visible to external compilation units
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
