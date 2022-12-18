;Exerc�cio I/O
;Fa�a uma calculadora para soma/subtra��o em bin�rio, que receba os operandos 
;nas portas B e C, e apresente o resultado na porta D. Utilize a porta A para 
;definir a opera��o e apresentar as flags de status.
;
; Processador: PIC18F45K22
; Clock: 8MHz
;******************************************************************************

;	processor PIC18F45K22
;-------- Arquivos inclu�dos no projeto ---
	#include p18f45k22.inc ; defini��es dos registradores

;--- configura��o dos Fuse bits (bits de configura��o) ---
	config FOSC=HSHP ; cristal oscilador externo de alta velocidade


; Atribuindo nomes das vari�veis aos endere�os de mem. RAM
NUM1 EQU PORTB
NUM2 EQU PORTC
OUT  EQU LATD
STAT EQU LATA

#DEFINE OP PORTA,RA5
	
;--------------- In�cio do programa ------------------------------------------
	ORG 00H	
INICIO:
;------------ Configura��es iniciais ----------------
; Inicializando Portas de entrada e sa�da
	MOVLB 	0xF 	; Set BSR for banked SFRs

; PortA
	CLRF 	LATA 	; Initialize PORTA by clearing output data latches	
	CLRF 	ANSELA 	; Configure I/O for digital inputs	
	MOVLW 	0E0h 	; Value used to initialize data direction
	MOVWF 	TRISA 	; Set RA<4:0> as outputs ; RA<7:5>as inputs
			   
; PortB
	CLRF 	LATB 	; Initialize PORTB by clearing output data latches	
	CLRF 	ANSELB 	; Configure I/O for digital inputs	
	MOVLW 	0FFh 	; Value used to initialize data direction
	MOVWF 	TRISB 	; Set RB<7:0>as inputs

; PortC
	CLRF 	LATC 	; Initialize PORTC by clearing output data latches	
	CLRF 	ANSELC 	; Configure I/O for digital inputs	
	MOVLW 	0FFh 	; Value used to initialize data direction
	MOVWF 	TRISC 	; Set RC<7:0>as inputss

; PortD
	CLRF 	LATD 	; Initialize PORTA by clearing output data latches	
	CLRF 	ANSELD 	; Configure I/O for digital inputs	
	MOVLW 	00h 	; Value used to initialize data direction
	MOVWF 	TRISD 	; Set RA<4:0> as outputs ; RA<7:5>as inputs

;----------- Programa principal	
LOOP:	
	MOVF	NUM2,W
	
	BTFSC	OP	;IF (OP==1) 
	GOTO	SUM	;	SUM();
	GOTO	SUB	;ELSE SUB();
	GOTO	LOOP
	
SUM:	;{OUT=NUM1+NUM2; STAT=STATUS}
	ADDWF	NUM1,W
	MOVWF	OUT
	MOVFF	STATUS, STAT
	GOTO	LOOP
	
	
SUB: ;{OUT=NUM1-NUM2; STAT=STATUS}	
	SUBWF	NUM1,W
	MOVWF	OUT
	MOVFF	STATUS, STAT
	GOTO	LOOP
	
	END
	