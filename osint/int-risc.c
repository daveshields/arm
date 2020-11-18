/*
Copyright 1987-2012 Robert B. K. Dewar and Mark Emmer.
Copyright 2012-2015 David Shields
*/

/*
 * int.c - integer support for SPITBOL.
 *
 * Needed for RISC systems that do not provide integer divide/remainder
 * divide in hardware.
 */

#include "port.h"

// checks for division by zero are made by caller

void cvd__() {
	
	
	reg_wa = reg_ia % 10;
	reg_ia /= 10;
	reg_wa  = -reg_wa + 48; // convert remainder to character code for digit
}


/*
 * dvi - divide into accumulator
 */
int dvi__(int arg)
{
	if (arg == 0)	return EXIT_1;
	reg_ia /= arg;
	return EXIT_0;
}

/*
 * rmi - remainder after division into accumulator
 */
int rmi__(int arg)
{
	if (arg == 0)	return EXIT_1;
	reg_ia %= arg;
	return EXIT_0;
}

/*
 *  mli - multiplication
 */
int mli__(int arg)
{
	int save_arg;

	save_ia = ia;
	reg_ia *= arg;
	if (reg_ia == 0) return EXIT_0;
	/* check for overflow by seeing that result divided by original value of ia is arg. */
	/* original value of ia cannot be zero since result was not zero. */
	if(reg_ia / save_ia != arg) return EXIT_1;
	return EXIT_0;
}


