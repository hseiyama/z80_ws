;***************************************************************
;	zasm_sample02_min Z80�A�Z���u���R�[�h
;***************************************************************

;*******************************
;	�萔��`
;*******************************
ROM_B	EQU	0000H
ENTRY	EQU	ROM_B + 40H
ENTRYL	EQU	ENTRY & 00FFH
NMI_B	EQU	ROM_B + 66H
RAM_B	EQU	ROM_B + 80H

;	�p�������|�[�gI/O�A�h���X�Z�b�g
PIOA	EQU	1CH		;�`�|�[�g�f�[�^
PIOB	EQU	1EH		;�a�|�[�g�f�[�^

;***************************************************************
;	���C�����[�`��
;***************************************************************
	ORG	ROM_B

START:
	DI
	LD	SP, 0000H
	IM	2
	LD	HL,ENTRY
	LD	A,H
	LD	I,A

	XOR	A
	LD	(CT0CNT), A
	LD	(CT1CNT), A
	EI
LOOP:
	IN	A, (PIOA)
	INC	A
	OUT	(PIOA), A
	JR	LOOP

;*******************************
;	���荞�ݏ���
;*******************************
INTCT0:
	PUSH	AF
	LD	A, (CT0CNT)
	INC	A
	LD	(CT0CNT), A
	POP	AF
	EI
	RETI

INTCT1:
	PUSH	AF
	LD	A, (CT1CNT)
	INC	A
	LD	(CT1CNT), A
	POP	AF
	EI
	RETI

;*******************************
;	���荞�݃A�h���X
;*******************************
	ORG	ENTRY + 04H

	DW	0000H		; 4: PIOA���荞��
	DW	0000H		; 6: PIOB���荞��
	DW	INTCT0		; 8: CTC0���荞��
	DW	INTCT1		;10: CTC1���荞��
	DW	0000H		;12: CTC2���荞��
	DW	0000H		;14: CTC3���荞��

;*******************************
;	NMI����
;*******************************
	ORG	NMI_B
NMI:
	PUSH	AF
	IN	A, (PIOA)
	CPL
	OUT	(PIOB), A
	POP	AF
	RETN

;*******************************
;	RAM�̈�
;*******************************
	ORG	RAM_B

CT0CNT:	DS	1
CT1CNT:	DS	1

	END
