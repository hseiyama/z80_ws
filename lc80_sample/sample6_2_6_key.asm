;***********************************************************
;SAMPLE 6_2_6_key
;***********************************************************
;��6�F�L�[�l
;���j�^�[�T�u�v���O�������g�p���āA���蓖�Ă�ꂽ�L�[�l�����肵�܂��B
;�T�u�v���O����DAK2�̓L�[�{�[�h�̋N���Ɩ₢���킹���������܂��B
;���̒l�̓}�g���N�X�z��ɑΉ����܂��B
;
;�G�~�����[�^�̓L�[���肪�AKEYUP�C�x���g�ł��邽�߁y�ǉ��z��}�������B
;***********************************************************
;
DAK2	EQU	0483H
DADP	EQU	04C3H
;
	ORG	2000H
EX06:
	CALL	DAK2
	JR	C,EX06		;�y�ǉ��z�L�[�����𔻒�
	CALL	DADP		;���[�h�f�[�^�\��
	JR	EX06
	END