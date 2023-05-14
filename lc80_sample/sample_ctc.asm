;***********************************************************
;SAMPLE CTC
;***********************************************************
;
CTC0	EQU	0ECh
CTC1	EQU	0EDh
CTC2	EQU	0EEh
CTC3	EQU	0EFh
;
	ORG	2000h
START:
	LD	HL,CTCC	;CTC CONTROL
	LD	B,3
	LD	C,CTC0  ;CTC 0
;	LD	C,CTC1  ;CTC 1
	OTIR
	IM	1
	EI
WAIT:
	JR	WAIT
CTCC:
	DEFB	00h		;INTTRUPT VECTOR (CTC0)
;	DEFB	02h		;INTTRUPT VECTOR (CTC1)
	DEFB	85h		;CHANEL CONTROL
	DEFB	10h		;TIME CONSTRUCT
;
	ORG	2338h
INT:
	EI
	RETI
;
	END
