; Disciplina Microcontroladores
; Autor: Fulano
;
; MCU: PIC18F45k22	clock: 8MHz
;
; Programas exemplo TIMER 0 sem interrupção
;
; versão: 0.1 - data: 18/07/2022
;--------------------------------------------

	list  p=18f45k22, r=dec ; indica o microcontrolador utilizado e o radix padrão

;-------- Arquivos incluídos no projeto ---
	#include p18f45k22.inc ; definições dos registradores

;--- configura Fuse bits (bits de configuração) ---
	config 	FOSC=HSHP	; cristal oscilador externo de alta velocidade,  
	config 	WDTEN=OFF	; desabilitado o watchdo timer , 
	config 	PWRTEN=ON	; power-up timer bit abilitado
	config 	CP0=OFF	; Code protection Block 0 disabled, 
	config 	CP1=OFF	; Code protection Block 1 disabled
	config 	CP2=OFF	; Code protection Block 2 disabled, 
	config 	CP3=OFF	; Code protection Block 3 disabled
	
;--- Saidas
	#define		led1		PORTE,RE1	;LEDs conectados na porta E	

;--- Entradas
	#define		botao		PORTC,RC0	; BOTÃO CONECTADO NA PORTA RC0

;--- variáveis
	CBLOCK	60h
		COUNTER1 
		COUNTER2
		NUM_MS
	ENDC
	
;********** Vetor de reset
	ORG		00H		;End inicial da mem. de prog.
		GOTO INICIO
		
;********** Vetor de interrupção
	;--- High-Priority Interrupt Vector 
	ORG 	0008h
		RETFIE

	;---Low-Priority Interrupt Vector
	ORG		0018h
		RETFIE

;********* Define endereço de inicio
	ORG		001Ah
INICIO:
;------ Programa principal
	;************ Configurações iniciais ***********
			CLRF ANSELE ; Configure A/D pins on PORTE for digital only
			
			MOVLW 0FDH 	; Value used to initialize data direction				
			MOVWF TRISE ; Set RE<0> as inputs
						; 	  RE<1> as outputs
						;     RE<2> as inputs
	
			CLRF PORTE 	; Initialize PORTE by clearing output data latches
			;CLRF LATE 	; Alternate method to clear output data latches
			
	;*****************************************						
loop:			

			MOVLW	.250
			call	delay_ms
			MOVLW	.250
			call	delay_ms
			
			;goto	apaga_led1	;não, desvia para apaga_led1
			bcf		led1		;apaga led1
			MOVLW	.100
			call	delay_ms
			bsf		led1		;sim, liga led1
			goto 	loop		;volta para label loop
			
	
;*********************** SUBROTINAS******************************
;----------------------------------------------
;Nome: delay_ms
;Descrição: Espera X ms
;Param. Entrada: WREG
;Param. Saída: nenhum
;Altera: WREG, NUM_MS, COUNTER2, COUNTER1
;----------------------------------------------
delay_ms: ;@8MHz => 2000Tcy, com prescaler de 16 e tmr0 de 125

			MOVWF	NUM_MS
			MOVLW	43H		; Configura Timer 0: 8bits, timer, pre-scaled, 1:16
							;	  0		  1		 0	   0	0		011							
			MOVWF	T0CON 	; |TMR0ON |T08BIT |T0CS| T0SE| PSA |TOPS<2:0>|	

			MOVLW	(256 - 125); valor inicial da contagem
			MOVWF 	TMR0L	;Writing to TMR0 when the prescaler is
							;assigned to Timer0 will clear the prescaler count
			
			BCF		INTCON,TMR0IF 	; LIMPA FLAG
			
			BSF		T0CON,TMR0ON	;RUN TIMER 0
			
TESTE:		BTFSS	INTCON,TMR0IF	;TESTA SE HOUVE ESTOURO DE TIMER
			GOTO	TESTE
			
			;	SE HOUVE ESTOURO DE TIMER
			MOVLW	(256 - 125); RECARREGA TM0L 
			MOVWF 	TMR0L				
			BCF		INTCON,TMR0IF ; LIMPA A FLAG DE ESTOURO DE TIMER			
			decfsz	NUM_MS  ; DECREMENTA CONTADOR DE MS			
			goto	TESTE	; RETORNA PARA TESTE até acabar a contagem
			
			BCF		T0CON,TMR0ON ; ACABOU CONTAGEM, PARA O TIMER				

			RETURN	 		
	end;
			

