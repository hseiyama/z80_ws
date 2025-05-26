;***************************************************************
;	perfectz80_trace�p Z80�A�Z���u���R�[�h
;***************************************************************

;*******************************
;	�萔��`
;*******************************
ROM_B	EQU	0000H
ENTRY	EQU	0040h
RAM_B	EQU	ROM_B + 80H

;	�p�������|�[�gI/O�A�h���X�Z�b�g
PIOA	EQU	1CH		;�`�|�[�g�f�[�^
PIOB	EQU	1EH		;�a�|�[�g�f�[�^
;	�J�E���^�^�C�}I/O�A�h���X�Z�b�g
CTC0	EQU	10H		;CTC0�̃A�h���X
;CTC1	EQU	11H		;CTC1�̃A�h���X
;CTC2	EQU	12H		;CTC2�̃A�h���X
;CTC3	EQU	13H		;CTC3�̃A�h���X

;***************************************************************
;	���C�����[�`��
;***************************************************************
	ORG	ROM_B

START:
	DI
	LD	SP, 0000H
	IM	2
	XOR	A
	LD	I, A
	CALL	IOSET
	XOR	A
	LD	(CT0CNT), A
	LD	(NMICNT), A
	EI
LOOP:
	IN	A, (PIOA)
	CP	0AAH
	JR	Z, BREAK
	RLCA
	LD	B, A
	LD	C, PIOB
	OUT	(C), B
	JR	LOOP
BREAK:
	NOP
	HALT
	LD	A, 55H
	OUT	(PIOA), A
	NOP
	JR	LOOP

IOSET:
	LD	HL, CTC0CD		;CTC0�R�}���h�Z�b�g�A�b�v
	LD	B, C0END - CTC0CD
	LD	C, CTC0
	OTIR
	RET

;*******************************
;	���荞�݃A�h���X
;*******************************
	ORG	ENTRY + 04H

	DW	0000H		; 4: PIOA���荞��
	DW	0000H		; 6: PIOB���荞��
	DW	INTCT0		; 8: CTC0���荞��
	DW	0000H		;10: CTC1���荞��
	DW	0000H		;12: CTC2���荞��
	DW	0000H		;14: CTC3���荞��

;*******************************
;	ROM�̈�
;*******************************
CTC0CD:
	DB	ENTRY + 8	;CTC0�C���^���v�g�x�N�^			*****000 (�S�`���l���p)
	DB	87H		;CTC0�`�����l���R���g���[�����[�h	*******1 (�^�C�}���[�h)
	DB	08H		;CTC0�^�C���R���X�^���g���W�X�^		(8)
C0END	EQU	$

;*******************************
;	NMI����
;*******************************
	ORG	0066H

NMI:
	EXX
	LD	HL, NMICNT
	INC	(HL)
	EXX
	RETN

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

;*******************************
;	RAM�̈�
;*******************************
	ORG	RAM_B

CT0CNT:	DS	1
NMICNT:	DS	1

	END
