;;;
;;;	EMILY Board Console Driver (for Z80)
;;;

	INCLUDE	"../../emily.inc"

INIT:
	LD	A,EC_INI
	LD	(SMBASE+EO_HSK),A
	LD	(SMBASE+EO_CMD),A

	LD	A,0A5H
	LD	(SMBASE+EO_SIG),A

	LD	A,0CCH
	LD	(SMBASE+EO_HSK),A

	RET

CONIN:
	LD	A,(SMBASE+EO_HSK)
	CP	0CCH
	JR	Z,CONIN

	LD	A,EC_CIN
	LD	(SMBASE+EO_CMD),A

	LD	A,0CCH
	LD	(SMBASE+EO_HSK),A
CI1:
	LD	A,(SMBASE+EO_HSK)
	CP	0CCH
	JR	Z,CI1

	LD	A,(SMBASE+EO_DAT)

	RET

CONST:
	LD	A,(SMBASE+EO_HSK)
	CP	0CCH
	JR	Z,CONST

	LD	A,EC_CST
	LD	(SMBASE+EO_CMD),A

	LD	A,0CCH
	LD	(SMBASE+EO_HSK),A
CS1:
	LD	A,(SMBASE+EO_HSK)
	CP	0CCH
	JR	Z,CS1

	LD	A,(SMBASE+EO_DAT)
	OR	A

	RET

CONOUT:
	PUSH	AF
CO0:
	LD	A,(SMBASE+EO_HSK)
	CP	0CCH
	JR	Z,CO0

	LD	A,EC_COT
	LD	(SMBASE+EO_CMD),A

	POP	AF
	LD	(SMBASE+EO_DAT),A
	PUSH	AF

	LD	A,0CCH
	LD	(SMBASE+EO_HSK),A

	POP	AF

	RET
