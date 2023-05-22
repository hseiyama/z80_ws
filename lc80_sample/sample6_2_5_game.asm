;***********************************************************
;SAMPLE sample6_2_5_game
;***********************************************************
;例5：循環ゲーム
;表示位置のセグメントを次々に制御する。
;キー「+」で循環を停止し、他のキー（リセットキーと割り込みキーを除く）で循環を継続する。
;表では、これが最初に示されます。
;バイトは表示位置 (OOXX=右、05XX=左) を表し、次のバイトはセグメントの割り当てを表します
;（ビット0セグメントBなど、記述に従う）。
;
;【備考】アセンブルエラーを解消。MEMのサイズは6（SEGの個数）。
;***********************************************************
;
DAK2	EQU	0483H
;
	ORG	2000H
EX05:
	LD	HL,TABLE
	LD	IX,MEM
LOOP:
	CALL	CLRDISP
	LD	E,(HL)		;表示位置
	INC	E
	JR	Z,EX05
	DEC	E
	LD	D,0
	ADD	IX,DE
	INC	HL
	LD	A,(HL)		;表示データ
	LD	(IX),A
	LD	IX,MEM
	LD	B,3
LIGHT:
	CALL	DAK2
	JR	C,LIGHT1
	LD	C,A		;キー値を記憶
LIGHT1:
	DJNZ	LIGHT
	LD	A,C		;キー値を復帰
	CP	0AH		;キー「+」と比較
	JR	Z,STOP
	INC	HL
	INC	HL
STOP:
	DEC	HL
	JR	LOOP
CLRDISP:
	LD	B,6		;SEGの個数を指定
CLR:
	LD	(IX+0),00H
	INC	IX
	DJNZ	CLR
	LD	DE,0FFFAH
	ADD	IX,DE
	RET
TABLE:
	DEFW	0400H
	DEFW	0100H
	DEFW	2000H
	DEFW	8000H
	DEFW	4000H
	DEFW	0200H
	DEFB	0FFH
;
	ORG	2100H
MEM:
	DEFS	6
	END
