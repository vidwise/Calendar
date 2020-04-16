/*----------------------------------------------------------------
|	Autor: Pere Millán (DEIM, URV)
|	Data:  Març/2020       		Versió: 1.0
|-----------------------------------------------------------------|
|	Nom fitxer: jocproves_d.c
|   Descripcio: Codi en C d'un possible JOC DE PROVES
|               de les rutines de dates/calendari (FCdates.s).
|   Rutina a cridar: void test(void);
| ----------------------------------------------------------------*/

#include "FCdates.h"	/* Declaracions de rutines dins de FCdates.s */

#include "test_utils.h"	/* Rutines d'utilitat per a tests/jocs de proves */


/****************************************************/
/* Declaració de símbols per treballar amb màscares */
/*                                                  */
/*		Camps: 0000aaaaaaaaaaaaaaammmmddddd0000		*/
/****************************************************/

	/************/
	/* MÀSCARES */
	/************/

#define DATE_YEAR_MASK 	 	0b00001111111111111110000000000000
#define DATE_MONTH_MASK	 	0b00000000000000000001111000000000
#define DATE_DAY_MASK		0b00000000000000000000000111110000

	/* Per poder fer "extensió de signe negatiu" de l'any: */
#define DATE_YEAR_SIGN_EXT	0b11110000000000000000000000000000


	/*******************************************/
	/* POSICIÓ DE BITS INICIAL/LSB I FINAL/MSB */
	/*******************************************/

#define DATE_YEAR_MSB 		27
#define DATE_YEAR_LSB 		13
#define DATE_MONTH_MSB 		12
#define DATE_MONTH_LSB 		 9
#define DATE_DAY_MSB		 8
#define DATE_DAY_LSB		 4


	/**********************************/
	/* Macro per crear valors fc_date */
	/**********************************/

#define MKD(aCa2,m,d) ( \
		  ((aCa2<<DATE_YEAR_LSB) & DATE_YEAR_MASK) \
		| ((m<<DATE_MONTH_LSB) & DATE_MONTH_MASK) \
		| ((d<<DATE_DAY_LSB) & DATE_DAY_MASK) \
	)


/* ======================
   Proves rutines FCdates
   ====================== */

/* Cada rutina de prova retorna un bool (true:ok; false:error) */

	/**********************/
	/* Proves create_date */
	/**********************/


bool prova_create_date_dins_rang_DC()
{
	fc_date result = create_date(true, 2020, 3, 30);
	fc_date esperat = MKD(2020, 3, 30);
	return ( result == esperat );
}


bool prova_create_date_dins_rang_AC_fundacio_Roma()
{
		/* Roma es va fundar el 21 d'abril de 753 AC */
	fc_date result = create_date(false, 753, 4, 21);
	fc_date esperat = MKD(-753, 4, 21);
	return ( result == esperat );
}


bool prova_create_date_fora_rang_any0DC()
{
	fc_date result = create_date(true, 0, 1, 2);
	fc_date esperat = MKD(1, 1, 2);
	return ( result == esperat );
}


bool prova_create_date_fora_rang_any0AC()
{
	fc_date result = create_date(false, 0, 1, 2);
	fc_date esperat = MKD(-1, 1, 2);
	return ( result == esperat );
}


bool prova_create_date_fora_rang_tot0()
{
	fc_date result = create_date(false, 0, 0, 0);
	fc_date esperat = MKD(-1, 1, 1);
	return ( result == esperat );
}


bool prova_create_date_fora_rang_tot_excedit()
{
	fc_date result = create_date(true, 10000, 13, 32);
	fc_date esperat = MKD(9999, 12, 31);
	return ( result == esperat );
}


bool prova_create_date_fora_rang_dies_exces_mes30dies()
{
	fc_date result = create_date(true, 2020, 4, 31);
	fc_date esperat = MKD(2020, 4, 30);
	return ( result == esperat );
}


bool prova_create_date_fora_rang_dies_exces_mes31dies()
{
	fc_date result = create_date(false, 2020, 3, 32);
	fc_date esperat = MKD(-2020, 3, 31);
	return ( result == esperat );
}



	/**************************/
	/* Proves is_after_Christ */
	/**************************/

bool prova_is_after_Christ_DC()
{
	bool result = is_after_Christ( MKD(2020,1,1) );
	return ( result == true );
}


bool prova_is_after_Christ_AC()
{
	bool result = is_after_Christ( MKD(-2020,1,1) );
	return ( result == false );
}



	/*****************************/
	/* Proves get_year_magnitude */
	/*****************************/

bool prova_get_year_magnitude_DC()
{
	u16 result = get_year_magnitude( MKD(1, 2, 3) );
	return ( result == 1 );
}


bool prova_get_year_magnitude_AC()
{
	u16 result = get_year_magnitude( MKD(-1, 2, 3) );
	return ( result == 1 );
}



	/***********************/
	/* Proves get_year_Ca2 */
	/***********************/

bool prova_get_year_Ca2_DC()
{
	s16 result = get_year_Ca2( MKD(1, 2, 3) );
	return ( result == 1 );
}


bool prova_get_year_Ca2_AC()
{
	s16 result = get_year_Ca2( MKD(-1, 2, 3) );
	return ( result == -1 );
}



	/********************/
	/* Proves get_month */
	/********************/

bool prova_get_month1()
{
	u8 result = get_month( MKD(1, 1, 1) );
	return ( result == 1 );
}


bool prova_get_month12()
{
	u8 result = get_month( MKD(12, 12, 12) );
	return ( result == 12 );
}



	/******************/
	/* Proves get_day */
	/******************/

bool prova_get_day1()
{
	u8 result = get_day( MKD(1, 1, 1) );
	return ( result == 1 );
}


bool prova_get_day31()
{
	u8 result = get_day( MKD(1, 1, 31) );
	return ( result == 31 );
}



	/***********************/
	/* Proves is_leap_year */
	/***********************/

bool prova_is_leap_year_400AC()
{
	bool result = is_leap_year( -400 );
	return ( result == false );
}


bool prova_is_leap_year_100AC()
{
	bool result = is_leap_year( -100 );
	return ( result == false );
}


bool prova_is_leap_year_40AC()
{
	bool result = is_leap_year( -40 );
	return ( result == true );
}


bool prova_is_leap_year_100DC()
{
	bool result = is_leap_year( 100 );
	return ( result == true );
}


bool prova_is_leap_year_1600DC()
{
	bool result = is_leap_year( 1600 );
	return ( result == true );
}


bool prova_is_leap_year_1900DC()
{
	bool result = is_leap_year( 1900 );
	return ( result == false );
}


bool prova_is_leap_year_1992DC()
{
	bool result = is_leap_year( 1992 );
	return ( result == true );
}



	/************************/
	/* Proves days_in_month */
	/************************/

bool prova_days_in_month_march()
{
	u8 result = days_in_month( 3, 2020 );

	return ( result == 31 );
}


bool prova_days_in_month_april()
{
	u8 result = days_in_month( 4, 2345 );

	return ( result == 30 );
}


bool prova_days_in_month_feb1900()
{
	u8 result = days_in_month( 2, 1900 );

	return ( result == 28 );
}


bool prova_days_in_month_feb1992()
{
	u8 result = days_in_month( 2, 1992 );

	return ( result == 29 );
}



	/**************************/
	/* Proves get_century_Ca2 */
	/**************************/

bool prova_get_century_Ca2_753AC()
{
	s8 result = get_century_Ca2( -753 );
	return ( result == -8 );
}


bool prova_get_century_Ca2_45AC()
{
	s8 result = get_century_Ca2( -45 );
	return ( result == -1 );
}


bool prova_get_century_Ca2_2000DC()
{
	s8 result = get_century_Ca2( 2000 );
	return ( result == 20 );
}


bool prova_get_century_Ca2_2001DC()
{
	s8 result = get_century_Ca2( 2001 );
	return ( result == 21 );
}


bool prova_get_century_fora_rang1()
{
	s8 result = get_century_Ca2( 0 );
	return ( result == 0 );
}


bool prova_get_century_fora_rang2()
{
	s8 result = get_century_Ca2( -10000 );
	return ( result == 0 );
}


bool prova_get_century_fora_rang3()
{
	s8 result = get_century_Ca2( 10000 );
	return ( result == 0 );
}



	/*******************/
	/* Proves week_day */
	/*******************/

bool prova_week_day_Bcn92()
{
	u8 result;

	result = week_day (25, 7, 1992);

	return ( result == 6 );
}


bool prova_week_day_30mar2020()
{
	u8 result;

	result = week_day (30, 3, 2020);

	return ( result == 1 );
}


bool prova_week_day_1abr2020()
{
	u8 result;

	result = week_day (1, 4, 2020);

	return ( result == 3 );
}


bool prova_week_day_29feb2020()
{
	u8 result;

	result = week_day (29, 2, 2020);

	return ( result == 6 );
}


bool prova_week_day_fora_rang1()
{
	u8 result;

	result = week_day (2, 1, 0);

	return ( result == 0 );
}


bool prova_week_day_fora_rang2()
{
	u8 result;

	result = week_day (1, 13, 1);

	return ( result == 0 );
}


bool prova_week_day_fora_rang3()
{
	u8 result;

	result = week_day (0, 1, 2);

	return ( result == 0 );
}


	/*********************************/
	/* Proves create_binary_calendar */
	/*********************************/

	/* Rutina auxiliar per comparar dues zones de memòria de "size" bytes */
bool mem_cmp_equal (u8* start1, u8* start2, u32 size)
{
	bool iguals;

	s32 offset = size;
	do
	{
		offset--;
	} while ( offset >= 0 && start1[offset] == start2[offset] );
	iguals = (offset == -1);

	return iguals;
}

	/* Calendaris de prova: */
s8 calMar2020DC[] = {
	 0, 3, 0, 2, 0, 2, 0,
	 0, 0, 0, 0, 0, 0, 1,
	 2, 3, 4, 5, 6, 7, 8, 
	 9,10,11,12,13,14,15,
	16,17,18,19,20,21,22,
	23,24,25,26,27,28,29,
	30,31, 0, 0, 0, 0, 0
	};
s8 calAbr2020DC[] = {
	 0, 4, 0, 2, 0, 2, 0,
	 0, 0, 1, 2, 3, 4, 5,
	 6, 7, 8, 9,10,11,12, 
	13,14,15,16,17,18,19,
	20,21,22,23,24,25,26,
	27,28,29,30, 0, 0, 0,
	 0, 0, 0, 0, 0, 0, 0
	};
s8 calFeb2016DC[] = {
	 0, 2, 0, 2, 0, 1, 6,
	 1, 2, 3, 4, 5, 6, 7,
	 8, 9,10,11,12,13,14, 
	15,16,17,18,19,20,21,
	22,23,24,25,26,27,28,
	29, 0, 0, 0, 0, 0, 0,
	 0, 0, 0, 0, 0, 0, 0
	};
s8 calFeb2015DC[] = {
	 0, 2, 0, 2, 0, 1, 5,
	 0, 0, 0, 0, 0, 0, 1,
	 2, 3, 4, 5, 6, 7, 8, 
	 9,10,11,12,13,14,15,
	16,17,18,19,20,21,22,
	23,24,25,26,27,28, 0,
	 0, 0, 0, 0, 0, 0, 0
	};
s8 calFeb2010DC[] = {
	 0, 2, 0, 2, 0, 1, 0,
	 1, 2, 3, 4, 5, 6, 7,
	 8, 9,10,11,12,13,14, 
	15,16,17,18,19,20,21,
	22,23,24,25,26,27,28,
	 0, 0, 0, 0, 0, 0, 0,
	 0, 0, 0, 0, 0, 0, 0
	};
s8 calJul1992DC[] = {
	 0, 7, 0, 1, 9, 9, 2,
	 0, 0, 1, 2, 3, 4, 5,
	 6, 7, 8, 9,10,11,12, 
	13,14,15,16,17,18,19,
	20,21,22,23,24,25,26,
	27,28,29,30,31, 0, 0,
	 0, 0, 0, 0, 0, 0, 0
	};
s8 calOct1582AC[] = {
	 1, 0,-1, 1, 5, 8, 2,
	 1, 2, 3, 4, 5, 6, 7,
	 8, 9,10,11,12,13,14, 
	15,16,17,18,19,20,21,
	22,23,24,25,26,27,28,
	29,30,31, 0, 0, 0, 0,
	 0, 0, 0, 0, 0, 0, 0
	};
s8 calAbr753AC[] = {
	 0, 4,-1, 0, 7, 5, 3,
	 1, 2, 3, 4, 5, 6, 7,
	 8, 9,10,11,12,13,14, 
	15,16,17,18,19,20,21,
	22,23,24,25,26,27,28,
	29,30, 0, 0, 0, 0, 0,
	 0, 0, 0, 0, 0, 0, 0
	};

s8 calendari1[7][7];

bool prova_create_binary_calendar_march2020()
{
	bool result, fila0ok, zerosAbansOk, zerosDespresOk, diesNoZeroOk;
	u8 dia;
	s8 *punter;

	result = create_binary_calendar (3, 2020, calendari1);

		/* comprovar fila 1 */
	fila0ok = ( (calendari1[0][0] == 0) && (calendari1[0][1] == 3)
		&& (calendari1[0][2] == 0)
		&& (calendari1[0][3] == 2) && (calendari1[0][4] == 0) 
		&& (calendari1[0][5] == 2) && (calendari1[0][6] == 0) );

		/* comprovar zeros abans */
	zerosAbansOk = true;
	for (dia = 0; dia <= 5; dia++)
		if (calendari1[1][dia] != 0)
			zerosAbansOk = false;

		/* comprovar zeros després */
	zerosDespresOk = true;
	for (dia = 2; dia <= 6; dia++)
		if (calendari1[6][dia] != 0)
			zerosDespresOk = false;

		/* comprovar dies no zero */
	diesNoZeroOk = true;
	punter = &(calendari1[1][6]);
	for (dia = 1; dia <= 31; dia++)
	{
		if (*punter != dia)
			diesNoZeroOk = false;

		punter++;	/* Avançar a següent casella calendari1 */
	}
	
	result = ( (result == true) && (fila0ok == true) && (zerosAbansOk == true)
			&& (zerosDespresOk == true) && (diesNoZeroOk == true) );

	return ( result == true );
}


bool prova_create_binary_calendar_march2020DC()
{
	bool result, memOk;

	result = create_binary_calendar (3, 2020, calendari1);
	memOk = mem_cmp_equal ( (u8*)calendari1, (u8*)calMar2020DC, 7*7 );

	return (result == true && memOk == true);
}


bool prova_create_binary_calendar_abril2020DC()
{
	bool result, memOk;

	result = create_binary_calendar (4, 2020, calendari1);
	memOk = mem_cmp_equal ( (u8*)calendari1, (u8*)calAbr2020DC, 7*7 );

	return (result == true && memOk == true);
}


bool prova_create_binary_calendar_febrer2016DC()
{
	bool result, memOk;

	result = create_binary_calendar (2, 2016, calendari1);
	memOk = mem_cmp_equal ( (u8*)calendari1, (u8*)calFeb2016DC, 7*7 );

	return (result == true && memOk == true);
}


bool prova_create_binary_calendar_febrer2015DC()
{
	bool result, memOk;

	result = create_binary_calendar (2, 2015, calendari1);
	memOk = mem_cmp_equal ( (u8*)calendari1, (u8*)calFeb2015DC, 7*7 );

	return (result == true && memOk == true);
}


bool prova_create_binary_calendar_febrer2010DC()
{
	bool result, memOk;

	result = create_binary_calendar (2, 2010, calendari1);
	memOk = mem_cmp_equal ( (u8*)calendari1, (u8*)calFeb2010DC, 7*7 );

	return (result == true && memOk == true);
}


bool prova_create_binary_calendar_juliol1992DC()
{
	bool result, memOk;

	result = create_binary_calendar (7, 1992, calendari1);
	memOk = mem_cmp_equal ( (u8*)calendari1, (u8*)calJul1992DC, 7*7 );

	return (result == true && memOk == true);
}


bool prova_create_binary_calendar_octubre1582AC()
{
	bool result, memOk;

	result = create_binary_calendar (10, -1582, calendari1);
	memOk = mem_cmp_equal ( (u8*)calendari1, (u8*)calOct1582AC, 7*7 );

	return (result == true && memOk == true);
}


bool prova_create_binary_calendar_abril753AC()
{
	bool result, memOk;

	result = create_binary_calendar (4, -753, calendari1);
	memOk = mem_cmp_equal ( (u8*)calendari1, (u8*)calAbr753AC, 7*7 );

	return (result == true && memOk == true);
}


bool prova_create_binary_calendar_mes0()
{
	bool result;

	result = create_binary_calendar (0, 2020, calendari1);

	return ( result == false );
}


bool prova_create_binary_calendar_any0()
{
	bool result;

	result = create_binary_calendar (12, 0, calendari1);

	return ( result == false );
}





	/********************************/
	/* Proves create_ascii_calendar */
	/********************************/

char calendari2[8][20];

	/* Calendaris de prova */
char calMar2020DC_CA[] = {
	"Març 2020 DC        "
	"Dl Dt Dc Dj Dv Ds Du"
	"                   1"
	" 2  3  4  5  6  7  8"
	" 9 10 11 12 13 14 15"
	"16 17 18 19 20 21 22"
	"23 24 25 26 27 28 29"
	"30 31               "
	};

char calAbr2020DC_ES[] = {
	"Abril 2020 DC       "
	"Lu Ma Mi Ju Vi Sá Do"
	"       1  2  3  4  5"
	" 6  7  8  9 10 11 12"
	"13 14 15 16 17 18 19"
	"20 21 22 23 24 25 26"
	"27 28 29 30         "
	"                    "
	};

char calFeb2016DC_EN[] = {
	"February 2016 DC    "
	"Mo Tu We Th Fr Sa Su"
	" 1  2  3  4  5  6  7"
	" 8  9 10 11 12 13 14"
	"15 16 17 18 19 20 21"
	"22 23 24 25 26 27 28"
	"29                  "
	"                    "
	};

char calFeb2015DC_FR[] = {
	"Février 2015 DC     "
	"Lu Ma Me Je Ve Sa Di"
	"                   1"
	" 2  3  4  5  6  7  8"
	" 9 10 11 12 13 14 15"
	"16 17 18 19 20 21 22"
	"23 24 25 26 27 28   "
	"                    "
	};

char calFeb2010DC_CA[] = {
	"Febrer 2010 DC      "
	"Dl Dt Dc Dj Dv Ds Du"
	" 1  2  3  4  5  6  7"
	" 8  9 10 11 12 13 14"
	"15 16 17 18 19 20 21"
	"22 23 24 25 26 27 28"
	"                    "
	"                    "
	};

char calJul1992DC_ES[] = {
	"Julio 1992 DC       "
	"Lu Ma Mi Ju Vi Sá Do"
	"       1  2  3  4  5"
	" 6  7  8  9 10 11 12"
	"13 14 15 16 17 18 19"
	"20 21 22 23 24 25 26"
	"27 28 29 30 31      "
	"                    "
	};

char calOct1582AC_EN[] = {
	"October 1582 AC     "
	"Mo Tu We Th Fr Sa Su"
	" 1  2  3  4  5  6  7"
	" 8  9 10 11 12 13 14"
	"15 16 17 18 19 20 21"
	"22 23 24 25 26 27 28"
	"29 30 31            "
	"                    "
	};

char calAbr753AC_FR[] = {
	"Avril 753 AC        "
	"Lu Ma Me Je Ve Sa Di"
	" 1  2  3  4  5  6  7"
	" 8  9 10 11 12 13 14"
	"15 16 17 18 19 20 21"
	"22 23 24 25 26 27 28"
	"29 30               "
	"                    "
	};



bool prova_create_ascii_calendar_Mar2020DC_CA()
{
	bool result, memOk;

	result = create_ascii_calendar (3, 2020, CALENDAR_LANG_CATALA, calendari2);
	memOk = mem_cmp_equal ( (u8*)calendari2, (u8*)calMar2020DC_CA, 8*20 );

	return (result == true && memOk == true);
}


bool prova_create_ascii_calendar_Abr2020DC_ES()
{
	bool result, memOk;

	result = create_ascii_calendar (4, 2020, CALENDAR_LANG_CASTELLANO, calendari2);
	memOk = mem_cmp_equal ( (u8*)calendari2, (u8*)calAbr2020DC_ES, 8*20 );

	return (result == true && memOk == true);
}


bool prova_create_ascii_calendar_Feb2016DC_EN()
{
	bool result, memOk;

	result = create_ascii_calendar (2, 2016, CALENDAR_LANG_ENGLISH, calendari2);
	memOk = mem_cmp_equal ( (u8*)calendari2, (u8*)calFeb2016DC_EN, 8*20 );

	return (result == true && memOk == true);
}


bool prova_create_ascii_calendar_Feb2015DC_FR()
{
	bool result, memOk;

	result = create_ascii_calendar (2, 2015, CALENDAR_LANG_FRANCAIS, calendari2);
	memOk = mem_cmp_equal ( (u8*)calendari2, (u8*)calFeb2015DC_FR, 8*20 );

	return (result == true && memOk == true);
}


bool prova_create_ascii_calendar_Feb2010DC_CA()
{
	bool result, memOk;

	result = create_ascii_calendar (2, 2010, CALENDAR_LANG_CATALA, calendari2);
	memOk = mem_cmp_equal ( (u8*)calendari2, (u8*)calFeb2010DC_CA, 8*20 );

	return (result == true && memOk == true);
}


bool prova_create_ascii_calendar_Jul1992DC_ES()
{
	bool result, memOk;

	result = create_ascii_calendar (7, 1992, CALENDAR_LANG_CASTELLANO, calendari2);
	memOk = mem_cmp_equal ( (u8*)calendari2, (u8*)calJul1992DC_ES, 8*20 );

	return (result == true && memOk == true);
}


bool prova_create_ascii_calendar_Oct1582AC_EN()
{
	bool result, memOk;

	result = create_ascii_calendar (10, -1582, CALENDAR_LANG_ENGLISH, calendari2);
	memOk = mem_cmp_equal ( (u8*)calendari2, (u8*)calOct1582AC_EN, 8*20 );

	return (result == true && memOk == true);
}


bool prova_create_ascii_calendar_Abr753AC_FR()
{
	bool result, memOk;

	result = create_ascii_calendar (4, -753, CALENDAR_LANG_FRANCAIS, calendari2);
	memOk = mem_cmp_equal ( (u8*)calendari2, (u8*)calAbr753AC_FR, 8*20 );

	return (result == true && memOk == true);
}





bool prova_create_ascii_calendar_mes0()
{
	bool result;

	result = create_ascii_calendar (0, 2020, 0, calendari2);

	return ( result == false );
}


bool prova_create_ascii_calendar_any0()
{
	bool result;

	result = create_ascii_calendar (12, 0, 0, calendari2);

	return ( result == false );
}








/**********************************************************/
/* "Empaquetar" cada prova individual en un joc de proves */
/**********************************************************/

functest jocDeProvesCreate[] = 
{
	/* Prova 0 */ prova_create_date_dins_rang_DC,
	/* Prova 1 */ prova_create_date_dins_rang_AC_fundacio_Roma,
	/* Prova 2 */ prova_create_date_fora_rang_any0DC,
	/* Prova 3 */ prova_create_date_fora_rang_any0AC,
	/* Prova 4 */ prova_create_date_fora_rang_tot0,
	/* Prova 5 */ prova_create_date_fora_rang_tot_excedit,
	/* Prova 6 */ prova_create_date_fora_rang_dies_exces_mes30dies,
	/* Prova 7 */ prova_create_date_fora_rang_dies_exces_mes31dies,
};


functest jocDeProvesGet[] = 
{
	/* Prova 0 */ prova_is_after_Christ_DC,
	/* Prova 1 */ prova_is_after_Christ_AC,
	/* Prova 2 */ prova_get_year_magnitude_DC,
	/* Prova 3 */ prova_get_year_magnitude_AC,
	/* Prova 4 */ prova_get_year_Ca2_DC,
	/* Prova 5 */ prova_get_year_Ca2_AC,
	/* Prova 6 */ prova_get_month1,
	/* Prova 7 */ prova_get_month12,
	/* Prova 8 */ prova_get_day1,
	/* Prova 9 */ prova_get_day31,
};


functest jocDeProvesAltresRuts[] = 
{
	/* Prova 0 */ prova_is_leap_year_400AC,
	/* Prova 1 */ prova_is_leap_year_100AC,
	/* Prova 2 */ prova_is_leap_year_40AC,
	/* Prova 3 */ prova_is_leap_year_100DC,
	/* Prova 4 */ prova_is_leap_year_1600DC,
	/* Prova 5 */ prova_is_leap_year_1900DC,
	/* Prova 6 */ prova_is_leap_year_1992DC,
	/* Prova 7 */ prova_days_in_month_march,
	/* Prova 8 */ prova_days_in_month_april,
	/* Prova 9 */ prova_days_in_month_feb1900,
	/* Prova 10 */ prova_days_in_month_feb1992,
	/* Prova 11 */ prova_get_century_Ca2_753AC,
	/* Prova 12 */ prova_get_century_Ca2_45AC,
	/* Prova 13 */ prova_get_century_Ca2_2000DC,
	/* Prova 14 */ prova_get_century_Ca2_2001DC,
	/* Prova 15 */ prova_get_century_fora_rang1,
	/* Prova 16 */ prova_get_century_fora_rang2,
	/* Prova 17 */ prova_get_century_fora_rang3,
	/* Prova 18 */ prova_week_day_Bcn92,
	/* Prova 19 */ prova_week_day_30mar2020,
	/* Prova 20 */ prova_week_day_1abr2020,
	/* Prova 21 */ prova_week_day_29feb2020,
	/* Prova 22 */ prova_week_day_fora_rang1,
	/* Prova 23 */ prova_week_day_fora_rang2,
	/* Prova 24 */ prova_week_day_fora_rang3,
};


functest jocDeProvesCalendariBinari[] = 
{
	/* Prova 0 */ prova_create_binary_calendar_march2020,
	/* Prova 0 */ prova_create_binary_calendar_march2020DC,
	/* Prova 2 */ prova_create_binary_calendar_abril2020DC,
	/* Prova 3 */ prova_create_binary_calendar_febrer2016DC,
	/* Prova 4 */ prova_create_binary_calendar_febrer2015DC,
	/* Prova 5 */ prova_create_binary_calendar_febrer2010DC,
	/* Prova 6 */ prova_create_binary_calendar_juliol1992DC,
	/* Prova 7 */ prova_create_binary_calendar_octubre1582AC,
	/* Prova 8 */ prova_create_binary_calendar_abril753AC,	
	/* Prova 9 */ prova_create_binary_calendar_mes0,
	/* Prova 10 */ prova_create_binary_calendar_any0,
};


functest jocDeProvesCalendariASCII[] = 
{
	/* Prova 0 */ prova_create_ascii_calendar_Mar2020DC_CA,
	/* Prova 1 */ prova_create_ascii_calendar_Abr2020DC_ES,
	/* Prova 2 */ prova_create_ascii_calendar_Feb2016DC_EN,
	/* Prova 3 */ prova_create_ascii_calendar_Feb2015DC_FR,
	/* Prova 4 */ prova_create_ascii_calendar_Feb2010DC_CA,
	/* Prova 5 */ prova_create_ascii_calendar_Jul1992DC_ES,
	/* Prova 6 */ prova_create_ascii_calendar_Oct1582AC_EN,
	/* Prova 7 */ prova_create_ascii_calendar_Abr753AC_FR,	
	/* Prova 8 */ prova_create_ascii_calendar_mes0,
	/* Prova 9 */ prova_create_ascii_calendar_any0,
};




	/* comptar quants tests ok */
u8 num_tests_ok_create, num_tests_ok_get, num_tests_ok_altres, num_tests_ok_cal_bin, num_tests_ok_cal_asc;	

	/* per marcar 1 bit per cada test amb error */
u32 quins_errors_create, quins_errors_get, quins_errors_altres, quins_errors_cal_bin, quins_errors_cal_asc;	

u8 total_errors = 234;

void test(void)		/* rutina que comprova tots els tests */
{
	/*
	create_binary_calendar (3, 2020, calendari1);
	create_ascii_calendar (3, 2020, CALENDAR_LANG_CATALA, calendari2);

	create_binary_calendar (4, 2020, calendari1);
	create_ascii_calendar (4, 2020, CALENDAR_LANG_CASTELLANO, calendari2);

	create_binary_calendar (2, 2010, calendari1);
	create_ascii_calendar (2, 2010, CALENDAR_LANG_ENGLISH, calendari2);

	create_binary_calendar (4, -753, calendari1);
	create_ascii_calendar (4, -753, CALENDAR_LANG_FRANCAIS, calendari2);
	*/

	verificarJocDeProves(jocDeProvesCreate, 8, &num_tests_ok_create, &quins_errors_create);
		/* Si tot va bé, num_tests_ok será 8 i quins_errors 0 */
		/* Si hi ha errors, num_tests_ok < 8 i quins_errors tindrà bits a 1 */

	verificarJocDeProves(jocDeProvesGet, 10, &num_tests_ok_get, &quins_errors_get);
		/* Si tot va bé, num_tests_ok será 10 i quins_errors 0 */
		/* Si hi ha errors, num_tests_ok < 10 i quins_errors tindrà bits a 1 */

	verificarJocDeProves(jocDeProvesAltresRuts, 25, &num_tests_ok_altres, &quins_errors_altres);
		/* Si tot va bé, num_tests_ok será 25 i quins_errors 0 */
		/* Si hi ha errors, num_tests_ok < 25 i quins_errors tindrà bits a 1 */

	verificarJocDeProves(jocDeProvesCalendariBinari, 11, &num_tests_ok_cal_bin, &quins_errors_cal_bin);
		/* Si tot va bé, num_tests_ok será 11 i quins_errors 0 */
		/* Si hi ha errors, num_tests_ok < 11 i quins_errors tindrà bits a 1 */

	verificarJocDeProves(jocDeProvesCalendariASCII, 10, &num_tests_ok_cal_asc, &quins_errors_cal_asc);
		/* Si tot va bé, num_tests_ok será 10 i quins_errors 0 */
		/* Si hi ha errors, num_tests_ok < 10 i quins_errors tindrà bits a 1 */

	total_errors = ( 8 - num_tests_ok_create ) + ( 10 - num_tests_ok_get ) + ( 25 - num_tests_ok_altres )
		+ ( 11 - num_tests_ok_cal_bin ) + ( 10 - num_tests_ok_cal_asc ); 

}




