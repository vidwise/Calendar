@;----------------------------------------------------------------
@;	Autors: Santiago Romaní, Pere Millán
@;	Data:   Mar,Abr/2020       			Versió: 2.1
@;-----------------------------------------------------------------
@;	Nom fitxer: FCdivmod.s
@;  Descripcio: implementació de les rutines de divisió entera 
@;				i residu (mòdul) amb operands naturals de 32 bits.
@; ----------------------------------------------------------------

.include "FCdivmod.i"	@; Símbols DIVMOD_ERROR_XXX amb valors d'error


@;-- .text. codi de les rutinas ---
.text	
		.align 2
		.arm


@; ========================================================
@;   Rutines de divisió i residu (mòdul)
@; ========================================================

@; u8 div_mod ( u32 num, u32 den, u32 *quo, u32 *mod ) :
@; Crida en C: div_mod(num, den, &quo, &mod)
@;    Rutina per realitzar una divisió entera per a un ARM, 
@;    a partir d'operacions a nivell de bits.
@;  Paràmetres:
@;      R0: [valor natural 32 bits] num (numerador o dividend)
@;      R1: [valor natural 32 bits] den (denominador o divisor)
@;      R2: [punter/adreça a nat. 32b] quo (posició de memòria on desar el quocient)
@;      R3: [punter/adreça a nat. 32b] mod (posició de memòria on desar el residu, mòdul)
@;	Resultat:
@;	    R0: DIVMOD_ERROR_NOERROR si NO hi ha problema (càlculs correctes)
@;          Altres valors DIVMOD_ERROR_XXX si s'ha detectat algun error en la divisió
@;      R2: unsigned int * quo, (quocient de la divisió, per referència)
@;      R3: unsigned int * mod, (residu o mòdul de la divisió, per referència)
	.global div_mod
div_mod:
	push {r4-r7, lr}

	cmp r1, #0				@; verificar si s'està intentant dividir entre zero
	moveq r0, #DIVMOD_ERROR_DIVBYZERO    @; codi d'error de divisió entre 0
	beq .Ldiv_fin2
	tst r2,#3				@; verificar quo alineat a word
	movne r0, #DIVMOD_ERROR_NOTALIGN4    @; codi d'error de punter no alineat a word
	bne .Ldiv_fin2
	tst r3,#3				@; verificar mod alineat a word
	movne r0, #DIVMOD_ERROR_NOTALIGN4    @; codi d'error de punter no alineat a word
	bne .Ldiv_fin2
	cmp r2,r3				@; verificar quo!=mod
	moveq r0, #DIVMOD_ERROR_SAMEADDR     @; codi d'error d'adreça quo==mod
	beq .Ldiv_fin2
.Ldiv_ini:
	mov r4, #0				@; R4 es el cociente (q)
	mov r5, #0				@; R5 es el resto (r)
	mov r6, #31				@; R6 es índice del bucle (de 31 a 0)
	mov r7, #0xff000000
.Ldiv_for1:
	tst r0, r7				@; comprobar si hay bits activos en una zona de 8
	bne .Ldiv_for2			@; bits del numerador, para evitar rastreo bit a bit
	mov r7, r7, lsr #8
	sub r6, #8				@; 8 bits menos a buscar
	cmp r7, #0
	bne .Ldiv_for1
	b .Ldiv_fin1			@; caso especial (numerador = 0 -> q=0 y r=0)
.Ldiv_for2:
	mov r7, r0, lsr r6		@; R7 es variable de trabajo j;
	and r7, #1				@; j = bit i-ésimo del numerador; 
	mov r5, r5, lsl #1		@; r = r << 1;
	orr r5, r7				@; r = r | j;
	mov r4, r4, lsl #1		@; q = q << 1;
	cmp r5, r1
	blo .Ldiv_cont			@; si (r >= divisor), activar bit en cociente
	sub r5, r1				@; r = r - divisor;
	orr r4, #1				@; q = q | 1;
 .Ldiv_cont:
	sub r6, #1				@; decrementar índice del bucle
	cmp r6, #0
	bge .Ldiv_for2			@; bucle for-2, mientras i >= 0
.Ldiv_fin1:
	str r4, [r2]
	str r5, [r3]			@; guardar resultados en memoria (por referencia)
	mov r0, #DIVMOD_ERROR_NOERROR    @; código de OK
.Ldiv_fin2:

	pop {r4-r7, pc}


@; -------------------------------------------------------- 


@; u32 FCdiv ( u32 num, u32 den ) :
@; Crida en C: quo = FCdiv ( num, den )
@;    Rutina per calcular el quocient d'una divisió entera per a un ARM, 
@;    a partir d'operacions a nivell de bits (crida a div_mod).
@;  Paràmetres:
@;      R0: [valor natural 32 bits] num (numerador o dividend)
@;      R1: [valor natural 32 bits] den (denominador o divisor)
@;	Resultat:
@;	    R0: num / den si NO hi ha problema (càlculs correctes)
@;          DIVMOD_RESULT_ERROR si s'ha detectat algun error en la divisió
	.global FCdiv
FCdiv:
	push {r2-r3, lr}

	sub sp, #8				@ crear espai per a vars. locals quo i mod (pas per referència)

	mov r2, sp				@; r2: @quo (sp)
	add r3, sp, #4			@; r3: @mod (sp+4)

	bl div_mod				@; [sp] quo = num (r0) / den (r1)

							@; si hi ha error a div_mod, retornar error
	cmp r0, #DIVMOD_ERROR_NOERROR
	movne r0, #DIVMOD_RESULT_ERROR

	ldreq r0, [sp]			@; sinó, retornar quocient ( desat per div_mod a [sp] )

	add sp, #8				@ eliminar espai de vars. locals quo i mod

	pop {r2-r3, pc}


@; -------------------------------------------------------- 


@; u32 FCmod ( u32 num, u32 den ) :
@; Crida en C: mod = FCdiv ( num, den )
@;    Rutina per calcular el residu (mòdul) d'una divisió entera per a un ARM, 
@;    a partir d'operacions a nivell de bits (crida a div_mod).
@;  Paràmetres:
@;      R0: [valor natural 32 bits] num (numerador o dividend)
@;      R1: [valor natural 32 bits] den (denominador o divisor)
@;	Resultat:
@;	    R0: num % den si NO hi ha problema (càlculs correctes)
@;          DIVMOD_RESULT_ERROR si s'ha detectat algun error en la divisió
	.global FCmod
FCmod:
	push {r2-r3, lr}

	sub sp, #8				@ crear espai per a vars. locals quo i mod (pas per referència)

	mov r2, sp				@; r2: @quo (sp)
	add r3, sp, #4			@; r3: @mod (sp+4)

	bl div_mod				@; [sp+4] mod = num (r0) / den (r1)

							@; si hi ha error a div_mod, retornar error

	cmp r0, #DIVMOD_ERROR_NOERROR
	movne r0, #DIVMOD_RESULT_ERROR

	ldreq r0, [sp, #4]		@; sinó, retornar quocient ( desat per div_mod a [sp+4] )

	add sp, #8				@ eliminar espai de vars. locals quo i mod

	pop {r2-r3, pc}


@; ========================================================


.end
