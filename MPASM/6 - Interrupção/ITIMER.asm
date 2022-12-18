; Disciplina Microcontroladores
; Autor: Fulano
;
; MCU: PIC18F45k22	clock: 8MHz
;
; Programas exemplo interrução externa e timer 0 em 16 bits
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
	CONFIG	PBADEN=OFF; DESABILITA CONVERSOR AD PORTB
	
;--- Saidas
	#define		buzzer		LATE,RE1	;LEDs conectados na porta E	

;--- Entradas
	#define		botao		PORTB,RB0	; BOTÃO CONECTADO NA PORTA RC0

;--- variáveis
	CBLOCK	60h
		status_temp
		w_temp
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
		GOTO ISR_HIGH
		

	;---Low-Priority Interrupt Vector
	ORG		0018h
		RETFIE

;********* Define endereço de inicio
	ORG		001Ah
INICIO:
;------ Programa principal
	;************ Configurações iniciais ***********
			BANKSEL ANSELB 	;Seleciona o banco onde está o registrador ANSELB
							;Addresses F38h through F5Fh are also used by SFRs, but are not
							;part of the Access RAM. Users must always use the complete
							;address or load the proper BSR value to access these registers.
			CLRF ANSELB ; Configure A/D pins on PORTB for digital only
			CLRF ANSELE
			BANKSEL 0	; Retornando para o banco 0
			
			SETF TRISB ; All port B pins are configured as outputs
			BCF TRISE,RE1; COLOCA RE1 COMO SAÍDA
						
			CLRF PORTB 	; Initialize PORT B by clearing output data latches
			
			BCF	T0CON,TMR0ON ; DESLLIGAR TIMER 0			
			BCF T0CON,T08BIT ; 16-bit timer
			bcf T0CON,T0CS ; TMR0 counts pulses from oscillator
			bSf T0CON,PSA ; Prescaler is NOT assign to timer TMR0
			
			bsf T0CON,T0PS0 ; Prescaler rate is 1:256
			bsf T0CON,T0PS1
			bsf T0CON,T0PS2
			MOVLW HIGH(65536 - 2273)
			MOVWF TMR0H
			MOVLW LOW(65536 - 2273)
			MOVWF TMR0L
						
			bsf INTCON,TMR0IE ; TMR0 interrupt overflow enabled
			BCF INTCON2,INTEDG0; CONFIGURA INT0 COMO BORDA DESCIDA
			BSF	INTCON,INT0IE ; HABILITA INT0
			bsf INTCON,GIE ; Global interrupt enabled
						
loop:
			goto loop ; Remain here
								
			
	;*********************** INTERRUPT ROUTINE *********************************
ISR_HIGH
			BTFSC	INTCON,INT0IF
			GOTO	ISR_RB0
			BTFSC	INTCON,TMR0IF
			GOTO	ISR_TMR0
ISR_RB0:
			 movwf w_temp ; Saves value in register W
			 movf STATUS ; Saves value in register STATUS
			 movwf status_temp
			 
			 BTG T0CON,TMR0ON ; LIGA/DESLIGA TIMER 0 
			 
			 BCF INTCON,INT0IF ; LIMPA FLAG DE INTERRUPÇÃO
			 
			 movf status_temp,w ; STATUS is given its original content
			 movwf STATUS
			 swapf w_temp,f ; W is given its original content
			 swapf w_temp,w
			
			 retfie ; Return from interrupt routine
	
ISR_TMR0:
			 movwf w_temp ; Saves value in register W
			 movf STATUS ; Saves value in register STATUS
			 movwf status_temp
		
			 BTG buzzer ; Increments register PORTB by 1
			
			 bcf INTCON,TMR0IF ; Clears interrupt flag TMR0IF
			 
			 MOVLW HIGH(65536 - 2273 +15 +6)
			 MOVWF TMR0H
			 MOVLW LOW(65536 - 2273 +15 +6)
			 MOVWF TMR0L
			
			 movf status_temp,w ; STATUS is given its original content
			 movwf STATUS
			 swapf w_temp,f ; W is given its original content
			 swapf w_temp,w
			
			 ;bsf INTCON,GIE ; Global interrupt enabled
			 retfie ; Return from interrupt routine
;*******************************************************************************
		
	end ; End of program;
			

