;***********************************************************
;SAMPLE 6_2_4_text
;***********************************************************
;例4：文字表示
;キー「-」を押して、表示を消去します。
;キー「+」を押すと、"Hello"という文字が表示されます。
;モニタープログラムでのテキスト定義が使用されます。
;(テキストは7セグメントディスプレイのコード表（付録参照）に従って構成されています）。
;***********************************************************
;
DAK1	EQU	045AH
DAK2	EQU	0483H
DISP3	EQU	0583H
DISP4	EQU	0589H
;
	ORG	2000H
EX04:
	LD	IX,DISP3	;テキスト「HALLO」
DISPL1:
	CALL	DAK1
	CP	11H		;キー「-」
	JR	NZ,DISPL1
	LD	IX,DISP4	;空のテキスト
DISPL2:
	CALL	DAK1
	CP	10H		;キー「+」
	JR	NZ,DISPL2
	LD	IX,DISP4
	LD	C,6
INI1:
	LD	B,20H
INI2:
	CALL	DAK2
	DJNZ	INI2
	DEC	IX
	DEC	C
	JR	NZ,INI1
	JR	EX04
	END
