	page 0
	cpu z80

;;; Constants

CR	EQU	0DH
LF	EQU	0AH

;	MEMORY ASSIGN

MSG_TOP		equ	5400H	; Message TOP address(command help)
MSG_E		equ	7500H	; Message END address

	ORG	MSG_TOP

;;;
;;; Messages
;;;

cmd_hlp:	db	"? :Command Help", CR, LF
		db	"#L|<num> :Launch program", CR, LF
		db	"A[<address>] : Mini Assemble mode", CR, LF
		db	"B[1|2[,<adr>]] :Set or List Break Point", CR, LF
		db	"BC[1|2] :Clear Break Point", CR, LF
		db	"D[<adr>] :Dump Memory", CR, LF
		db	"DI[<adr>][,s<steps>|<adr>] :Disassemble", CR, LF
		db	"G[<adr>][,<stop adr>] :Go and Stop", CR, LF
		db	"I<port> : Input from port", CR, LF
		db	"L[G|<offset>] :Load HexFile (and GO)", CR, LF
		db	"O<port>,<data> : Output data to port", CR, LF
		db	"P[I|S] :Save HexFile(I:Intel,S:Motorola)", CR, LF
		db	"R[<reg>] :Set or Dump register", CR, LF
		db	"S[<adr>] :Set Memory", CR, LF
		db	"T[<adr>][,<steps>|-1] : Trace command", CR, LF
		db	"TM[I|S] :Trace Option for CALL", CR, LF
		db	"TP[ON|OFF] :Trace Print Mode", CR, LF, 00h

	db	MSG_E - $ dup(0ffH)

	END
