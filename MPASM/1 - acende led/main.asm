; Exemplo acender led

;-------- Arquivos incluídos no projeto ---
	#include p18f45k22.inc ; definições dos registradores

; ----- configuração dos fuse bits
	config FOSC = HSMP ; configura oscilador externo como HS oscillator (medium power 4-16 MHz)
	config PWRTEN = ON ; habilita o power up timer

; ----- INICIO DO PROGRAMA
	ORG 00H
; -- configurações iniciais ----
; port B
	CLRF 	PORTB 	; Initialize PORTB by clearing output data latches
	
	MOVLB 	0xF 	; Set BSR for banked SFRs

	BCF 	ANSELB,0 ; CONFIGURE I/O for digital inputs
	MOVLW 	01h 	; Value used to initialize data direction
	MOVWF 	TRISB 	; Set RB<0> as inputs

; port B
	CLRF 	PORTC 	; Initialize PORTB by clearing output data latches
	BCF 	ANSELC,0 ; CONFIGURE I/O for digital inputs
	BCF 	TRISC,0  ; Value used to initialize data direction

; ----- PROGRAMA PRINCIPAL
LOOP:
	BTFSC	PORTB,0 ; IF RB0 == 1
	GOTO	LIGA
	GOTO 	DESLIGA
	
LIGA:	
	BSF		PORTC,0	;	RC0 = 1
	GOTO	LOOP

DESLIGA:	
	BCF		PORTC,0	; ELSE RC0 = 0
	GOTO	LOOP
	
	END