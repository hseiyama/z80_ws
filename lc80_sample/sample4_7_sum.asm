;***********************************************************
;SAMPLE 4_7_sum
;***********************************************************
;4.7 データを合計する
;課題：一連のデータの合計を計算する、その数はメモリロケーション2041Hにある。
;データ列は、メモリ位置 2042H から始まる。
;結果は、メモリ位置 2040B に格納される。(可能なキャリーオーバーは考慮されない)。
;
;28H＋55H＋26H＝A3Hの結果が、メモリロケーション2040Hに格納される。
;***********************************************************
;
	ORG	2000H		;プログラムの開始時のアドレス
BSP7:
	LD	HL,2041H	;アドレス番号
	LD	B,(HL)		;カウンタ=数値の数
	SUB	A		;SUM=0
SUM:
	INC	HL		;次のアドレス
	ADD	A,(HL)		;SUM=SUM+新しい数値
	DJNZ	SUM		;すべての数字まで実行する
	LD	(2040H),A	;結果を保存する
	HALT
;
	ORG	2040H		;アドレスデータ
	DEFS	1		;メモリに結果を保存する
	DEFB	03H
	DEFB	28H
	DEFB	55H
	DEFB	26H
	END
