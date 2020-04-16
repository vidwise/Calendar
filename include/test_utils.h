/*----------------------------------------------------------------
|	Autor: Pere Millán (DEIM, URV)
|	Data:  Febrer 2020					Versió: 1.0
|-----------------------------------------------------------------|
|	Nom fitxer: test_utils.h
|   Descripció: declaracions i funcions d'utilitat 
|				 per aplicar jocs de proves.
| ----------------------------------------------------------------*/

#ifndef TESTUTILS_H
#define TESTUTILS_H

#include "FCtypes.h"	/* bool, u8, u32 */


typedef bool (*functest)(void);		/* Definir el tipus de funció de prova */
	/* Si la prova ha estat correcta, retorna true */

extern void verificarJocDeProves(functest jocDeProves[], u8 num_proves, 
									u8 *num_tests_ok, u32 *quins_errors);
	/* Crida a cadascuna de les num_proves contingudes a jocDeProves */
	/* apuntant en num_tests_ok quantes proves han anat bé */
	/* i en quins_errors activa 1 bit per cada prova errònia */


#endif /* TESTUTILS_H */

