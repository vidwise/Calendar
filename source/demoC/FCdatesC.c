/*----------------------------------------------------------------
|	Autor:	Pere Millán
|	Data:	Mar,Abr/2020       			Versió: 1.0
|-----------------------------------------------------------------|
|	Nom fitxer: FCdatesC.c
|   Descripcio: exemple d'implementació en C de les rutines 
|			`	per treballar amb dates i calendaris.
|-----------------------------------------------------------------|
|   programador/a 1: pere.millan@urv.cat
| ----------------------------------------------------------------*/

#include "FCdates.h"	/* declaració de tipus i rutines de temps */
#include "FCdivmod.h"	/* rutines de divisió / mòdul */



/****************************************************/
/* Declaració de símbols per treballar amb màscares */
/*                                                  */
/*		Camps: 0000aaaaaaaaaaaaaaammmmddddd0000		*/
/****************************************************/

	/************/
	/* MÀSCARES */
	/************/

#define DATE_YEAR_MASK  	0b00001111111111111110000000000000
#define DATE_YEAR_SIGN_MASK 0b00001000000000000000000000000000
#define DATE_MONTH_MASK 	0b00000000000000000001111000000000
#define DATE_DAY_MASK   	0b00000000000000000000000111110000

	/* Per poder fer "extensió de signe negatiu" de l'any: */
#define DATE_YEAR_SIGN_EXT	0b11110000000000000000000000000000


	/*******************************************/
	/* POSICIÓ DE BITS INICIAL/LSB I FINAL/MSB */
	/*******************************************/

#define DATE_YEAR_MSB	27
#define DATE_YEAR_LSB	13
#define DATE_MONTH_MSB	12
#define DATE_MONTH_LSB	 9
#define DATE_DAY_MSB	 8
#define DATE_DAY_LSB	 4


/*********************/
/* RUTINES PÚBLIQUES */
/*********************/

	/* Crear valors a partir dels seus components */
		/* Si algun paràmetre/camp està fora de rang, posarà el valor vàlid més proper */

fc_date create_date ( bool despresCrist, u16 any, u8 mes, u8 dia )
		/* Crea un fc_date amb els valors donats (corregits si estan fora de rang) */
{
	fc_date resultat;
	s16 any_Ca2;
	u8 dies_mes;

		/* Comprovar rangs */
	if (any < 1) any = 1;
	if (any > 9999) any = 9999;
	if (mes < 1) mes = 1;
	if (mes > 12) mes = 12;
	if (dia < 1) dia = 1;

		/* Calcular any en complement a 2 */
	if (despresCrist)
		any_Ca2 = any;
	else
		any_Ca2 = -any;

		/* Obtenir  */
	dies_mes = days_in_month (mes, any_Ca2);
	if (dia > dies_mes) dia = dies_mes;

		/* combinar camps fc_date */
	resultat = 
			 ( (any_Ca2 << DATE_YEAR_LSB) & DATE_YEAR_MASK )
	         | (mes << DATE_MONTH_LSB)
			 | (dia << DATE_DAY_LSB)
			 ;

	return resultat;
}

/* -------------------------------------------------------- */

	/* rutines de consulta de valors de camps */
bool is_after_Christ ( fc_date data_completa )
{
	bool resultat;

	resultat = ( data_completa & DATE_YEAR_SIGN_MASK ) == 0;

	return resultat;
}

/* -------------------------------------------------------- */

u16 get_year_magnitude ( fc_date data_completa )	/* 1..9999 */
{
	u16 resultat;
	s32 any_Ca2;

	if ( (data_completa & DATE_YEAR_SIGN_MASK) == 0 ) 
			/* Any positiu: el valor ja és la magnitut */
		resultat = (data_completa & DATE_YEAR_MASK) >> DATE_YEAR_LSB ;
	else
	{		/* Any negatiu: cal fer canvi de signe, negació */
		any_Ca2 = (DATE_YEAR_SIGN_EXT | (data_completa & DATE_YEAR_MASK)) >> DATE_YEAR_LSB ;
		resultat = -any_Ca2;  /* Passar de negatiu a positiu */
	}

	return resultat;
}


/* -------------------------------------------------------- */

s16 get_year_Ca2 ( fc_date data_completa )	/* -9999..-1, 1..9999 */
{
	s16 resultat;
	s32 any_Ca2;

	any_Ca2 = (data_completa & DATE_YEAR_MASK);
	if ( (any_Ca2 & DATE_YEAR_SIGN_MASK) != 0 ) 
			/* Any negatiu: cal fer extensió de signe */
		any_Ca2 = any_Ca2 | DATE_YEAR_SIGN_EXT ;

	any_Ca2 = any_Ca2 >> DATE_YEAR_LSB ;
	resultat = (s16)any_Ca2;  /* Agafar 16 bits baixos */

	return resultat;
}


/* -------------------------------------------------------- */

u8 get_month ( fc_date data_completa )		/* 1 .. 12 */
{
	u8 resultat;

	resultat = ( data_completa & DATE_MONTH_MASK ) >> DATE_MONTH_LSB;

	return resultat;
}

/* -------------------------------------------------------- */

u8 get_day ( fc_date data_completa )		/* 1..28/29/30/31 */
{
	u8 resultat;
	resultat = ( data_completa & DATE_DAY_MASK ) >> DATE_DAY_LSB;
	return resultat;
}

/* -------------------------------------------------------- */

bool is_leap_year ( s16 any_Ca2 )	/* És any de traspàs/bixest? */
{
	bool resultat, mult4, mult100, mult400;
	u32 modul;

	if ( any_Ca2 < -46)	/* Els anys de traspàs es van afegir l'any 46 abans de Crist */
		resultat = false;
	else
	{
		mult4 = (( any_Ca2 & 0b11) == 0);	/* Múltiple de 4 si els 2 bits baixos són 00 */
		if ( any_Ca2 <= 1582 )
		{	/* Fins a l'any 1582 els anys múltiples de 4 eren de traspàs */
			resultat = mult4;
		}
		else	/* Calendari Gregorià */
		{	/* Els anys de traspàs són els múltiples de 4, no múltiples de 100 o múltiples de 400 */
			modul = FCmod ( any_Ca2, 100);
			mult100 = (modul == 0);
			modul = FCmod ( any_Ca2, 400);
			mult400 = (modul == 0);
			resultat = ((mult4 && !mult100) || mult400);
		}
	}

	return resultat;
}


/* -------------------------------------------------------- */

static u8 diesPerMes[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

u8 days_in_month ( u8 mes, s16 any_Ca2 )
{
	u8 resultat;
	bool anyTraspas;

	if (mes < 1 || mes > 12 || any_Ca2 < -9999 || any_Ca2 == 0 || any_Ca2 > 9999)
		resultat = 0;
	else
	{
		resultat = diesPerMes[mes-1];
		if (mes == 2)
		{
			anyTraspas = is_leap_year ( any_Ca2 );
			if ( !anyTraspas )
				resultat = 28;
			else
				resultat = 29;
		}
	}

	return resultat;
}


/* -------------------------------------------------------- */

s8 get_century_Ca2 ( s16 any_Ca2 )	/* Segle al qual pertany l'any */
{
	s8 resultat;
	u16 anyAbsolut;

	if ( any_Ca2 < -9999 || any_Ca2 == 0 || any_Ca2 > 9999 )
		resultat = 0;
	else
	{
		if ( any_Ca2 > 0)
		{
			resultat = 1 + FCdiv (any_Ca2 - 1, 100);
		}
		else
		{
			anyAbsolut = -any_Ca2;
			resultat = -( 1 + FCdiv ( anyAbsolut - 1, 100) );
		}
	}

	return resultat;
}


/* -------------------------------------------------------- */

u8 week_day ( u8 dia, u8 mes, s16 any_Ca2 )	/* 1=dilluns, ... 7=diumenge */
{
	u8 resultat, diesMes;
	s32 dia_julia;

	diesMes = days_in_month ( mes, any_Ca2 );
	
	if ( diesMes == 0 || dia < 1 || dia > diesMes )
		resultat = 0;
	else
	{
		dia_julia = julian_day ( dia, mes, any_Ca2 );
		resultat = 1 + FCmod ( dia_julia + 0, 7 );
	}
	
	return resultat;
}


/* -------------------------------------------------------- */

	/* Declaració "forward" */
void mem_set(u8 *start, u8 value, u32 count);
	/* Escriu "count" valors "value" a partir de "start" */

	/* Genera el calendari del mes i any indicats 
	   sobre la matriu donada, amb valors numèrics */
bool create_binary_calendar ( u8 mes, s16 any_Ca2, s8 calendari[7][7] )
	/* Retorna true si s'ha pogut generar el calendari; false en cas de mes o any fora de rang */

	/* Format del calendari (per a març 2020): cada casella de la matriu conté valors -1..31
	   +--+--+--+--+--+--+--+
	   | 0| 3| 0| 2| 0| 2| 0|	Mes: 0 3	AC(-1)/DC(0)	Any: 2 0 2 0 (Mes i any a fila 0)
	   | 0  0  0  0  0  0  1|	1a setmana de Març (el mes comença diumenge, resta de dies a 0)
	   | 2  3  4  5  6  7  8|	2a setmana de Març, dies 2-8
	   | 9 10 11 12 13 14 15|	3a setmana de Març, dies 9-15
	   |16 17 18 19 20 21 22|	4a setmana de Març, dies 16-22
	   |23 24 25 26 27 28 29|	5a setmana de Març, dies 23-29
	   |30 31  0  0  0  0  0|	6a setmana de Març, dies 30 i 31, resta de dies amb 0
	*/
{
	bool resultat;
	u8 primerDiaSetmana, numDiesMes, dia;
	/* u8 fil, col; */
	s8 *punter;
	u32 quocient, residu;

	if ( mes < 1 || mes > 12 || any_Ca2 < -9999 || any_Ca2 == 0 || any_Ca2 > 9999 )
		resultat = false;
	else
	{
		numDiesMes = days_in_month ( mes, any_Ca2 );
		primerDiaSetmana = week_day ( 1, mes, any_Ca2 );

			/* Generar capçalera a fila 0 */
		div_mod ( mes, 10, &quocient, &residu );
		calendari[0][0] = quocient;
		calendari[0][1] = residu;

		if (any_Ca2 > 0)
			calendari[0][2] = 0;	/* Indicar any DC */
		else
		{
			calendari[0][2] = -1;	/* Indicar any AC */
			any_Ca2 = -any_Ca2;		/* Valor absolut de l'any */
		}

		div_mod ( any_Ca2, 10, &quocient, &residu );
		calendari[0][6] = residu;
		div_mod ( quocient, 10, &quocient, &residu );
		calendari[0][5] = residu;
		div_mod ( quocient, 10, &quocient, &residu );
		calendari[0][4] = residu;
		div_mod ( quocient, 10, &quocient, &residu );
		calendari[0][3] = residu;
		
			/* Emplenar resta del calendari amb 0 */
		/*
		for ( fil = 1; fil < 7; fil++ )
			for ( col = 0; col < 7; col++ )
				calendari[fil][col] = 0;
		*/
		mem_set( (u8*)&(calendari[1][0]), 0, 6*7 );
		
			/* Emplenar dies del calendari, recorregut lineal */
		punter = &(calendari[1][primerDiaSetmana - 1]);
		for (dia = 1; dia <= numDiesMes; dia++)
		{
				/* Canvi calendari Julià --> Gregorià? 
				   després del 4/oct/1582 va el 15/oct/1582 */
			/*
			if (dia==5 && mes==10 && any_Ca2==1582 && calendari[0][2] == 0)
				dia = 15;
			*/

			*punter = dia;	
			punter++;	/* Següent posició del calendari */
		}

		resultat = true;
	}

	return resultat;
}


/* -------------------------------------------------------- */

	/**********************/
	/* Rutines auxiliars: */
	/**********************/

void mem_set(u8 *start, u8 value, u32 count)
	/* Escriu "count" valors "value" a partir de "start" */
{
	while (count > 0)
	{
		count--;
		start[count] = value;
	}
}


u32 str_length (char *string)
	/* Retorna el número de caràcters de "string" */
{
	u32 length = 0;

	while (string[length] != 0) length++;

	return length;
}


void mem_copy (u8 *from, u8 *to, u32 count)
	/* Copia "count" bytes de "from" cap a "to" */
{
	while (count > 0)
	{
		count--;
		to[count] = from[count];
	}
}


u8 u32toString ( u32 number, char string[11] )
	/* Converteix "number" a string, 
	   retorna el número de dígits */
{
	u32 quo, mod;
	u8 mida = 0, i;
	char digit;

	quo = number;
	do
	{
		div_mod (quo, 10, &quo, &mod);
		string[mida] = mod + '0';
		mida++;
	} while ( quo > 0);
	string[mida] = 0;	/* Sentinella de final de string */
	
		/* Invertir caràcters */
	for ( i = 0; i < mida/2; i++ ){
		digit = string[i];
		string[i] = string[ mida-i-1 ];
		string[ mida-i-1 ] = digit;
	}

	return mida;
}


/*******************************/
/* Declaració de varis strings */
/*******************************/

	/* Noms de mesos, 4 idiomes, 12 mesos */
char *monthNames[4][12] = { 
	{"Gener","Febrer","Març","Abril","Maig","Juny","Juliol","Agost","Setembre","Octubre","Novembre","Desembre"},
	{"Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"},
	{"January","February","March","April","May","June","July","August","September","October","November","December"},
	{"Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"}
};

	/* Abreviatures dels dies de la setmana amb 2 caràcters: */
char weekDaysNames[4][14] = {
		"DlDtDcDjDvDsDu",
		"LuMaMiJuViSáDo",
		"MoTuWeThFrSaSu",
		"LuMaMeJeVeSaDi",
		};



	/* Genera el calendari del mes i any indicats, en l'idioma indicat, 
	   sobre la matriu donada, amb caràcters ASCII.
	   Idiomes --> 0: català, 1: castellano, 2: english, 3: français */
bool create_ascii_calendar ( u8 mes, s16 any_Ca2, u8 calendarLanguage, char calendari[8][20] )
	/* Retorna true si s'ha pogut generar el calendari; false en cas de mes o any fora de rang */

	/* Format del calendari (per a març 2020): cada casella de la matriu conté caràcters ASCII
	   +--------------------+
	   |Març 2020 DC        |	Nom del mes, any, AC/DC (a fila 0)
	   |dl dt dc dj dv ds du|	Inicials dels dies de la setmana (a fila 1)
	   |                   1|	1a setmana de Març (el mes comença diumenge, resta de dies a 0)
	   | 2  3  4  5  6  7  8|	2a setmana de Març, dies 2-8
	   | 9 10 11 12 13 14 15|	3a setmana de Març, dies 9-15
	   |16 17 18 19 20 21 22|	4a setmana de Març, dies 16-22
	   |23 24 25 26 27 28 29|	5a setmana de Març, dies 23-29
	   |30 31               |	6a setmana de Març, dies 30 i 31, resta de dies amb 0
	*/
{
	bool resultat, anyDC;
	u8 primerDiaSetmana, numDiesMes, i, fil, col;
	char *nomMes, buffer[11];
	u32 mida1, mida2, quo, mod, dia;

	if ( mes < 1 || mes > 12 || any_Ca2 < -9999 || any_Ca2 == 0 || any_Ca2 > 9999 )
		resultat = false;
	else
	{
		numDiesMes = days_in_month ( mes, any_Ca2 );
		primerDiaSetmana = week_day ( 1, mes, any_Ca2 );

			/* Emplenar tot el calendari amb espais en blanc */
		mem_set( (u8*)calendari, ' ', 8*20);

			/* Generar capçalera a fila 0 */
				/* nom mes */
		nomMes = monthNames[calendarLanguage][mes-1];
		mida1 = str_length (nomMes);
		mem_copy( (u8*)nomMes, (u8*)calendari, mida1);

				/* Any */
		if (any_Ca2 < 0)
		{
			anyDC = false;
			any_Ca2 = -any_Ca2;
		}
		else
			anyDC = true;

		mida2 = u32toString( any_Ca2, buffer );
		mem_copy( (u8*)buffer, (u8*)&(calendari[0][mida1+1]), mida2 );

				/* AC/DC */
		if (anyDC)
		{
			calendari[0][mida1+mida2+2] = 'D';
		}
		else
		{
			calendari[0][mida1+mida2+2] = 'A';
		}
		calendari[0][mida1+mida2+3] = 'C';

			/* Fila 1: sigles dies setmana */
		for(i=0; i<7; i++)
		{
			calendari[1][i*3]   = weekDaysNames[calendarLanguage][i*2];
			calendari[1][i*3+1] = weekDaysNames[calendarLanguage][i*2+1];
		}

			/* Files 2, 3, ... */
		fil = 2;
		col = primerDiaSetmana - 1;
		for (dia = 1; dia <= numDiesMes; dia++)
		{
				/* Canvi calendari Julià --> Gregorià? 
				   després del 4/oct/1582 va el 15/oct/1582 */
			/*
			if (dia==5 && mes==10 && any_Ca2==1582 && anyDC == true)
				dia = 15;
			*/

			div_mod(dia, 10, &quo, &mod);
			if (quo > 0)
				calendari[fil][col*3] = quo + '0';
			calendari[fil][col*3+1] = mod + '0';
			col++;
			if (col >= 7)
			{
				col = 0;
				fil++;
			}
		}

		resultat = true;
	}

	return resultat;
}



