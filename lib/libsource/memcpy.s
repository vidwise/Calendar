@;
@;  memcpy.s
@;
@;
@;  Created by Pere Millán Marco on 21/03/2019.
@;

@; char *memcpy(char *desti, const char *font, size_t numBytes)
@;  R0                R0                 R1           R2

.text
    .align 2
    .arm
    .global memcpy
memcpy:
    push {r2-r3, lr}
.Loop:
    cmp r2, #0
    ble .Lend
    sub r2, #1
    ldrb r3, [r1,r2]
    strb r3, [r0,r2]
    b .Loop
.Lend:
    pop  {r2-r3, pc}

.end
