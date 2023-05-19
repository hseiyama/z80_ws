;***********************************************************
;SAMPLE 4_1_complement
;***********************************************************
;4.1. バイナリ補数
;練習：メモリ位置2040Hの内容から、1の補数を形成する（否定）。
;その結果はメモリ位置2041Hに格納される。
;
;結果はメモリ位置2041Hに95Hが格納される。
;***********************************************************
;
	ORG	2000H		;プログラム開始のアドレス
BSP1:
	LD	A,(2040H)	;ロード初期値
	CPL			;補数を形成
	LD	(2041H),A	;結果を保存
	HALT			;CPUストップ
;
	ORG	2040H		;アドレスデータ
	DEFB	6AH		;出力値(例)
	END
