/*----------------------------------------------------------------
|	Autor: Pere Millán (DEIM, URV)
|	Data:  Febrer 2020					Versió: 1.0
|-----------------------------------------------------------------|
|	Nom fitxer: FCtypes.h
|   Descripció: declaració de tipus naturals/enters de 8/16/32 bits
|               i tipus bool (true/false) per a exercicis FC/ARM.
| ----------------------------------------------------------------*/

#ifndef FCTYPES_H
#define FCTYPES_H

#include <stdbool.h>	/* bool, true, false */

#include <stdint.h>

/* Definir tipus naturals */
typedef uint8_t  u8;
typedef uint16_t u16;
typedef uint32_t u32;

/* Definir tipus enters */
typedef int8_t  s8;
typedef int16_t s16;
typedef int32_t s32;


#endif /* FCTYPES_H */

