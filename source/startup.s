@;=== startup function for ARM assembly programs ===

.text
		.align 2
		.arm
		.global _start
	_start:
		nop             @; phony instruction for skipping initial breakpoint
		bl test         @; call the test routine
		@;bl principal    @; call the main routine
	.Lstop:
		b  .Lstop       @; endless loop

.end
