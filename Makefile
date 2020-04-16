#-------------------------------------------------------------------------------
# Example Makefile to assembly, link and debug ARM source code (and C code)
# Author: Santiago Romaní, Pere Millán
# Date: February 2016, May 2017, March 2019, February/March 2020
# Licence: Public Domain
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# options for code generation
#-------------------------------------------------------------------------------
ASFLAGS	:= -march=armv5te -mlittle-endian -g -I./include
LDFLAGS := -z max-page-size=0x8000 

ARCH	:=	-march=armv5te -mlittle-endian
CFLAGS	:=	-Wall -gdwarf-3 -O2 $(ARCH) -fomit-frame-pointer -ffast-math -c \
			-I./include 


#-------------------------------------------------------------------------------
# make commands
#-------------------------------------------------------------------------------

dates.elf : build/dates.o build/startup.o build/jocproves_d.o lib/ruts_lib.a
	arm-none-eabi-ld $(LDFLAGS) build/dates.o build/startup.o build/jocproves_d.o lib/ruts_lib.a -o dates.elf

build/dates.o : source/FCdates.s include/FCdates.h
	arm-none-eabi-as $(ASFLAGS) source/FCdates.s -o build/dates.o

build/startup.o : source/startup.s
	arm-none-eabi-as $(ASFLAGS) source/startup.s -o build/startup.o


build/jocproves_d.o : test/jocproves_d.c include/FCdates.h include/test_utils.h
	arm-none-eabi-gcc $(CFLAGS) test/jocproves_d.c -o build/jocproves_d.o


# Llibreria amb rutines:
lib/ruts_lib.a : lib/test_utils.o lib/FCdivmod.o lib/julianday.o lib/memcpy.o
	arm-none-eabi-ar -rs lib/ruts_lib.a lib/test_utils.o lib/FCdivmod.o lib/julianday.o lib/memcpy.o

lib/test_utils.o : lib/libsource/test_utils.c
	arm-none-eabi-gcc $(CFLAGS) lib/libsource/test_utils.c -o lib/test_utils.o

lib/FCdivmod.o : lib/libsource/FCdivmod.s include/FCdivmod.i
	arm-none-eabi-as $(ASFLAGS) lib/libsource/FCdivmod.s -o lib/FCdivmod.o

lib/julianday.o : lib/libsource/julianday.c
	arm-none-eabi-gcc $(CFLAGS) lib/libsource/julianday.c -o lib/julianday.o

lib/memcpy.o : lib/libsource/memcpy.s
	arm-none-eabi-as $(ASFLAGS) lib/libsource/memcpy.s -o lib/memcpy.o


build/jocproves_divmod.o : lib/libsource/jocproves_divmod.c include/FCdivmod.h include/test_utils.h
	arm-none-eabi-gcc $(CFLAGS) lib/libsource/jocproves_divmod.c -o build/jocproves_divmod.o

jocproves_divmod.elf : build/startup.o build/jocproves_divmod.o lib/ruts_lib.a
	arm-none-eabi-ld $(LDFLAGS) build/startup.o build/jocproves_divmod.o lib/ruts_lib.a -o jocproves_divmod.elf




# Versió amb el codi de les rutines en C:
demoC: datesC.elf

datesC.elf : build/datesC.o build/startup.o build/jocproves_d.o lib/ruts_lib.a
	arm-none-eabi-ld $(LDFLAGS) build/datesC.o build/startup.o build/jocproves_d.o lib/ruts_lib.a -o datesC.elf

build/datesC.o : source/demoC/FCdatesC.c include/FCdates.h
	arm-none-eabi-gcc $(CFLAGS) source/demoC/FCdatesC.c -o build/datesC.o


#-------------------------------------------------------------------------------
# clean commands
#-------------------------------------------------------------------------------
clean : 
	@rm -fv build/startup.o
	@rm -fv build/dates.o
	@rm -fv build/jocproves_d.o
	@rm -fv dates.elf
	@rm -fv build/datesC.o
	@rm -fv datesC.elf
	@rm -fv lib/test_utils.o
	@rm -fv lib/FCdivmod.o
	@rm -fv lib/julianday.o
	@rm -fv lib/memcpy.o
	@rm -fv jocproves_divmod.elf


#-------------------------------------------------------------------------------
# debug commands
#-------------------------------------------------------------------------------
debug : dates.elf
	arm-eabi-insight dates.elf &

debugC : datesC.elf
	arm-eabi-insight datesC.elf &

debugDivmod : jocproves_divmod.elf
	arm-eabi-insight jocproves_divmod.elf &

