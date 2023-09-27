	ORG	0C000H

	LD	A, 15
	LD	B, 70
	CALL	MULTI
	RST	38H

MULTI:
	LD	HL, 0
	LD	E, B
	LD	D, 0
	LD	B, 8
MULT0:
	RRCA				;Rotate Right Circular Acc.
	JR	NC, MULT1
	ADD	HL, DE			;Add register pair to H and L
MULT1:
	SLA	E			;Shift operand register left Arithmetic
	RL	D			;Rotate Left register
	DJNZ	MULT0			;Decrement B and Jump relative if B=0
	RET

	END
