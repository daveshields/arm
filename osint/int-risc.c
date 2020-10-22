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


void cvd__() {
	
	reg_wa = reg_ia % 10;
	reg_ia /= 10;
	reg_wa  = -reg_wa + 48; // convert remainder to character code for digit
}

/*
 * dvi - divide into accumulator
 */
int dvi__()
{
	if (reg_w0 == 0) return EXIT_1;
	reg_ia / reg_w0;
	return NORMAL_EXIT;
}

/*
 * rmi - remainder after division into accumulator
 */
int rmi__()
{
	if (reg_w0 == 0) return EXIT_1;
	reg_ia %= reg_w0;
	return NORMAL_EXIT;
}

#endif					// SUN4
