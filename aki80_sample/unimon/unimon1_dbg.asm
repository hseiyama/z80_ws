;******************************
;�y�W�S�b�O�P�T��p�Z�b�g�A�b�v
;******************************
;AKI80�X�^�[�g�A�b�v�A�Z���u��

DBUG	EQU	8000H		;Universal Monitor���g�p����Ƃ���8000H
				;ROM�ɏĂ��Ƃ���0000H

;	�p�������|�[�gI/O�A�h���X�Z�b�g
PIOA	EQU	1CH		;�`�|�[�g�f�[�^
PIOB	EQU	1EH		;�a�|�[�g�f�[�^

;	�r�h�n�|�[�gI/O�A�h���X�Z�b�g
SIOA	EQU	18H		;chA���M/��M�o�b�t�@
SIOB	EQU	1AH		;chB���M/��M�o�b�t�@

;	�J�E���^�^�C�}I/O�A�h���X�Z�b�g
CTC0	EQU	10H		;CTC0�̃A�h���X
CTC1	EQU	11H		;CTC1�̃A�h���X
CTC2	EQU	12H		;CTC2�̃A�h���X
CTC3	EQU	13H		;CTC3�̃A�h���X

;	�y�W�S�b�O�P�T��pI/O�A�h���X�Z�b�g
WDM	EQU	0F0H	;WDTER,WDTPR,HALTMR
WDC	EQU	0F1H	;�N���A�[(4EH) �f�B�Z�[�u��(B1H)
DGC	EQU	0F4H	;�f�C�W�[�`�F�[���ݒ�(bit0-bit2)
;	�y�W�S�b�O�P�T��p�R�}���h�f�[�^
WDCL	EQU	4EH	;�E�H�b�`�h�b�O�N���A�R�}���h�f�[�^
WDDE	EQU	0B1H	;�E�H�b�`�f�B�Z�[�u���R�}���h�f�[�^
HMCR	EQU	0DBH	;�z���g���[�h�R���g���[���R�}���h�f�[�^


;********************************
;	�h�^�n�Z�b�g�f�[�^
;********************************
;�K�X�ύX�̂���

	ORG	DBUG
	JP	START
PIOACD:
	DB	0CFH	;PIOA���[�h���[�h			**001111 (���[�h3)
	DB	0FFH	;PIOA�f�[�^�f�B���N�V�������[�h		(�S�r�b�g����)
	DB	97H	;PIOA�C���^���v�g�R���g���[�����[�h	****0111 (�����ݗL��)
	DB	0FEH	;PIOA�C���^���v�g�}�X�N���[�h
	DB	0E4H	;PIOA�C���^���v�g�x�N�^
PAEND	EQU	$
PIOBCD:
	DB	0CFH	;PIOB���[�h���[�h			**001111 (���[�h3)
	DB	00H	;PIOB�f�[�^�f�B���N�V�������[�h		(�S�r�b�g�o��)
	DB	07H	;PIOB�C���^���v�g�R���g���[�����[�h	****0111 (�����ݖ���)
;	DB	00H	;PIOB�C���^���v�g�}�X�N���[�h		(���g�p)
;	DB	0E6H	;PIOB�C���^���v�g�x�N�^			(���g�p)
PBEND	EQU	$

;SIOACD:
;	DB	18H	;SIOA WR0 �`�����l�����Z�b�g
;	DB	04H	;SIOA WR0 �|�C���^�S
;	DB	44H	;SIOA WR4 �ۯ� �ݸӰ�� �į�� �ޯ� ���è �Ȱ���
;	DB	01H	;SIOA WR0 �|�C���^�P
;	DB	10H	;SIOA WR1 ���荞�ݐ���E�F�C�g�^���f�B		(��M��׸����荞�݉�)
;	DB	03H	;SIOA WR0 �|�C���^�R
;	DB	0C1H	;SIOA WR3 ��M�o�b�t�@������
;	DB	05H	;SIOA WR0 �|�C���^�T
;	DB	68H	;SIOA WR5 ���M�o�b�t�@������
;SAEND	EQU	$
;SIOBCD:
;	DB	18H	;SIOB WR0 �`�����l�����Z�b�g
;	DB	04H	;SIOB WR0 �|�C���^�S
;	DB	44H	;SIOB WR4 �ۯ� �ݸӰ�� �į�� �ޯ� ���è �Ȱ���
;	DB	01H	;SIOB WR0 �|�C���^�P
;	DB	04H	;SIOB WR1 ���荞�ݐ���E�F�C�g�^���f�B		(�ð�� �̪�� �޸��)
;	DB	02H	;SIOB WR0 �|�C���^�Q
;	DB	0F0H	;SIOB WR2 �C���^���v�g�x�N�^			(���荞���޸��)
;	DB	03H	;SIOB WR0 �|�C���^�R
;	DB	0C1H	;SIOB WR3 ��M�o�b�t�@������
;	DB	05H	;SIOB WR0 �|�C���^�T
;	DB	68H	;SIOB WR5 ���M�o�b�t�@������
;SBEND	EQU	$

CTC0CD:
	DB	0A5H	;CTC0 �`�����l���R���g���[�����[�h	*******1 (�^�C�}���[�h)
	DB	240	;CTC0 �^�C���R���X�^���g���W�X�^	(200Hz: 5ms����)
	DB	0E8H	;CTC0 �C���^���v�g�x�N�^		*****000 (�S�`���l���p)
C0END	EQU	$
CTC1CD:
	DB	0C5H	;CTC1 �`�����l���R���g���[�����[�h	*******1 (�J�E���^���[�h)
	DB	200	;CTC1 �^�C���R���X�^���g���W�X�^	(1Hz: 1s����)
C1END	EQU	$
CTC2CD:
	DB	05H	;CTC2 �`�����l���R���g���[�����[�h	*******1
	DB	00H	;CTC2 �^�C���R���X�^���g���W�X�^
C2END	EQU	$
CTC3CD:
	DB	05H	;CTC3 �`�����l���R���g���[�����[�h	*******1 (�^�C�}���[�h)
	DB	5	;CTC3 �^�C���R���X�^���g���W�X�^	(153.6kHz)
C3END	EQU	$

WDMCD:
;	DB	0F3H	;�E�H�b�`�h�b�O�C�z���g���[�h�ݒ�	*****011 (STOP���[�h)
;	DB	0E3H	;�E�H�b�`�h�b�O�C�z���g���[�h�ݒ�	*****011 (IDLE1���[�h)
;	DB	0EBH	;�E�H�b�`�h�b�O�C�z���g���[�h�ݒ�	*****011 (IDLE2���[�h)
	DB	0FBH	;�E�H�b�`�h�b�O�C�z���g���[�h�ݒ�	*****011 (RUN���[�h)
DGCCD:
	DB	00H	;�f�C�W�[�`�F�[�����ʐݒ�		00000*** (CTC > SIO > PIO)


;*****************************
;	�h�m�s����(IM1)
;*****************************

	ORG	DBUG + 0038H
INT:
	EI
	RETI


;***********************
;	�m�l�h����
;***********************

	ORG	DBUG + 0066H
NMI:
	PUSH	AF
	PUSH	BC
	LD	A, '2'
	LD	C, 02H
	RST	30H			;[UniMon] CONOUT
	LD	A, 0FFH
	LD	(DBGP), A		;�f�o�b�O�p���߂ɏ�����
	POP	BC
	POP	AF
	RETN


;*******************************
;	�h�^�n�Z�b�g�A�b�v
;*******************************

	ORG	DBUG + 0080H
IOSET:
	LD	HL, PIOACD		;PIOA�R�}���h�Z�b�g�A�b�v
	LD	B, PAEND - PIOACD
	LD	C, PIOA + 1		;PIOA�R�}���h�A�h���X(1DH)
	OTIR
	LD	HL, PIOBCD		;PIOB�R�}���h�Z�b�g�A�b�v
	LD	B, PBEND - PIOBCD
	LD	C, PIOB + 1		;PIOB�R�}���h�A�h���X(1FH)
	OTIR
	LD	HL, CTC0CD		;CTC0�R�}���h�Z�b�g�A�b�v
	LD	B, C0END - CTC0CD
	LD	C, CTC0
	OTIR
	LD	HL, CTC1CD		;CTC1�R�}���h�Z�b�g�A�b�v
	LD	B, C1END - CTC1CD
	LD	C, CTC1
	OTIR
	LD	HL, CTC2CD		;CTC2�R�}���h�Z�b�g�A�b�v
	LD	B, C2END - CTC2CD
	LD	C, CTC2
	OTIR
;	LD	HL, CTC3CD		;CTC3�R�}���h�Z�b�g�A�b�v	[UniMon]�����ӏ�
;	LD	B, C3END - CTC3CD
;	LD	C, CTC3
;	OTIR
;	LD	HL, SIOACD		;SIOA�R�}���h�Z�b�g�A�b�v	[UniMon]�����ӏ�
;	LD	B, SAEND - SIOACD
;	LD	C, SIOA + 1		;SIOA�R�}���h�A�h���X(19H)
;	OTIR
;	LD	HL, SIOBCD		;SIOB�R�}���h�Z�b�g�A�b�v	[UniMon]�����ӏ�
;	LD	B, SBEND - SIOBCD
;	LD	C, SIOB + 1		;SIOB�R�}���h�A�h���X(1BH)
;	OTIR
	LD	A, HMCR			;�z���g���[�h�R���g���[��
	OUT	(WDC), A
	LD	A, (WDMCD)		;�E�H�b�`�h�b�O�C�z���g���[�h�Z�b�g
	OUT	(WDM), A
	LD	A, (DGCCD)		;���荞�ݗD�揇�ʃZ�b�g
	OUT	(DGC), A
WDOG:	LD	A, WDCL			;�E�H�b�`�h�b�O�N���A
	OUT	(WDC), A
	RET


;**************************************
;	���荞�݃A�h���X�CDWL�ݒ�
;	�A�h���X�l�����̂܂܋L��
;**************************************

	ORG	DBUG + 00E4H
	DW	INTPA			;PIOA���荞��
	DW	0000H			;PIOB���荞��
	DW	INTCT0			;CTC0���荞��
	DW	INTCT1			;CTC1���荞��
	DW	0000H			;CTC2���荞��
	DW	0000H			;CTC3���荞��
	DW	0000H			;SIOB�g�����X�~�b�^�o�b�t�@�G���v�e�B
	DW	0000H			;SIOB�O���^�X�e�[�^�X���荞��
	DW	0000H			;SIOB���V�[�o�L�����N�^�A�x�C���u��
	DW	0000H			;SIOB�����M���
	DW	0000H			;SIOA�g�����X�~�b�^�o�b�t�@�G���v�e�B
	DW	0000H			;SIOA�O���^�X�e�[�^�X���荞��
	DW	0000H			;SIOA���V�[�o�L�����N�^�A�x�C���u��
	DW	0000H			;SIOA�����M���


;************************************************************************
;	���C�����[�`���X�^�[�g
;************************************************************************

	ORG	DBUG + 0100H

START:	DI				;�Z�b�g�A�b�v���A���荞�ݕs��
	IM	2			;���荞�݃��[�h�Q
	LD	A, DBUG / 100H		;���荞�ݏ�ʃx�N�^���[�h
	LD	I, A
	LD	SP, 0000H		;�X�^�b�N�|�C���^ FFFFH����

	CALL	IOSET
	EI

	;��������v���O����������
	IN	A, (PIOA)		;�|�[�gA�����
	LD	(VALUE), A		;VALUE��������
	LD	A, '0'
	LD	C, 02H
	RST	30H			;[UniMon] CONOUT
LOOP:
	CALL	LPBK			;���[�v�o�b�N
	CALL	WDOG			;�E�H�b�`�h�b�O�N���A
	DI
DBGP:	NOP				;[UniMon] �f�o�b�O�p�_�~�[����
	EI
	JR	LOOP

;���[�v�o�b�N
LPBK:
	PUSH	AF
	PUSH	BC
	LD	C, 05H
	RST	30H			;[UniMon] CONST
	JR	Z, LPBKE
	LD	C, 04H
	RST	30H			;[UniMon] CONIN
	LD	C, 02H
	RST	30H			;[UniMon] CONOUT
	DI				;���荞�݋֎~
	LD	A, (VALUE)
	ADD	A, 10H			;VALUE���X�V
	LD	(VALUE), A
	EI				;���荞�݋���
LPBKE:
	POP	BC
	POP	AF
	RET

;CTC0���荞�� (5ms����)
INTCT0:
	PUSH	AF
	LD	A, (VALUE)
	OUT	(PIOB), A		;�|�[�gB�ɏo��
	POP	AF
	EI
	RETI

;CTC1���荞�� (1s����)
INTCT1:
	PUSH	AF
	LD	A, (VALUE)
	INC	A			;VALUE���X�V
	LD	(VALUE), A
	POP	AF
	EI
	RETI

;PIOA���荞��
INTPA:
	PUSH	AF
	PUSH	BC
	IN	A, (PIOA)		;�|�[�gA�����
	LD	(VALUE), A		;VALUE���X�V
	LD	A, '1'
	LD	C, 02H
	RST	30H			;[UniMon] CONOUT
	POP	BC
	POP	AF
	EI
	RETI


;**************************************
;	�q�`�l�z�u
;**************************************

	ORG	DBUG + 1000H

VALUE:	DEFB	00H

	END
