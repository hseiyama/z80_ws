	ORG	0000H

	LD	A,0FFH
	OR	A			;�uCP 0�v�̑�p
	LD	A,00H
	OR	A			;�uCP 0�v�̑�p

	LD	B,00H
	DEC	B
	INC	B			;�uCP 0�v�����B���W�X�^��
	LD	B,0FFH
	INC	B
	DEC	B			;�uCP 0�v�����B���W�X�^��

	END
