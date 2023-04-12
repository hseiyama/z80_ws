;***********************************************************
;SAMPLE4
;***********************************************************
;

	ORG	0000h
START:
	LD	SP,0000h
	CALL	MCLEAR
	HALT
;
	ORG	0031h
MCLEAR:
	LD	HL,0100h	;HL <- 0x0100
	LD	BC,0300h	;BC <- 0x0300
ZEROM:
	LD	(HL),0		;(HL) <- 0
	INC	HL		;HL <- HL+1
	DEC	BC		;BC <- BC-1
	LD	A,B		;A <- B
	OR	C		;A <- A|C
	JR	NZ,ZEROM
	RET
	END
