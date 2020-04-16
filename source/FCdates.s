@;----------------------------------------------------------------
@;	Analista: Pere Millán
@;	Data:   Mar,Abr/2020       		Versió: 1.0
@;-----------------------------------------------------------------
@;	Nom fitxer: FCdates.s
@;  Descripcio: implementació de les rutines per 
@;				treballar amb dates i calendaris.
@;-----------------------------------------------------------------
@;   programador/a 1: pedro.espadas@estudiants.urv.cat
@;   programador/a 2: xxx.xxx@estudiants.urv.cat
@;   programador/a 3: xxx.xxx@estudiants.urv.cat
@; ----------------------------------------------------------------

.include "FCdivmod.i"

@; Declaració de símbols per treballar amb màscares
@;
@; 			Camps: 0000aaaaaaaaaaaaaaammmmddddd0000

@;		MÀSCARES :

DATE_YEAR_MASK      = 0b00001111111111111110000000000000
DATE_YEAR_SIGN_MASK = 0b00001000000000000000000000000000
DATE_MONTH_MASK     = 0b00000000000000000001111000000000
DATE_DAY_MASK       = 0b00000000000000000000000111110000

	@; Per poder fer "extensió de signe negatiu" de l'any: 
DATE_YEAR_SIGN_EXT  = 0b11110000000000000000000000000000


@;		POSICIÓ DE BITS INICIAL/LSB I FINAL/MSB :

DATE_YEAR_MSB  = 27
DATE_YEAR_LSB  = 13
DATE_MONTH_MSB = 12
DATE_MONTH_LSB =  9
DATE_DAY_MSB   =  8
DATE_DAY_LSB   =  4



@;--- .data. Non-zero Initialized data ---
.data
	diesPerMes:	.byte	31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31


@;-- .text. codi de les rutinas ---
.text	
		.align 2
		.arm


@; ========================================================
@;   Crear valors a partir dels seus components
@; ========================================================

@; fc_date create_date ( bool despresCrist, u16 any, u8 mes, u8 dia ) :
@;	  Crea un fc_date amb els valors donats
@;	  (els paràmetres fora de rang, es queden amb el valor vàlid més proper)
@;  Paràmetres:
@;      R0: despresCrist (0: abans de Crist; diferent de 0: després de Crist)
@;      R1: magnitud de l'any (rang vàlid: 1-9999)
@;      R2: mes (rang vàlid: 1-12)
@;      R3: dia (rang vàlid: 1-28/29/30/31, segons mes i any)
@;	Resultat:
@;		R0: valor fc_date amb els camps inicialitzats segons paràmetres
		.global create_date
create_date:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==

		@; Ajustat de valors
		@; Any
		cmp r1, #1
		movlt r1, #1  @; Si any < 1 --> any = 1
		
		ldr r4, =9999  @; Carreguem constant (limitació de ARM)
		cmp r1, r4  
		movhi r1, r4  @; Si any > 9999 --> any = 9999
		
		@; Mes
		cmp r2, #1  
		movlt r2, #1  @; Si mes < 1 --> mes = 1
		
		cmp r2, #12
		movhi r2, #12  @; Si mes > 12 --> mes = 12
		
		@; Dia
		cmp r3, #1
		movlt r3, #1  @; Si dia < 1 --> dia = 1
		
		@; caldrà veure quants dies té aquest mes per veure els dies superiors
		
		@; calcular any en Ca2. 
		cmp r0, #1
		beq .LFiAbansDeCrist  @; Si es després del naixement de Jesús no cal fer res
		mvn r0, r0  @; Sino apliquem NOT sobre el registre (Ca1)
		add r0, #1  @; I sumem 1 (Ca2)
		.LFiAbansDeCrist:
		
		@; //RF  FALTA CODIIII
		
		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar



@; ========================================================
@;   Rutines de consulta de valors de camps
@; ========================================================


@; bool is_after_Christ ( fc_date data_completa ) :
@;	  Retorna true (1) si la data indicada és després de Crist, o 0 en cas contrari
@;  Paràmetres:
@;      R0: valor fc_date
@;	Resultat:
@;		R0: 1 si la data indicada és després de Crist; 0 altrament
		.global is_after_Christ
is_after_Christ:
		push {r1, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==

		and r1, r0, #DATE_YEAR_SIGN_MASK  @; Apliquem máscara de "signe"
		cmp r1, #0  @; Veiem si queda un 0 o no
		moveq r0, #1  @; Si queda 0 no hi ha signe per tant després de Crist
		movne r0, #0  @; Sino pues 1 perque si que és després de Crist
		
		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1, pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; u16 get_year_magnitude ( fc_date data_completa ) :
@;	  Retorna el valor absolut (magnitud) del camp 'any' de la fc_date indicada
@;  Paràmetres:
@;      R0: valor fc_date
@;	Resultat:
@;		R0: valor absolut (magnitud) del camp 'any' de la fc_date indicada (1..9999)
		.global get_year_magnitude
get_year_magnitude:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		ldr r4, =DATE_YEAR_MASK  @; Carreguem constant (limitació ARM)
		and r2, r0, r4  @; Ens quedem amb la info de l'any a r2
		
		and r1, r0, #DATE_YEAR_SIGN_MASK  @; Apliquem máscara de despres de Crist
		cmp r1, #0  @; Mirem si hi ha bit de signe
		beq .LAnyDespresDeCrist
		
		@; Aqui tractem si es un any després de Jesús
		mov r2, r2, lsr #DATE_YEAR_LSB  @; Posem bits al lloc
		b .LFiGetYear  @; Marxem
		
		.LAnyDespresDeCrist:  @; Tractem si es després de Crist
		orr r2, r2, #DATE_YEAR_SIGN_EXT  @; Afegim els bits d'extensió
		mov r2, r2, asr #DATE_YEAR_LSB  @; Posem bits a lloc amb extensió de signe
		mvn r2, r2  @; Neguem bits (Ca1)
		add r2, #1  @; Afegim 1  (Ca2)
		
		.LFiGetYear:
		mov r0, r2  @; Tornem info a r0 per fer el retorn de la rutina
		
		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; s16 get_year_Ca2 ( fc_date data_completa ) :
@;	  Retorna el valor del camp 'any' (Ca2) de la fc_date indicada
@;  Paràmetres:
@;      R0: valor fc_date
@;	Resultat:
@;		R0: valor (Ca2) del camp 'any' de la fc_date indicada (-9999..-1, 1..9999)
		.global get_year_Ca2
get_year_Ca2:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==


		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; u8 get_month ( fc_date data_completa ) :
@;	  Retorna el valor del camp 'mes' de la fc_date indicada
@;  Paràmetres:
@;      R0: valor fc_date
@;	Resultat:
@;		R0: valor del camp 'mes' de la fc_date indicada (1..12)
		.global get_month
get_month:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==


		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; u8 get_day ( fc_date data_completa ) :
@;	  Retorna el valor del camp 'dia' de la fc_date indicada
@;  Paràmetres:
@;      R0: valor fc_date
@;	Resultat:
@;		R0: valor del camp 'dia' de la fc_date indicada (1..28/29/30/31)
		.global get_day
get_day:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==


		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar




@; =============================================================
@;   Altres rutines de dates
@; =============================================================


@; bool is_leap_year ( s16 any_Ca2 ) :
@;	  Retorna true (1) si l'any indicat és de traspàs/bixest, o 0 en cas contrari
@;  Paràmetres:
@;      R0: valor de l'any (Ca2)
@;	Resultat:
@;		R0: 1 si l'any indicat és de traspàs/bixest; 0 altrament
		.global is_leap_year
is_leap_year:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==


		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; u8 days_in_month ( u8 mes, s16 any_Ca2 ) :
@;	  Retorna el número de dies d'aquell mes (0 en cas de més o any fora de rang)
@;  Paràmetres:
@;      R0: valor del mes (rang esperat 1..12)
@;		R1: valor de l'any (Ca2, rang esperat -9999..-1 / 1..9999) 
@;	Resultat:
@;		R0: número de dies d'aquell mes (1..28/29/30/31) o 0 en cas de fora de rang
		.global days_in_month
days_in_month:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==


		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; s8 get_century_Ca2 ( s16 any_Ca2 ) :
@;	  Retorna el número de segle al qual pertany l'any indicat (0 en cas d'any fora de rang)
@;  Paràmetres:
@;		R01: valor de l'any (Ca2, rang esperat -9999..-1 / 1..9999) 
@;	Resultat:
@;		R0: segle al qual pertany l'any indicat (-100..-1 / +1..+100) o 0 en cas d'any fora de rang
		.global get_century_Ca2
get_century_Ca2:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==


		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; u8 week_day ( u8 dia, u8 mes, s16 any_Ca2 ) :
@;	  Retorna el dia de la setmana d'aquella data (1:dilluns..7:diumenge o 0 si data fora de rang)
@;  Paràmetres:
@;      R0: valor del dia (rang esperat 1..28/29/30/31)
@;      R1: valor del mes (rang esperat 1..12)
@;		R2: valor de l'any (Ca2, rang esperat -9999..-1 / 1..9999) 
@;	Resultat:
@;		R0: dia de la setmana d'aquella data (1:dilluns..7:diumenge o 0 si data fora de rang)
		.global week_day
week_day:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==


		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar




@; =============================================================
@;   Rutines per generar calendaris mensuals
@; =============================================================


@; bool create_binary_calendar ( u8 mes, s16 any_Ca2, s8 calendari[7][7] ) :
@;	  Genera el calendari del mes i any indicats sobre la matriu donada, amb valors numèrics
@;  Paràmetres:
@;      R0: valor del mes (rang esperat 1..12)
@;		R1: valor de l'any (Ca2, rang esperat -9999..-1 / 1..9999) 
@;		R2: matriu on s'ha d'escriure el calendari (pas per referència)
@;	Resultat:
@;		R0: 1 si s'ha pogut generar el calendari; 0 en cas de mes o any fora de rang
@;
@;  Format del calendari (per a març 2020): cada casella de la matriu conté valors -1..31
@;	   +--+--+--+--+--+--+--+
@;	   | 0| 3| 0| 2| 0| 2| 0|	Mes: 0 3	AC(-1)/DC(0)	Any: 2 0 2 0 (Mes i any a fila 0)
@;	   | 0  0  0  0  0  0  1|	1a setmana de Març (el mes comença diumenge, resta de dies a 0)
@;	   | 2  3  4  5  6  7  8|	2a setmana de Març, dies 2-8
@;	   | 9 10 11 12 13 14 15|	3a setmana de Març, dies 9-15
@;	   |16 17 18 19 20 21 22|	4a setmana de Març, dies 16-22
@;	   |23 24 25 26 27 28 29|	5a setmana de Març, dies 23-29
@;	   |30 31  0  0  0  0  0|	6a setmana de Març, dies 30 i 31, resta de dies amb 0
@;
		.global create_binary_calendar
create_binary_calendar:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==


		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; bool create_ascii_calendar ( u8 mes, s16 any_Ca2, u8 language, char calendari[8][20] ) :
@;    Genera el calendari del mes i any indicats, en l'idioma indicat, 
@;    sobre la matriu donada, amb caràcters ASCII.
@;  Paràmetres:
@;      R0: valor del mes (rang esperat 1..12)
@;		R1: valor de l'any (Ca2, rang esperat -9999..-1 / 1..9999) 
@;		R2: idioma ( 0: català, 1: castellano, 2: english, 3: français )
@;		R3: matriu on s'ha d'escriure el calendari (pas per referència)
@;	Resultat:
@;		R0: 1 si s'ha pogut generar el calendari; 0 en cas de mes o any fora de rang
@;
@;  Format del calendari (per a març 2020): cada casella de la matriu conté caràcters ASCII
@;	   +--------------------+
@;	   |Març 2020 DC        |	Nom del mes, any, AC/DC (a fila 0)
@;	   |dl dt dc dj dv ds du|	Inicials dels dies de la setmana (a fila 1)
@;	   |                   1|	1a setmana de Març (el mes comença diumenge, resta de dies a 0)
@;	   | 2  3  4  5  6  7  8|	2a setmana de Març, dies 2-8
@;	   | 9 10 11 12 13 14 15|	3a setmana de Març, dies 9-15
@;	   |16 17 18 19 20 21 22|	4a setmana de Març, dies 16-22
@;	   |23 24 25 26 27 28 29|	5a setmana de Març, dies 23-29
@;	   |30 31               |	6a setmana de Març, dies 30 i 31, resta de dies amb 0
@;
		.global create_ascii_calendar
create_ascii_calendar:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==


		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar



.data
	@; Strings per al calendari ASCII 

monthNames:    @; adreces dels strings amb els noms dels mesos: char *monthNames[4][12]
	.align 2
	.word Gener, Febrer, Marc, Abril, Maig, Juny, Juliol, Agost, Setembre, Octubre, Novembre, Desembre
	.word Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre
	.word January, February, March, April, May, June, July, August, September, October, November, December
	.word Janvier, Fevrier, Mars, Avril, Mai, Juin, Juillet, Aout, Septembre, Octobre, Novembre, Decembre

weekDaysNames:
	.ascii "DlDtDcDjDvDsDu"
	.ascii "LuMaMiJuViSáDo"
	.ascii "MoTuWeThFrSaSu"
	.ascii "LuMaMeJeVeSaDi"

		@; Noms individuals dels mesos
Gener:      .asciz "Gener"
Enero:      .asciz "Enero"
January:    .asciz "January"
Janvier:    .asciz "Janvier"
Febrer:     .asciz "Febrer"
Febrero:    .asciz "Febrero"
February:   .asciz "February"
Fevrier:    .asciz "Février"
Marc:       .asciz "Març"
Marzo:      .asciz "Marzo"
March:      .asciz "March"
Mars:       .asciz "Mars"
Abril:      .asciz "Abril"
April:      .asciz "April"
Avril:      .asciz "Avril"
Maig:       .asciz "Maig"
Mayo:       .asciz "Mayo"
May:        .asciz "May"
Mai:        .asciz "Mai"
Juny:       .asciz "Juny"
Junio:      .asciz "Junio"
June:       .asciz "June"
Juin:       .asciz "Juin"
Juliol:     .asciz "Juliol"
Julio:      .asciz "Julio"
July:       .asciz "July"
Juillet:    .asciz "Juillet"
Agost:      .asciz "Agost"
Agosto:     .asciz "Agosto"
August:     .asciz "August"
Aout:       .asciz "Août"
Setembre:   .asciz "Setembre"
Septiembre: .asciz "Septiembre"
September:  .asciz "September"
Septembre:  .asciz "Septembre"
Octubre:    .asciz "Octubre"
October:    .asciz "October"
Octobre:    .asciz "Octobre"
Novembre:   .asciz "Novembre"
Noviembre:  .asciz "Noviembre"
November:   .asciz "November"
Desembre:   .asciz "Desembre"
Diciembre:  .asciz "Diciembre"
December:   .asciz "December"
Decembre:   .asciz "Décembre"


.end
