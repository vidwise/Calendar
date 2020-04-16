/*----------------------------------------------------------------
|	Autor: Pere Millán (DEIM, URV)
|	Data:  Març 2020					Versió: 1.0
|-----------------------------------------------------------------|
|	Nom fitxer: julianday.c
|   Descripció: càlcul del dia julià d'una data donada.
| ----------------------------------------------------------------*/


#include "FCtypes.h"


	/* Codi obtingut de https://pdc.ro.nu/jd-code.html */
long gregorian_calendar_to_jd(int y, int m, int d)
{
		/* És correcte per a dates posteriors a 15/oct/1582 (calendari Gregorià) */
		/* Per a dates anteriors (calendari Julià) el resultat és "aproximat" */
	y += 8000;
	if (m<3) 
	{
		y--;
		m += 12;
	}
	return (y*365) + (y/4) - (y/100) + (y/400) - 1200820
              + (m*153+3)/5 - 92
              + d-1
	;
}


s32 julian_day ( u8 dia, u8 mes, s16 any_Ca2 )	/* Dia julià de la data indicada */
{
	long jd;

	jd = gregorian_calendar_to_jd(any_Ca2, mes, dia);
	
	/* To-do: ajustar a dates del calendari Julià (abans 4/oct/1582) */

	return jd;
}





