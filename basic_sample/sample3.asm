;***********************************************************
;SAMPLE3
;***********************************************************
;
GUSUR	EQU	0200h
KISUR	EQU	025Fh
	ORG	0000h
START:
	LD	B,0		;B <- 0
LOOP2:
	SRL	A		;A <- A>>1
	JR	NC,JP1
	INC	B		;B <- B+1
JP1:
	JR	NZ,LOOP2
	BIT	0,B
	JP	Z,GUSUR
	JP	KISUR
	END
