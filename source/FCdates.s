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
	quo: .word 0
	mod: .word 0
	


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
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==

		push {r1-r4, lr}	@; guardar a pila possibles registres modificats 

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
		cmp r0, #0
		negeq r1, r1  @; Si es 0 es abans de Crist per tant fem el Ca2 del valor
		
		@; Malabar de registres per a cridar a la funció days in month
		mov r0, r2  @; Aquí ja no necessitem la dada de abans de Crist a r0
		@; A r1 ja hi tenim ben colocat l'any en Ca2
		bl days_in_month  @; r0 = dies_mes
		cmp r0, r3  @; Mirem que els dies no se surtin de rang
		movgt r0, r3  @; Si els dies passats per parametre son menors, ens quedem amb el parametre
		
		@; Combinem les dades en un sol registre
		@; Coloquem dia
		mov r0, r0, lsl #DATE_DAY_LSB  
		
		@; Coloquem any
		mov r1, r1, lsl #DATE_YEAR_LSB
		ldr r3, =DATE_YEAR_MASK  @; Carreguem constant (limitació ARM)
		and r1, r1, r3  @; Matem els bits degut al Ca2
		orr r0, r0, r1  @; Coloquem els bits de l'any al registre
		
		@; Coloquem mes
		mov r2, r2, lsl #DATE_MONTH_LSB
		orr r0, r0, r2  @; Coloquem els bits del mes al registre
				
		pop {r1-r4, pc}	@; recuperar de pila registres modificats i retornar

		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==




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
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==

		push {r1, lr}	@; guardar a pila possibles registres modificats 

		and r1, r0, #DATE_YEAR_SIGN_MASK  @; Apliquem máscara de "signe"
		cmp r1, #0  @; Veiem si queda un 0 o no
		moveq r0, #1  @; Si queda 0 no hi ha signe per tant després de Crist
		movne r0, #0  @; Sino pues 1 perque si que és després de Crist
		
		pop {r1, pc}	@; recuperar de pila registres modificats i retornar

		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==



@; -------------------------------------------------------- 


@; u16 get_year_magnitude ( fc_date data_completa ) :
@;	  Retorna el valor absolut (magnitud) del camp 'any' de la fc_date indicada
@;  Paràmetres:
@;      R0: valor fc_date
@;	Resultat:
@;		R0: valor absolut (magnitud) del camp 'any' de la fc_date indicada (1..9999)
		.global get_year_magnitude
get_year_magnitude:		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		push {r1-r3, lr}	@; guardar a pila possibles registres modificats 
		
		ldr r3, =DATE_YEAR_MASK  @; Carreguem constant (limitació ARM)
		and r2, r0, r3  @; Ens quedem amb la info de l'any a r2
		
		and r1, r0, #DATE_YEAR_SIGN_MASK  @; Apliquem máscara de despres de Crist
		cmp r1, #0  @; Mirem si es 0 (si es 0 es després de crist)
		beq .LAnyDespresDeCrist
		
		@; Aqui tractem si es un any després de Jesús
		orr r2, r2, #DATE_YEAR_SIGN_EXT  @; Afegim els bits d'extensió
		mov r2, r2, asr #DATE_YEAR_LSB  @; Posem bits a lloc amb extensió de signe
		neg r2, r2  @; Ca2
		b .LFiGetYear  @; Marxem
		
		.LAnyDespresDeCrist:  @; Tractem si es després de Crist
		mov r2, r2, lsr #DATE_YEAR_LSB  @; Posem bits al lloc

		.LFiGetYear:
		mov r0, r2  @; Tornem info a r0 per fer el retorn de la rutina

		pop {r1-r3, pc}	@; recuperar de pila registres modificats i retornar

		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==


@; -------------------------------------------------------- 


@; s16 get_year_Ca2 ( fc_date data_completa ) :
@;	  Retorna el valor del camp 'any' (Ca2) de la fc_date indicada
@;  Paràmetres:
@;      R0: valor fc_date
@;	Resultat:
@;		R0: valor (Ca2) del camp 'any' de la fc_date indicada (-9999..-1, 1..9999)
		.global get_year_Ca2
get_year_Ca2:
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		push {r1-r2, lr}	@; guardar a pila possibles registres modificats 

		ldr r2, =DATE_YEAR_MASK  @; Carreguem constant (limitació ARM)
		and r1, r0, r2  @; Ens quedem amb el camp year a r1
		and r2, r1, #DATE_YEAR_SIGN_MASK  @; Ens quedem amb el signe 
		cmp r2, #0  @; Mirem si no te signe
		beq .LGetYearDespresDeCrist  
		
		@; Aqui tractem si té signe i per tant es un any abans de Crist
		orr r1, r1, #DATE_YEAR_SIGN_EXT  @; Afegim els bits d'extensió
		mov r1, r1, asr #DATE_YEAR_LSB  @; Posem bits a lloc amb extensió de signe
		b .LFiGetYearCa2  @; Anem al final de la funció

		.LGetYearDespresDeCrist:
		mov r1, r1, lsr #DATE_YEAR_LSB  @; Movem al lloc
		
		.LFiGetYearCa2:
		@;ldr r2, =0x0000FFFF  @; Carreguem constant (limitació ARM)
		@; and r1, r1, r2  @; Forcem retornar un half-word
		mov r0, r1  @; Per a fer el retorn de la funció
		
		pop {r1-r2, pc}	@; recuperar de pila registres modificats i retornar
				
		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==



@; -------------------------------------------------------- 


@; u8 get_month ( fc_date data_completa ) :
@;	  Retorna el valor del camp 'mes' de la fc_date indicada
@;  Paràmetres:
@;      R0: valor fc_date
@;	Resultat:
@;		R0: valor del camp 'mes' de la fc_date indicada (1..12)
		.global get_month
get_month:		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		push {lr}	@; guardar a pila possibles registres modificats 

		and r0, r0, #DATE_MONTH_MASK
		mov r0, r0, lsr #DATE_MONTH_LSB
		
		pop {pc}	@; recuperar de pila registres modificats i retornar

		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==



@; -------------------------------------------------------- 


@; u8 get_day ( fc_date data_completa ) :
@;	  Retorna el valor del camp 'dia' de la fc_date indicada
@;  Paràmetres:
@;      R0: valor fc_date
@;	Resultat:
@;		R0: valor del camp 'dia' de la fc_date indicada (1..28/29/30/31)
		.global get_day
get_day:
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		push {lr}	@; guardar a pila possibles registres modificats 

		and r0, r0, #DATE_DAY_MASK
		mov r0, r0, lsr #DATE_DAY_LSB

		pop {pc}	@; recuperar de pila registres modificats i retornar

		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==





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
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		push {r1-r5, lr}	@; guardar a pila possibles registres modificats 

		mov r3, r0  @; Movem al registre r3 per comoditat
		cmp r3, #-46  @; Comparem amb -46
		movlt r0, #0  @; No es any bixest
		blt .LFiIsLeapYear  @; Fi funció
		
		@;Aquí continuem si es major o igual que -46
		and r2, r3, #0b11  @; Si r2 = 0, any multiple de 4
		cmp r2, #0  @; Mirem si es 0
		moveq r2, #1  @; Si es 0 fiquem true
		movne r2, #0  @; Sino pues fiquem false
		ldr r4, =1582  @; Carreguem constant (limiació ARM)
		cmp r3, r4  @; comparem amb 1582
		movle r0, r2  @; Si any menor o igual a 1582 carreguem a r0 si es multiple de 4 o no
		ble .LFiIsLeapYear  @; I retornem
		
		@; Aquí continuem si l'any es major que 1582
		@; Malabars de registres per a cridar a la funció per fer any % 100
		mov r0, r3  @; Carreguem any a r0 (primer argument)
		mov r1, #100  @; carreguem quocient a r1 (segon argument)
		bl FCmod  @; r0 = any % 100
		cmp r0, #0
		moveq r4, #1  @; Si es igual llavors es múltiple de 100 (true)
		movne r4, #0  @; Si es diferent llavors posem a false
		
		@; Malabars de registres per a cridar a la funció per fer any % 400
		mov r0, r3  @; Carreguem any a r0 (primer argument)
		mov r1, #400  @; carreguem quocient a r1 (segon argument)
		bl FCmod  @; r0 = any % 400
		cmp r0, #0
		moveq r5, #1  @; Si es igual llavors es múltiple de 400 (true)
		movne r5, #0  @; Si es diferent llavors ho posem a false
		
		@; r2: Multiplicitat amb 4
		@; r4: Multiplicitat amb 100
		@; r5: Multiplicitat amb 400
		
		mvn r4, r4  @; neguem multiplicitat amb 100
		and r0, r2, r4  @; Fem la and. Se'ns maten tots els 1 useless que em creat a l'anterior instrucció
		orr r0, r0, r5  @; Resultat final
		
		.LFiIsLeapYear:
		
		pop {r1-r5, pc}	@; recuperar de pila registres modificats i retornar
		
		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==



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
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		push {r1-r3, lr}	@; guardar a pila possibles registres modificats 

		mov r2, r0  @; Guardem mes a un altre lloc per comoditat
		mov r0, #0  @; resultat incorrecte fins que no es demostri el contrari
		
		@; Any
		ldr r3, =-9999  @; Carreguem constant (limitació de ARM)
		cmp r1, r3
		blt .LFiDaysInMonth  @; Fi funció
		
		ldr r3, =9999  @; Carreguem constant (limitació de ARM)
		cmp r1, r3  
		bgt .LFiDaysInMonth  @; Fi funció
		
		cmp r1, #0
		beq .LFiDaysInMonth  @; Fi funció
		
		@; Mes
		cmp r2, #1  
		blt .LFiDaysInMonth  @; Fi funció
		
		cmp r2, #12
		bhi .LFiDaysInMonth  @; Fi funció
		
		@; En aquest punt els arguments son valids i estem al else
		sub r2, #1  @; Resta 1 a mes per a poder indexar amb ell a l'array
		ldr r3, =diesPerMes  @; Carreguem @ del array diesPerMes
		add r3, r2  @; Desplacem el punter fins la posicio que ens interessa
		ldrb r0, [r3]  @; Carreguem un byte a r0 corresponent als dies d'aquell mes
		cmp r2, #1  @; Mirem si es febrer. Hem restat 1, per aixo mirem amb 1
		bne .LFiDaysInMonth  @; Si no ho es hem acabat
		
		@; Aqui tenim el suposit que es Febrer
		@; Fem malabars per cridar a la funció
		mov r3, r0  @; Guardem dies del mes (en aquest punt sera 28) a r3
		mov r0, r1  @; Carreguem any per a passarli a la funció
		bl is_leap_year  @; Cridem a la funció per saber si es bixest o no
		add r0, r0, r3  @; Sumem el resultat i jasta... estalviem diverses instruccions
		
		.LFiDaysInMonth:
		
		pop {r1-r3, pc}	@; recuperar de pila registres modificats i retornar
		
		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==



@; -------------------------------------------------------- 


@; s8 get_century_Ca2 ( s16 any_Ca2 ) :
@;	  Retorna el número de segle al qual pertany l'any indicat (0 en cas d'any fora de rang)
@;  Paràmetres:
@;		R0: valor de l'any (Ca2, rang esperat -9999..-1 / 1..9999) 
@;	Resultat:
@;		R0: segle al qual pertany l'any indicat (-100..-1 / +1..+100) o 0 en cas d'any fora de rang
		.global get_century_Ca2
get_century_Ca2:		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		push {r1-r2, lr}	@; guardar a pila possibles registres modificats 

		mov r1, r0  @; Movem any a r1 per comoditat
		mov r0, #0  @; Parametres incorrectes fins que no es demostri el contrari
		
		@; Any
		ldr r2, =-9999  @; Carreguem constant (limitació de ARM)
		cmp r1, r2
		blt .LFiGetCentury  @; Fi funció
		
		ldr r2, =9999  @; Carreguem constant (limitació de ARM)
		cmp r1, r2  
		bgt .LFiGetCentury  @; Fi funció
		
		cmp r1, #0
		beq .LFiGetCentury  @; Fi funció
		
		@; A partir d'aqui estem amb paràmetres correctes
		
		cmp r1, #0  
		neglt r1, r1  @; Si es un negatiu el convertim a positiu
		movlt r2, #-1  @; Carreguem un -1 per a després
		movgt r2, #1  @; Carreguem un 1 per a després
		
		@; Malabars de registres per cridar a la divisió
		mov r0, r1  @; Carreguem any
		sub r0, #1  @; Restem un 1
		mov r1, #100  @; Carreguem quocient
		bl FCdiv  @; A r0 tenim el resultat de la divisió
		add r0, #1  @; Sumem 1 per corregir
		mov r1, r0  @; Carreguem a un altre registre per a mul (limitació ARM)
		mul r0, r1, r2  @; Multipliquem segons el que hagim carregat a r2 previament
		
		.LFiGetCentury:

		pop {r1-r2, pc}	@; recuperar de pila registres modificats i retornar

		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==



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
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==

		push {r1-r4, r12, lr}	@; Cridem a una funció C (r1-r4, r12)
		@; Malabars de registres per a cridar a la funció
		mov r3, r0  @; r3 --> dies
		mov r4, r1  @; r4 --> mes (necessitem guardar-ho perque sino ho perdrem)
		mov r0, r1  @; Per a cridar la func
		mov r1, r2  @; Per a cridar la func. r2 --> any (no el matxacarem)
		bl days_in_month  @; r0 --> days in month
		mov r1, r0  @; r1 --> days in month
		
		@; Checkegem parámetres
		mov r0, #0  @; Els parametres son incorrectes fins que no es demostri el contrari
		
		cmp r1, #0  @; Comparem retorn amb 0 (codi error)
		beq .LFiWeekDay
		
		cmp r3, #1  @; Comparem dies per si son menors de 1
		blt .LFiWeekDay  @; Si ho són marxem de la funció
		
		cmp r3, r1  @; Mirem si els dies proporcionats estan fora de rang
		bgt .LFiWeekDay  
		
		@; Aquí els paràmetres son correctes
		@; Malabars de registres per a cridar a la funcio de divisio
		mov r0, r3  @; Carreguem primer dies
		mov r1, r4  @; Carreguem segon mes
		@; a r2 ja hi tenim l'any ben colocat
		bl julian_day  @; r0 = numero de dies passats des del calendari julià
		mov r1, #7  @; Carreguem un 7 de quocient
		bl FCmod  @; r0 modul amb 7
		add r0, #1  @; Corregim sumant 1 per a que 1 --> dilluns ... 7 --> diumenge
		
		.LFiWeekDay:
		
		pop {r1-r4, r12, pc}	@; Cridem a una funció C (r1-r4, r12)


		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==





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
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 

		mov r4, r0  @; Guardem mes a un altre lloc per comoditat. r4 = mes
		mov r0, #0  @; resultat incorrecte fins que no es demostri el contrari
		
		@; Any
		ldr r5, =-9999  @; Carreguem constant (limitació de ARM)
		cmp r1, r5
		blt .LFiCreateCalendar  @; Fi funció
		
		ldr r5, =9999  @; Carreguem constant (limitació de ARM)
		cmp r1, r5  
		bgt .LFiCreateCalendar  @; Fi funció
		
		cmp r1, #0
		beq .LFiCreateCalendar  @; Fi funció
		
		@; Mes
		cmp r4, #1  
		blt .LFiCreateCalendar  @; Fi funció
		
		cmp r4, #12
		bhi .LFiCreateCalendar  @; Fi funció

		@; A partir d'aqui els parametres son correctes
		
		@; Trobem el nombre de dies del mes
		mov r0, r4  @; recarreguem mes a r0
		bl days_in_month  @; r0 = nombre de dies que té aquell mes en concret
		mov r8, r0  @; r8 = days in month
		
		@; Trobem el dia de la setmana inicial
		@; malabars de registres
		mov r0, #1  @; Carreguem dia 1
		mov r5, r1  @; per comoditat r5 = any
		mov r6, r2  @; per comoditat r6 = @array
		mov r1, r4  @; recuperem mes com a segon argument
		mov r2, r5  @; recuperem any com a tercer argument
		bl week_day  @; r0 = [1-7] depenent del dia de la setmana inicial
		mov r7, r0  @; r7 = dia de la setmana
		
		@; Generacio de la primera fila
		
		@; Mes
		@; malabars de registres per a cridar a divmod
		mov r0, r4  @; recarreguem mes
		mov r1, #10  @; carreguem mes
		ldr r2, =quo  @; carreguem punter de quocient
		ldr r3, =mod  @; carreguem punter de modul
		bl div_mod  @; r0 es plena de brossa inutil
		
		ldr r0, [r2]  @; Carreguem quocient
		strb r0, [r6]  @; Guardem quocient a la primera pos
		add r6, #1  @; incrementem apuntador
		ldr r0, [r3]  @; carreguem modul
		strb r0, [r6]  @; guardem modul a la segona posicio
		add r6, #1  @; incrementem a la seguent posicio 
		
		@; any
		@; malabars de registres per cridar a u32toString
		@; void u32toString ( u32 number, char string[11], bool ascii )
		mov r0, r5  @; carreguem el nombre
		mov r1, r6  @; carreguem la direccio de l'array
		mov r2, #0  @; Li diem que no volem ascii
		mov r3, #4  @; Hard-codegem que esperem 4 xifres
		cmp r0, #0  @; Si es un negatiu
		blt .LNegatiu  @; cridem la funció directament
		@; Sino (si es positiu)
		strb r2, [r1]  @; Carreguem un 0 a la pos on estaria el signe
		add r1, #1  @; Desplacem una posicio l'array per escriure mes endavant
		.LNegatiu:
		bl u32toString  @; registres inalterats
		add r6, #5  @; Desplacem 5 posicions corresponents a l'any
		
		@; Primera setmana (zeros)
		mov r0, #0  @; Carreguem un 0 per anar plenant
		mov r1, #0  @; r1 = i = 0
		.LBucleZerosSetmana:  @; Sempre fem una iteracio de mes pero tranki que despres machaquem
		strb r0, [r6, r1]  @; guardem un 0 a array[i]
		add r1, #1  @; desplacem l'index 1 pos
		
		cmp r1, r7  @; Comparem amb el dia inicial
		bne .LBucleZerosSetmana   @; Si no es igual seguim iterant
		
		@; Dies del mes
		sub r7, #1  @; Corregim una posicio per a indexar amb ella
		add r6, r7  @; Anem a la pos on hem de començar a escriure els dies
		
		mov r0, #0  @; dia del mes i index
		.LBucleDies:
		add r0, #1  @; Incrementem 1 el dia
		strb r0, [r6]  @; Escribim al calendari
		add r6, #1  @; Incrementem l'apuntador
		cmp r0, r8  @; comparem amb el nombre de dies
		bne .LBucleDies  @; Fins que no haguem escrit l'últim dia no sortim
		
		@; Aqui ja hem escrit tot el calendari. Ara cal saber quants 0 de final cal posar
		add r0, r7, r8  @; Sumem total de dies escrits
		rsb r1, r0, #42  @; restem del total de dies
		
		@; Inicialitzacions
		mov r0, #0  @; Movem a r0 un 0
		@; A r1 hi tenim lindex que es el nombre de dies
		.LBucleZerosFinal:
		strb r0, [r6]  @; Guardem un 0
		sub r1, #1  @; Decrementem 
		add r6, #1
		cmp r1, #0  @; comparem amb 0
		bne .LBucleZerosFinal
		
		mov r0, #1  @; Hem pogut generar el calendari
		
		.LFiCreateCalendar:
		
		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar

		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==


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
		
		mov r4, r0  @; Guardem mes a un altre lloc per comoditat. r4 = mes
		mov r9, r3  @; r9 = Idioma
		mov r0, #0  @; resultat incorrecte fins que no es demostri el contrari
		
		@; Any
		ldr r5, =-9999  @; Carreguem constant (limitació de ARM)
		cmp r1, r5
		blt .LFiCreateCalendarASCII  @; Fi funció
		
		ldr r5, =9999  @; Carreguem constant (limitació de ARM)
		cmp r1, r5  
		bgt .LFiCreateCalendarASCII  @; Fi funció
		
		cmp r1, #0
		beq .LFiCreateCalendarASCII  @; Fi funció
		
		@; Mes
		cmp r4, #1  
		blt .LFiCreateCalendarASCII  @; Fi funció
		
		cmp r4, #12
		bhi .LFiCreateCalendarASCII  @; Fi funció

		@; A partir d'aqui els parametres son correctes
		
		@; Trobem el nombre de dies del mes
		mov r0, r4  @; recarreguem mes a r0
		bl days_in_month  @; r0 = nombre de dies que té aquell mes en concret
		mov r8, r0  @; r8 = days in month
		
		@; Trobem el dia de la setmana inicial
		@; malabars de registres
		mov r0, #1  @; Carreguem dia 1
		mov r5, r1  @; per comoditat r5 = any
		mov r6, r3  @; per comoditat r6 = @array
		mov r1, r4  @; recuperem mes com a segon argument
		mov r2, r5  @; recuperem any com a tercer argument
		bl week_day  @; r0 = [1-7] depenent del dia de la setmana inicial
		mov r7, r0  @; r7 = dia de la setmana

		@; REGISTRES
		@; r4 --> mes
		@; r5 --> any
		@; r6 --> @array del calendari
		@; r7 --> dia inicial de la setmana
		@; r8 --> days in month
		@; r9 --> idioma
		
		@; Plenem tot despais
		mov r0, #0  @; index
		mov r1, #32  @; espai
		
		.LBucleEspais:
		strb r1, [r6, r0]  @; Anem guardant espais al calendari
		add r0, #1  @; incrementem index
		
		cmp r0, #160  @; Mirem si estem fora del calendari
		bne .LBucleEspais  @; Sino tornem a començar
		
		@; Generacio de la primera fila
		
		ldr r0, =monthNames  @; Punter a punters 
		mov r2, #48  @; 12 punters, de 4 bytes cadascun (limitació mul)
		mul r1, r9, r2  @; Generem index a l'array de punters de l'idioma que toca
		add r0, r1  @; Anem fins al principi de l'array que correspongui segons idioma
		sub r2, r4, #1  @; Restem 1 per indexar a l'array
		mov r2, r2, lsl #2  @; Multipliquem per 4 perque son punters de 4 bytes
		add r0, r2  @; Punter de punters del mes adequat en lidioma adequat
		ldr r0, [r0]  @; Punter a l'array de caracters
		mov r1, r0  @; Malabar de registres per cridar a str_length
		bl str_length  @; r0 nombre de caracters a copiar
		
		mov r2, r0  @; Coloquem el nombre de caracters a copiar
		mov r0, r1  @; Coloquem punter al string del nom del mes
		mov r1, r6  @; Coloquem el punter al calendari
		bl mem_copy  @; Copiem nom
		add r6, r2  @; movem el punter la longitud de caracters que haguem copiar
		
		.LFiCreateCalendarASCII:

		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar

@; =============================================================
@;   Rutines auxiliars
@; =============================================================

@; void u32toString ( u32 number, char string[11], bool ascii, uint numxifres)
@;     Converteix un nombre a String i el copia a la direcció rebuda per parametre
@;     Yo me lo guiso yo me lo como --> la faig hardcoded com a mi em dona la gana
@;     Limitacions i característiques:
@;     - No fico caracters de final de string perque van directes al calendari
@;     - No retorno longitud de caracters generats
@;     - Si ascii = True ho fa pel format en ascii
@;     - sino ho fa per a nombres int
@;
		.global u32toString
u32toString:
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		push {r0-r9, lr}	@; guardar a pila possibles registres modificats 
		
		@; Inicialitzacions
		mov r8, r3  @; Movem el nombre de xifres a r8 per comoditat
		mov r7, r2  @; Movem el parametre boolea ascii per comoditat a r7
		mov r4, r1  @; Movem el punter a r4 per comoditat
		mov r5, #0  @; Num caracters copiats
		mov r1, #10  @; Carreguem el divisor
		ldr r2, =quo  @; Carreguem @ quocient
		ldr r3, =mod  @; Carreguem @ residu
		
		@; Coloquem el negatiu i així ja ens oblidem
		mov r6, #-1  @; Carreguem -1 
		strb r6, [r4]  @; Fiquem el -1. No passa res perque machacarem si no es el cas
		
		cmp r7, #0  @; Comparem per veure si ascii
		cmpne r0, #0  @; Si es mode ASCII comparem el nombre
		neglt r0, r0  @; Neguem el nombre si es mes petit que 0. Aquesta instruccio es podria executar en plan troll pero en principi ens passen boolea. 
		
		cmp r7, #0  @; Tornem a actualitzar els flags
		bne .LSeguentXifra  
		@; Aqui estem en mode binari
		
		cmp r0, #0
		addlt r4, #1  @; Movem l'apuntador d'array una posicio per no machacar si realment es negatiu
		neglt r0, r0
		
		.LSeguentXifra:
		
		bl div_mod  @; r0 = Brossa que no farem servir
		ldr r0, [r2]  @; Regenerem el dividend que sera un ordre de magnitud menys a l'anterior operació
		ldr r6, [r3]  @; Carreguem el mòdul a r6
		
		cmp r7, #0  @; Comparem amb 0 el parametre ascii
		addne r6, #48  @; Si es true convertim a ASCII
		
		strb r6, [r4, r5]  @; Guardem caracter a la pos de l'array
		add r5, #1  @; Incrementem en 1 el nombre de caràcters copiats
		cmp r0, #0  @; Mirem si encara queden xifres per processar
		bhi .LSeguentXifra
		
		@; En aquest punt del codi el nombre ja esta processat i les xifres estan invertides.
		@; L'apuntador apunta per una posicio fora de l'array
		
		@; Inicialitzacions
		mov r6, r5, lsr #1  @; Dividim entre dos r5 = mida, r6 = mida / 2
		mov r1, #0  @; r1 = i = 0
		
		.LBucleInversio:
		ldrb r0, [r4, r1]  @; Carreguem digit actual
		@; Generem índex
		sub r2, r5, r1
		sub r2, #1  @; r2 = mida - i - 1
		
		ldrb r3, [r4, r2]  @; Carreguem de array[mida - i - 1]
		strb r3, [r4, r1]  @; Guardem a array[i]
		strb r0, [r4, r2]  @; Guardem digit a array[mida - i - 1]
		
		add r1, #1  @; Incrementem i. i++
		
		cmp r1, r6
		bne .LBucleInversio  @; En principi sortim del bucle quan siguin iguals
		
		cmp r7, #1  @; Mirem Si estem en mode ASCII
		beq .LFitoString  @; Si es aixi marxem perque no em de fer res mes
		
		cmp r8, r5  @; Comparem les xifres esperades amb les escrites
		beq .LFitoString
		
		@; Aqui el nombre de xifres copiades es diferent de les que s'han de plenar
		sub r3, r8, r5  @; Guardem diferencia a r3
		mov r0, r4  @; Movem punter a r0
		add r1, r0, r3  @; Movem el punter el que indiqui la dif
		mov r2, r5  @; Indiquem els caracters a copiar
		bl mem_copy  @; Copiem aquella zona de memoria
		
		@; I ara plenem de 0s
		@; Inicialitzacions
		mov r1, #0  @; 0 d'escriptura
		sub r3, #1  @; restem una pos per a indexar
		
		.LBucleZerosDesplasament:
		strb r1, [r0, r3]  @; fiquem un 0
		sub r3, #1  @; restem 1
		cmp r3, #-1  @; Mirem si ja estem fora del array
		bne .LBucleZerosDesplasament
		
		.LFitoString:
		
		pop {r0-r9, pc}	@; recuperar de pila registres modificats i retornar

		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==


@; void mem_copy (u8 *from, u8 *to, u32 count)
@;     Copia "count" bytes de "from" cap a "to" 
@;
		.global mem_copy
mem_copy:
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		push {r0-r3, lr}	@; guardar a pila possibles registres modificats 
		
		.LBucleMemCopy:
		sub r2, #1
		ldrb r3, [r0, r2]
		strb r3, [r1, r2]
		
		cmp r2, #0
		bne .LBucleMemCopy
		
		
		pop {r0-r3, pc}	@; recuperar de pila registres modificats i retornar

		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==


@; u32 str_length (char *string)
@;     Retorna el número de caràcters de "string" 
@; 
		.global str_length
str_length:
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		push {r0-r2, lr}	@; guardar a pila possibles registres modificats 
		
		mov r1, #-1  @; longitud
		.LBucleStrLength:
		add r1, #1  @; Incrementem en 1 la longitud
		ldrb r2, [r0, r1]
		cmp r2, #0
		bne .LBucleStrLength
		
		mov r0, r1  @; fem el retorn
		
		pop {r0-r2, pc}	@; recuperar de pila registres modificats i retornar

		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==


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
