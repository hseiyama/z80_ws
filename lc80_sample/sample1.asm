;***********************************************************
;SAMPLE 1
;***********************************************************
;
MUSIK	EQU	04EEh
;
	ORG	2000h
START:
	LD	IY,NOTEN
	CALL	MUSIK
;
	ORG	2010h
NOTEN:
	DEFW	0801h
	DEFW	0802h
	DEFW	0803h
	DEFB	40h
	END
