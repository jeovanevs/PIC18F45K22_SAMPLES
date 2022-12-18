; Exercício Delay por software
;
; * Faça uma sobrotina para atraso de tempo de 200ms
; * Faça a documentação do subrotina
; * Utilizando essa subrotina, pisque um led na porta B
; * Altere a subrotina para que ela gere atrasos múltiplos de 1ms e aceite como 
;	parâmetro de entrada o valor de atraso desejado.
; * Com essa subrotina projete um semáforo simples com tempo em vermelho de 
;	500ms, amarelo 100 ms e verde de 250 ms. 
;;
; Processador: PIC18F45K22
; Clock: 8MHz
;******************************************************************************

	;processor PIC18F45K22
	;RADIX	DEC
	list	p=PIC18F45K22, r=DEC
	
;-------- Arquivos incluídos no projeto ---
	#include p18f45k22.inc ; definições dos registradores

;--- configuração dos Fuse bits (bits de configuração) ---
	config FOSC=HSMP ; HS oscillator (medium power 4-16 MHz)
	config 	WDTEN=OFF	; desabilitado o watchdo timer , 
	config 	PWRTEN=ON	; power-up timer bit abilitado

;--- Saidas
	#define		LED		PORTB,RB0	;LED conectado na porta RB0

; Atribuindo nomes das variáveis aos endereços de mem. RAM

CBLOCK 00H
	COUNTER1
	COUNTER2
	COUNTER3
ENDC

	
;--------------- Vetor de Reset ------------------------------------------
	ORG 00H	; End inicial da mem. de prog.
INICIO:
;------ Programa principal

;------------ Configurações iniciais ----------------
; Inicializando Portas de entrada e saída
	;MOVLB 	0xF 	; Set BSR for banked SFRs
	BANKSEL ANSELB	; SELECIONA BANCO DE MEMÓRIA DO REG. ANSELB
		   
; PortB
	CLRF 	LATB 	; Initialize PORTB by clearing output data latches	
	CLRF 	ANSELB 	; Configure I/O for digital inputs	
	MOVLW 	00h 	; Value used to initialize data direction
	MOVWF 	TRISB 	; CONFIGURA PORTB COMO SAÍDA


;----------- Programa principal	
LOOP:	
	
	CALL	delay_200ms
	BTG		LED

	GOTO	LOOP

;*********************** SUBROTINAS******************************
;----------------------------------------------
;Nome: delay_200ms
;Descrição: Espera 200 ms
;Param. Entrada: nenhum
;Param. Saída: nenhum
;Altera: WREG, NUM_MS, COUNTER2, COUNTER1
;----------------------------------------------
delay_200ms:

	MOVLW	200
	MOVWF	COUNTER3
LOOP3:
; DELAY DE 1 MS
	MOVLW	4
	MOVWF	COUNTER2
LOOP2:
	MOVLW	165
	MOVWF	COUNTER1 
	
LOOP1:
	DECFSZ	COUNTER1
	GOTO	LOOP1 ;  165*3 -1 = 494  
	
	DECFSZ	COUNTER2
	GOTO	LOOP2 ; COUNTER2 * (494 + 2 + 3) - 1 =  
	
	DECFSZ	COUNTER3
	GOTO	LOOP3 ;


	RETURN	 

	END