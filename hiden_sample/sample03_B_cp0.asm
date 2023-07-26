	ORG	0000H

	LD	A,0FFH
	OR	A			;「CP 0」の代用
	LD	A,00H
	OR	A			;「CP 0」の代用

	LD	B,00H
	DEC	B
	INC	B			;「CP 0」判定のBレジスタ版
	LD	B,0FFH
	INC	B
	DEC	B			;「CP 0」判定のBレジスタ版

	END
