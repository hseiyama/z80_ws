;***********************************************************
;SAMPLE6
;***********************************************************
;
	ORG	0000h
START:
	LD	SP,0000h	;SP <- 0x0000
	CALL	CONV
	HALT
;
	ORG	004Eh
CONV:
	AND	0Fh		;A <- A&0x0F
	LD	C,A		;C <- A
	LD	B,0		;B <- 0
	LD	HL,TABLE
	ADD	HL,BC		;HL <- BC
	LD	A,(HL)		;A <- (HL)
	RET
TABLE:
	DEFB	5Ch
	DEFB	06h
	DEFB	58h
	DEFB	4Fh
	DEFB	66h
	DEFB	6Dh
	DEFB	7Dh
	DEFB	27h
	DEFB	7Fh
	DEFB	6Fh
	DEFB	77h
	DEFB	7Ch
	DEFB	39h
	DEFB	5Eh
	DEFB	79h
	DEFB	71h
	END
