/*----------------------------------------------------------------
|	Autor: Pere Millán (DEIM, URV)
|	Data:  Març,Abril 2020				Versió: 1.1
|-----------------------------------------------------------------|
|	Nom fitxer: FCdates.h
|   Descripció: declaració de tipus i rutines per  
|			    treballar amb dates i calendaris.
| ----------------------------------------------------------------*/

#ifndef FCDATES_H
#define FCDATES_H

#include "FCtypes.h"	/* u8, s8, u32, bool ... */


	/* declaració dels tipus fc_date */
typedef u32 fc_date;		/* AAAA/MM/DD */
		/*		Camps: 0000aaaaaaaaaaaaaaammmmddddd0000		*/


	/* rutines a desenvolupar/disponibles (quan s'implementin) */

	/* Crear valors a partir dels seus components */
		/* Si algun paràmetre/camp està fora de rang, posarà el valor vàlid més proper */

extern fc_date create_date ( bool despresCrist, u16 any, u8 mes, u8 dia );
		/* Crea un fc_date amb els valors donats (corregits si estan fora de rang) */


	/* rutines de consulta de valors de camps */
extern bool is_after_Christ ( fc_date data_completa );
extern u16 get_year_magnitude ( fc_date data_completa );  /* 1..9999 */
extern s16 get_year_Ca2 ( fc_date data_completa );	/* -9999..-1, 1..9999 */
extern u8 get_month ( fc_date data_completa );		/* 1..12 */
extern u8 get_day ( fc_date data_completa );		/* 1..28/29/30/31 */


	/* Altres rutines de dates */
extern bool is_leap_year ( s16 any_Ca2 );	/* És any de traspàs/bixest? */
extern u8 days_in_month ( u8 mes, s16 any_Ca2 );	/* Dies que té aquell mes */
extern s8 get_century_Ca2 ( s16 any_Ca2 );	/* Segle al qual pertany l'any */
extern u8 week_day ( u8 dia, u8 mes, s16 any_Ca2 );		/* Dia de la setmana: 
													1=dilluns, ... 7=diumenge */

	/* Generació de calendaris mensuals */
extern bool create_binary_calendar ( u8 mes, s16 any_Ca2, s8 calendari[7][7] );
extern bool create_ascii_calendar ( u8 mes, s16 any_Ca2, u8 language, char calendari[8][20] );

#define CALENDAR_LANG_CATALA     0
#define CALENDAR_LANG_CASTELLANO 1
#define CALENDAR_LANG_ENGLISH    2
#define CALENDAR_LANG_FRANCAIS   3

	/* Rutina auxiliar (ja implementada) */
extern s32 julian_day ( u8 dia, u8 mes, s16 any_Ca2 );	/* Dia julià d'aquella data */

#endif /* FCDATES_H */

