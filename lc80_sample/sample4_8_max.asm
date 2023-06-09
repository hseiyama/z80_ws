;***********************************************************
;SAMPLE 4_8_max
;***********************************************************
;4.8 最大の数を決定する
;課題：一連の数値のうち最大のものを決定する。
;データの数はアドレス2041Hで与えられ、数字の列はアドレス2042Hで始まる。
;数字のうち最大のものは、メモリ位置2040Hに格納される。
;
;その結果、OE3Hはメモリロケーション2040Bに格納される。
;***********************************************************
;
	ORG	2000H		;プログラム開始アドレス
BSP8:
	LD	HL,2041H	;個数のアドレス
	LD	B,(HL)		;カウンタ=個数
	SUB	A		;クリア
NEXT:
	INC	HL		;次の数値のアドレス
	CP	(HL)		;新しい最大数か？
	JP	NC,ZAHL		;そうでない場合はジャンプ
	LD	A,(HL)		;Aの新しい数値
ZAHL:
	DJNZ NEXT		;すべての数値まで実行する
	LD	(2040H),A	;最大数を保存する
	HALT
;
	ORG	2040H		;データのアドレス
	DEFS	1		;結果を格納する場所
	DEFB	05H
	DEFB	67H
	DEFB	79H
	DEFB	15H
	DEFB	0E3H
	DEFB	72H
	END
