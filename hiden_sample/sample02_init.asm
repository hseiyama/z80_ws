	ORG	0000H

	PUSH	AF
	PUSH	AF
	XOR	A			;演算結果が常にゼロになる
					;「LD A,0」の代用（フラグ変化なし）
	POP	AF
	OR	A			;キャリーフラグのリセット用
					;「CP 0」の代用
	POP	AF
	AND	A			;「OR A」と同じ目的で使用
	HALT

	END
