; Programa que toca a nota l� no buzzer quando INT0 � acionada.
; 	Fosc = 8MHz

	list p=18f45k22				; indica o microcontrolador utiizado para o MPASM
	#include<p18f45k22.inc>		; inclui as defini��es de registradores do PIC18F45k22
; --------- FUSE Bits ---------
	CONFIG		WDTEN=OFF		; desliga watchdog timer
	CONFIG		FOSC=HSMP 		; HS oscillator (medium power 4-16 MHz)
	CONFIG		PWRTEN=ON		; power-up timer bit habilitado
	CONFIG		CP0=OFF					; code protection block 0 disabled
	CONFIG		CP1=OFF					; code protection block 1 disabled
	CONFIG		CP2=OFF					; code protection block 2 disabled
	CONFIG		CP3=OFF					; code protection block 3 disabled
; --------- Sa�das ---------
	#define		buzzer		PORTE,RE1	; buzzer conectado na porta RE1
; --------- Entradas ---------
	#define		botao		PORTB,RB0	; botao conectado na porta RC0
; --------- Vari�veis ---------
	cblock		H'60'					; aloca as vari�veis ap�s a posi��o de mem�ria 60h
	; vari�veis para armazenar os dados antes da interrup��o
		bsr_temp
		w_temp							; registrador para armazenar o conte�do tempor�rio de work (w)
		status_temp					 	; registrador para armazenar o conte�do tempor�rio de status
	endc
; --------- Vetor de Reset ---------
	org			H'00'					; inicio da mem�ria de programa
	goto		inicio					; vai para inicio do programa ap�s os vetores de interru��es
; --------- Vetor de Interrup��o ---------
	org			H'08'					; high-priority interrupt vector
	goto		isr					     ; vai para isr
	org			H'18'				   	; low-priority interrupt vector
	retfie
; ====================================================================================================== 
	org			H'01A'					; define endere�o de in�cio
inicio:
	banksel		ANSELB					; seleciona o banco onde est� o registrador ANSELB
	setf		ANSELB					; configura os pinos A/D no PORTB apenas para digital
	clrf		ANSELE				
	banksel		0						; retornando para o banco 0 (opcional utilizando banco de acesso)
	movlw		H'FF'
	movwf		TRISB
	movlw		H'8E'
	movwf		TRISE					; definindo somente RE1 como sa�da
	clrf 		PORTE					; iniciando pinos da porta E em n�vel baixo
	; configura�es do timer0 - 8 bits
	bcf			T0CON,TMR0ON		   ; TIMER0 inicia desligado									(0)
	bsf			T0CON,T08BIT			  ; habilitando TIMER0 de 8 btis					        (1)
	bcf			T0CON,T0CS				; TIME0 conta pulsos do oscilador 			         (0)
	bsf			T0CON,T0SE				 ; tipo de ativa��o (borda de subida ou descida) (1)
	bcf			T0CON,PSA			      ; ativa prescaler para o TIMER0					       (0)
	bcf			T0CON,T0PS2				; raz�o do prescaler						                    (0)
	bsf			T0CON,T0PS1				; raz�o do prescaler						                    (1)
	bsf			T0CON,T0PS0				; raz�o do prescaler						                    (1)
	; T0CON ---- B'01010011' 
	; configura��es do INTCON
				 
	bsf			INTCON,TMR0IE			; overflow do TIMER0 habilitado 				(1)
	bsf			INTCON,INT0IE			; habilita interrup��o externa					    (1)
	bcf			INTCON2,INTEDG0			; borda de subida (1) ou descida (0)	  (0)
	bsf			INTCON,GIE				; interrup��o global habilitada	
	
loop:

	goto loop 							; Aguarda as interrup��es
; =================================================================================================================== 

; -------------------- Rotina de Interrup��o --------------------
isr:
; ---------- Salva Contexto ----------
	movwf 	  	w_temp					; copia o conte�do de work para w_temp
	movff		STATUS,status_temp		; move o conte�do de STATUS para status_temp
	movff		BSR,bsr_temp			; move o cont�do de BSR para bsr_temp
; ---------- Trata Interrup��o ----------
	btfsc		INTCON,INT0IF			; houve interrup��o externa (botao foi pressionado)?
	goto		isr_RB0				         ; Sim, vai para rotina de interrup��o do botao	
	btfsc		INTCON,TMR0IF			; houve overflow do TIMER0 (temporizador estourou)?
	goto		isr_TIMER0			       ; Sim, vai para rotina de interrup��o do TIMER0 (limpar flag)
; ---------- Recupera Contexto e sai da interrup��o ----------
ret:
	movff		bsr_temp,BSR		    ; restaura o BSR
	movf		w_temp,w				; restaura WREG
	movff		status_temp,STATUS		; restaura STATUS
	retfie								; retorna ao endere�o de chamanda
; ----- ISR INT0 ---------	
isr_RB0:

	btg			T0CON,TMR0ON			; TIMER0 � ligado
	bcf			INTCON,INT0IF			; Limpa a flag de interrup��o
	goto		ret						; prepara para sair da interrup��o
; ----- ISR TMR0						                  
isr_TIMER0:
	movlw		D'114'
	movwf		TMR0L					; Recarrega o timer
	btg			buzzer				    ; altera bit de RE1, 0 para 1
	bcf			INTCON,TMR0IF			; limpa a flag TMR0IF
	goto 		ret						; prepara para sair da interrup��o

; ===================================================================================================================
	end