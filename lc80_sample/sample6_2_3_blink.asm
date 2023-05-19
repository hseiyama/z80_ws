;***********************************************************
;SAMPLE 6_2_3_blink
;***********************************************************
;例3：点滅ライトの制御
;OUT LEDをHIGHまたはLOW信号で制御して、このLEDが点滅するようにすることです。
;***********************************************************
;
DIGITAP	EQU	0F5H		;B2...B7=DIGITANST. AND キーマトリックス
				;B0=テープイン, B1=テープアウト
;
	ORG	2000H
EX03:
	LD	A,0FFH
	OUT	(DIGITAP),A
	LD	B,50H
LOOP1:
	CALL	DELAY
	DJNZ	LOOP1
	LD	A,0FDH
	OUT	(DIGITAP),A
	LD	B,50H
LOOP2:
	CALL	DELAY
	DJNZ	LOOP2
	JR	EX03
DELAY:
	LD	C,0FFH
LOOP3:
	DEC	C
	JR	NZ,LOOP3
	RET
	END
