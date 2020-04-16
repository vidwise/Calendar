/*----------------------------------------------------------------
|	Autor: Pere Millán (DEIM, URV)
|	Data:  Març/2020       		Versió: 1.0
|-----------------------------------------------------------------|
|	Nom fitxer: jocproves_divmod.c
|   Descripcio: Codi en C d'un possible JOC DE PROVES
|               de les rutines de divisió/mòdul (FCdivmod.s).
|   Rutina a cridar: void test(void);
| ----------------------------------------------------------------*/

#include "FCdivmod.h"	/* Declaracions de rutines i símbols dins de FCdivmod.s */

#include "test_utils.h"	/* Rutines d'utilitat per a tests/jocs de proves */


/* ======================
   Proves rutines FCtimes
   ====================== */

/* Cada rutina de prova retorna un bool (true:ok; false:error) */

	/******************/
	/* Proves div_mod */
	/******************/

bool prova_div_mod_divisio_exacta()
{
	u32 quo, mod;
	u8 result;

	result = div_mod (12345, 15, &quo, &mod);

	return ( quo == 823 && mod == 0 && result == DIVMOD_ERROR_NOERROR );
}


bool prova_div_mod_divisio_inexacta()
{
	u32 quo, mod;
	u8 result;

	result = div_mod (54321, 15, &quo, &mod);

	return ( quo == 3621 && mod == 6 && result == DIVMOD_ERROR_NOERROR );
}


bool prova_div_mod_resultat_zero()
{
	u32 quo, mod;
	u8 result;

	result = div_mod (123, 456, &quo, &mod);

	return ( quo == 0 && mod == 123 && result == DIVMOD_ERROR_NOERROR );
}


bool prova_div_mod_divisio_entre_zero()
{
	u32 quo, mod;
	u8 result;

	result = div_mod (13579, 0, &quo, &mod);

	return ( result == DIVMOD_ERROR_DIVBYZERO );
}


bool prova_div_mod_quocient_no_alineat()
{
	u32 mod;
	u8 result;

	result = div_mod (1, 2, (u32 *)3, &mod);

	return ( result == DIVMOD_ERROR_NOTALIGN4 );
}


bool prova_div_mod_residu_no_alineat()
{
	u32 quo;
	u8 result;

	result = div_mod (1, 2, &quo, (u32 *)3);

	return ( result == DIVMOD_ERROR_NOTALIGN4 );
}


bool prova_div_mod_adreces_iguals()
{
	u32 quo;
	u8 result;

	result = div_mod (1, 2, &quo, &quo);

	return ( result == DIVMOD_ERROR_SAMEADDR );
}



	/****************/
	/* Proves FCdiv */
	/****************/

bool prova_FCdiv_divisio_exacta()
{
	u32 resultat;

	resultat = FCdiv (12345, 15);

	return ( resultat == 823 );
}


bool prova_FCdiv_divisio_inexacta()
{
	u32 resultat;

	resultat = FCdiv (54321, 15);

	return ( resultat == 3621 );
}


bool prova_FCdiv_resultat_zero()
{
	u32 resultat;

	resultat = FCdiv (123, 456);

	return ( resultat == 0 );
}


bool prova_FCdiv_divisio_entre_zero()
{
	u32 resultat;

	resultat = FCdiv (13579, 0);

	return ( resultat == DIVMOD_RESULT_ERROR );
}



	/****************/
	/* Proves FCmod */
	/****************/

bool prova_FCmod_divisio_exacta()
{
	u32 resultat;

	resultat = FCmod (12345, 15);

	return ( resultat == 0 );
}


bool prova_FCmod_divisio_inexacta()
{
	u32 resultat;

	resultat = FCmod (54321, 15);

	return ( resultat == 6 );
}


bool prova_FCmod_divisio_entre_zero()
{
	u32 resultat;

	resultat = FCmod (13579, 0);

	return ( resultat == DIVMOD_RESULT_ERROR );
}




/**********************************************************/
/* "Empaquetar" cada prova individual en un joc de proves */
/**********************************************************/

functest jocDeProvesDivMod[] = 
{
	/* Prova  0 */ prova_div_mod_divisio_exacta,
	/* Prova  1 */ prova_div_mod_divisio_inexacta,
	/* Prova  2 */ prova_div_mod_resultat_zero,
	/* Prova  3 */ prova_div_mod_divisio_entre_zero,
	/* Prova  4 */ prova_div_mod_quocient_no_alineat,
	/* Prova  5 */ prova_div_mod_residu_no_alineat,
	/* Prova  6 */ prova_div_mod_adreces_iguals,
	/* Prova  7 */ prova_FCdiv_divisio_exacta,
	/* Prova  8 */ prova_FCdiv_divisio_inexacta,
	/* Prova  9 */ prova_FCdiv_resultat_zero,
	/* Prova 10 */ prova_FCdiv_divisio_entre_zero,
	/* Prova 11 */ prova_FCmod_divisio_exacta,
	/* Prova 12 */ prova_FCmod_divisio_inexacta,
	/* Prova 13 */ prova_FCmod_divisio_entre_zero,
};




u8 num_tests_ok;	/* comptar quants tests ok */
u32 quins_errors;	/* per marcar 1 bit per cada test amb error */

u8 total_errors = 234;

void test(void)		/* rutina que comprova tots els tests */
{
	verificarJocDeProves(jocDeProvesDivMod, 14, &num_tests_ok, &quins_errors);
		/* Si tot va bé, num_tests_ok será 14 i quins_errors 0 */
		/* Si hi ha errors, num_tests_ok < 14 i quins_errors tindrà bits a 1 */

	total_errors = ( 14 - num_tests_ok ); 
}


