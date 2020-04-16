/*----------------------------------------------------------------
|	Autor: Pere Millán (DEIM, URV)
|	Data:  Març 2020					Versió: 1.0
|-----------------------------------------------------------------|
|	Nom fitxer: FCdivmod.h
|   Descripció: declaració de rutines de divisió entera
|			    i residu (mòdul) amb operands naturals de 32 bits.
| ----------------------------------------------------------------*/

#ifndef FCDIVMOD_H
#define FCDIVMOD_H

#include "FCtypes.h"	/* u32 ... */


	/* rutina completa de divisió: calcula quocient i residu (mòdul) */
extern u8 div_mod ( u32 num, u32 den, u32 *quo, u32 *mod );
		/*
			*quo = num / den	Quocient
			*mod = num % den 	Residu, mòdul
			Retorna possibles errors DIVMOD_ERROR_XXXX
		*/
			/* Possibles errors retornats per div_mod */
#define DIVMOD_ERROR_NOERROR    0	/* No s'ha detectat cap error, resultats Ok */
#define DIVMOD_ERROR_DIVBYZERO  1	/* S'ha intentat dividir entre 0 */
#define DIVMOD_ERROR_NOTALIGN4  2	/* quo o den no estan alineats a adreça múltiple de 4 */
#define DIVMOD_ERROR_SAMEADDR   3	/* quo i den apunten a la mateixa adreça */


	/* rutines per obtenir només quocient o residu (mòdul). Criden a div_mod */
extern u32 FCdiv ( u32 num, u32 den );	/* Retorna num / den o DIVMOD_RESULT_ERROR en cas d'error */
extern u32 FCmod ( u32 num, u32 den );	/* Retorna num % den o DIVMOD_RESULT_ERROR en cas d'error */

			/* Possible resultat erroni de FCdiv o FCmod */
#define DIVMOD_RESULT_ERROR 0xFF000000


#endif /* FCDIVMOD_H */

