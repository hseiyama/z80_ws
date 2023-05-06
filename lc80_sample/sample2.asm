;***********************************************************
;SAMPLE 2
;***********************************************************
;
DAK1	EQU	045Ah
;
	ORG	2000h
EX1:
	LD	IX,HELP
DISP:
	CALL	DAK1		; ADR, TEXT
	CP	10h		; ANZEIGE
	JR	NZ,DISP		; TASTE "+"
	HALT
;
	ORG	2020h
HELP:
	DEFB	0AEh		;"S"
	DEFB	0E3h		;"U"
	DEFB	4Fh		;"P"
	DEFB	0C2h		;"L"
	DEFB	0CEh		;"E"
	DEFB	6Bh		;"H"
	END
