; Programa que toca a nota lá no buzzer quando INT0 é acionada.
; 	Fosc = 8MHz

	list p=18f45k22				; indica o microcontrolador utiizado para o MPASM
	#include<p18f45k22.inc>		; inclui as definições de registradores do PIC18F45k22
; --------- FUSE Bits ---------
	CONFIG		WDTEN=OFF		; desliga watchdog timer
	CONFIG		FOSC=HSMP 		; HS oscillator (medium power 4-16 MHz)
	CONFIG		PWRTEN=ON		; power-up timer bit habilitado
	CONFIG		CP0=OFF					; code protection block 0 disabled
	CONFIG		CP1=OFF					; code protection block 1 disabled
	CONFIG		CP2=OFF					; code protection block 2 disabled
	CONFIG		CP3=OFF					; code protection block 3 disabled
; --------- Saídas ---------
	#define		buzzer		PORTE,RE1	; buzzer conectado na porta RE1
; --------- Entradas ---------
	#define		botao		PORTB,RB0	; botao conectado na porta RC0
; --------- Variáveis ---------
	cblock		H'60'					; aloca as variáveis após a posição de memória 60h
	; variáveis para armazenar os dados antes da interrupção
		bsr_temp
		w_temp							; registrador para armazenar o conteúdo temporário de work (w)
		status_temp					 	; registrador para armazenar o conteúdo temporário de status
	endc
; --------- Vetor de Reset ---------
	org			H'00'					; inicio da memória de programa
	goto		inicio					; vai para inicio do programa após os vetores de interruções
; --------- Vetor de Interrupção ---------
	org			H'08'					; high-priority interrupt vector
	goto		isr					     ; vai para isr
	org			H'18'				   	; low-priority interrupt vector
	retfie
; ====================================================================================================== 
	org			H'01A'					; define endereço de início
inicio:
	banksel		ANSELB					; seleciona o banco onde está o registrador ANSELB
	setf		ANSELB					; configura os pinos A/D no PORTB apenas para digital
	clrf		ANSELE				
	banksel		0						; retornando para o banco 0 (opcional utilizando banco de acesso)
	movlw		H'FF'
	movwf		TRISB
	movlw		H'8E'
	movwf		TRISE					; definindo somente RE1 como saída
	clrf 		PORTE					; iniciando pinos da porta E em nível baixo
	; configuraões do timer0 - 8 bits
	bcf			T0CON,TMR0ON		   ; TIMER0 inicia desligado									(0)
	bsf			T0CON,T08BIT			  ; habilitando TIMER0 de 8 btis					        (1)
	bcf			T0CON,T0CS				; TIME0 conta pulsos do oscilador 			         (0)
	bsf			T0CON,T0SE				 ; tipo de ativação (borda de subida ou descida) (1)
	bcf			T0CON,PSA			      ; ativa prescaler para o TIMER0					       (0)
	bcf			T0CON,T0PS2				; razão do prescaler						                    (0)
	bsf			T0CON,T0PS1				; razão do prescaler						                    (1)
	bsf			T0CON,T0PS0				; razão do prescaler						                    (1)
	; T0CON ---- B'01010011' 
	; configurações do INTCON
				 
	bsf			INTCON,TMR0IE			; overflow do TIMER0 habilitado 				(1)
	bsf			INTCON,INT0IE			; habilita interrupção externa					    (1)
	bcf			INTCON2,INTEDG0			; borda de subida (1) ou descida (0)	  (0)
	bsf			INTCON,GIE				; interrupção global habilitada	
	
loop:

	goto loop 							; Aguarda as interrupções
; =================================================================================================================== 

; -------------------- Rotina de Interrupção --------------------
isr:
; ---------- Salva Contexto ----------
	movwf 	  	w_temp					; copia o conteúdo de work para w_temp
	movff		STATUS,status_temp		; move o conteúdo de STATUS para status_temp
	movff		BSR,bsr_temp			; move o contúdo de BSR para bsr_temp
; ---------- Trata Interrupção ----------
	btfsc		INTCON,INT0IF			; houve interrupção externa (botao foi pressionado)?
	goto		isr_RB0				         ; Sim, vai para rotina de interrupção do botao	
	btfsc		INTCON,TMR0IF			; houve overflow do TIMER0 (temporizador estourou)?
	goto		isr_TIMER0			       ; Sim, vai para rotina de interrupção do TIMER0 (limpar flag)
; ---------- Recupera Contexto e sai da interrupção ----------
ret:
	movff		bsr_temp,BSR		    ; restaura o BSR
	movf		w_temp,w				; restaura WREG
	movff		status_temp,STATUS		; restaura STATUS
	retfie								; retorna ao endereço de chamanda
; ----- ISR INT0 ---------	
isr_RB0:

	btg			T0CON,TMR0ON			; TIMER0 é ligado
	bcf			INTCON,INT0IF			; Limpa a flag de interrupção
	goto		ret						; prepara para sair da interrupção
; ----- ISR TMR0						                  
isr_TIMER0:
	movlw		D'114'
	movwf		TMR0L					; Recarrega o timer
	btg			buzzer				    ; altera bit de RE1, 0 para 1
	bcf			INTCON,TMR0IF			; limpa a flag TMR0IF
	goto 		ret						; prepara para sair da interrupção

; ===================================================================================================================
	end