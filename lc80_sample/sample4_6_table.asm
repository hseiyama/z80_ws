;***********************************************************
;SAMPLE 4_6_table
;***********************************************************
;4.6 �������̌���
;���K���F�e�[�u���@��p���āA���������P�[�V����2040H�̐����̕����������肷��B
;���̌��ʂ́A���������P�[�V����2041H�Ɋi�[�����B
;�e�[�u���̓A�h���X2060H����n�܂�A�l�� 0 �` 9 �ɂȂ�B
;
;���̌��ʂ́A���������P�[�V����2041H��09H���i�[�����B
;�������ʒu	16�i��	10�i��
;2060H		OOH	0  (0^2)
;2061H		01H	1  (1^2)
;2062H		04H	4  (2^2)
;2063H		09H	9  (3^2)
;2064H		10H	16 (4^2)
;2065H		19H	25 (5^2)
;2066H		24H	36 (6^2)
;2067H		31H	49 (7^2)
;2068H		40H	64 (8^2)
;2069H		51H	81 (9^2)
;***********************************************************
;
	ORG	2000H		;�v���O�����̊J�n���̃A�h���X
BSP6:
	LD	A,(2040H)	;A�̌�̃V�[�h�ԍ�
	LD	L,A		;16�r�b�g�A�h���X�̃C���f�b�N�X
	LD	H,00H		;H���W�X�^�̃N���A
	LD	DE,2060H	;�����`�^�u�̊J�n�A�h���X
	ADD	HL,DE		;�J�n�A�h���X+�C���f�b�N�X
	LD	A,(HL)		;A�̌�̐����`�̐�
	LD	(2041H),A	;���ʂ�ۑ�����
	HALT
;
	ORG	2040H		;�A�h���X�f�[�^
	DEFB	03H
;
	ORG	2060H		;�A�h���X�������^�u
	DEFB	0
	DEFB	1
	DEFB	4
	DEFB	9
	DEFB	16
	DEFB	25
	DEFB	36
	DEFB	49
	DEFB	64
	DEFB	81
	END