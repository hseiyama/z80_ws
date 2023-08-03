	ORG	0000H

	CALL	CHECK
	HALT

CHECK:
	NOP				;最小ウェイト
	NOP				;(RETに置き換えて調整可)
	NOP
	RET

	END
