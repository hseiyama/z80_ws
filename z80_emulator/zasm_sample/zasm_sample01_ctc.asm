;***************************************************************
;	zasm_sample01_ctc Z80�A�Z���u���R�[�h
;***************************************************************

;*******************************
;	�萔��`
;*******************************
ROM_B	EQU	8000H
ENTRY	EQU	ROM_B + 40H
ENTRYL	EQU	ENTRY & 00FFH
RAM_B	EQU	ROM_B + 80H

;	�p�������|�[�gI/O�A�h���X�Z�b�g
PIOA	EQU	1CH		;�`�|�[�g�f�[�^
PIOB	EQU	1EH		;�a�|�[�g�f�[�^
;	�J�E���^�^�C�}I/O�A�h���X�Z�b�g
CTC0	EQU	10H		;CTC0�̃A�h���X
CTC1	EQU	11H		;CTC1�̃A�h���X
;CTC2	EQU	12H		;CTC2�̃A�h���X
;CTC3	EQU	13H		;CTC3�̃A�h���X

;***************************************************************
;	���C�����[�`��
;***************************************************************
	ORG	ROM_B

START:
	DI
;	LD	SP, 0000H
;	IM	2
	LD	HL,ENTRY
	LD	A,H
	LD	I,A

	CALL	IOSET
	XOR	A
	LD	(CT0CNT), A
	EI
LOOP:
	IN	A, (PIOA)
	CP	0AAH
	JR	NZ, POUT
	LD	A, (CT0CNT)
POUT:
	OUT	(PIOB), A
	JR	LOOP

IOSET:
	LD	HL, CTC0CD		;CTC0�R�}���h�Z�b�g�A�b�v
	LD	B, C0END - CTC0CD
	LD	C, CTC0
	OTIR
	LD	HL, CTC1CD		;CTC1�R�}���h�Z�b�g�A�b�v
	LD	B, C1END - CTC1CD
	LD	C, CTC1
	OTIR
;	LD	HL, CTC2CD		;CTC2�R�}���h�Z�b�g�A�b�v
;	LD	B, C2END - CTC2CD
;	LD	C, CTC2
;	OTIR
;	LD	HL, CTC3CD		;CTC3�R�}���h�Z�b�g�A�b�v
;	LD	B, C3END - CTC3CD
;	LD	C, CTC3
;	OTIR
	RET

;*******************************
;	���荞�݃A�h���X
;*******************************
	ORG	ENTRY + 04H

	DW	0000H		; 4: PIOA���荞��
	DW	0000H		; 6: PIOB���荞��
	DW	0000H		; 8: CTC0���荞��
	DW	INTCT1		;10: CTC1���荞��
	DW	0000H		;12: CTC2���荞��
	DW	0000H		;14: CTC3���荞��

;*******************************
;	ROM�̈�
;*******************************
CTC0CD:
	DB	ENTRYL + 8	;CTC0�C���^���v�g�x�N�^			*****000 (�S�`���l���p)
	DB	27H		;CTC0�`�����l���R���g���[�����[�h	*******1 (�^�C�}���[�h)
	DB	122		;CTC0�^�C���R���X�^���g���W�X�^		(128.0Hz CLK=4MHz�O��)
C0END	EQU	$
CTC1CD:
	DB	0C7H		;CTC1�`�����l���R���g���[�����[�h	*******1 (�J�E���^���[�h)
	DB	128		;CTC1�^�C���R���X�^���g���W�X�^		(1s)
C1END	EQU	$
;CTC2CD:
;	DB	05H		;CTC2�`�����l���R���g���[�����[�h	*******1
;	DB	00H		;CTC2�^�C���R���X�^���g���W�X�^
;C2END	EQU	$
;CTC3CD:
;	DB	05H		;CTC3�`�����l���R���g���[�����[�h	*******1
;	DB	5		;CTC3�^�C���R���X�^���g���W�X�^
;C3END	EQU	$

;*******************************
;	���荞�ݏ���
;*******************************
INTCT1:
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

	END
