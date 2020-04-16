@;----------------------------------------------------------------
@;	Autor: Pere Millán (DEIM, URV)
@;	Data:  Març 2020					Versió: 1.0
@;-----------------------------------------------------------------
@;	Nom fitxer: FCdivmod.i
@;	Descripció: declaració de possibles codis d'error 
@;				retornats per les rutines de divisió entera
@;			    i residu (mòdul) amb operands naturals de 32 bits.
@; ----------------------------------------------------------------


	@; rutina completa de divisió: calcula quocient i residu (mòdul) 
	@; u8 div_mod ( u32 num, u32 den, u32 *quo, u32 *mod );
	@;		*quo = num / den	Quocient
	@;		*mod = num % den 	Residu, mòdul
	@;		Retorna possibles errors DIVMOD_ERROR_XXXX

@;		Possibles errors retornats per div_mod
DIVMOD_ERROR_NOERROR   = 0	@; No s'ha detectat cap error, resultats Ok 
DIVMOD_ERROR_DIVBYZERO = 1	@; S'ha intentat dividir entre 0 
DIVMOD_ERROR_NOTALIGN4 = 2	@; quo o den no estan alineats a adreça múltiple de 4 
DIVMOD_ERROR_SAMEADDR  = 3	@; quo i den apunten a la mateixa adreça 


	@; rutines per obtenir només quocient o residu (mòdul). Criden a div_mod 
	@; u32 FCdiv ( u32 num, u32 den );	Retorna num / den o DIVMOD_RESULT_ERROR en cas d'error 
	@; u32 FCmod ( u32 num, u32 den );	Retorna num % den o DIVMOD_RESULT_ERROR en cas d'error 

@;		Possible resultat erroni de FCdiv o FCmod 
DIVMOD_RESULT_ERROR = 0xFF000000

