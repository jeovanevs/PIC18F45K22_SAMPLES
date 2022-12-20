; Disciplina Microcontroladores
; Autor: Fulano
;
; MCU: PIC18F45k22	clock: 8MHz		Tcy:0.5us
;
; Programas exemplo
;
; versão: 0.1 - data: 30/11/2022
;--------------------------------------------

	list  p=18f45k22, r=dec ; indica o microcontrolador utilizado e o radix padrão

;-------- Arquivos incluídos no projeto ---
	#include p18f45k22.inc ; definições dos registradores

;--- configura Fuse bits (bits de configuração) ---
	config 	FOSC=HSMP 	; HS oscillator (medium power 4-16 MHz)
	config 	WDTEN=OFF	; desabilitado o watchdo timer , 
	config 	PWRTEN=ON	; power-up timer bit abilitado
	config 	CP0=OFF	; Code protection Block 0 disabled, 
	config 	CP1=OFF	; Code protection Block 1 disabled
	config 	CP2=OFF	; Code protection Block 2 disabled, 
	config 	CP3=OFF	; Code protection Block 3 disabled
	

;--- Saidas
	; DEFINIÇÕES DO DISPLAY 7-SEG
	DISP7SEG 	equ		PORTD ; DISPLAY DE 7 SEG. CAT. COMUM  NA PORTA D
	DISP_MUX	equ		PORTA ; DIS0 - RA0, DIS1 - RA1, DIS2 - RA2,  DIS3 - RA3

	; DEFINIÇÕES DO TECLADO 4X4
	#define COLUNA0 PORTB,RB4
	#define COLUNA1 PORTB,RB5
	#define COLUNA2 PORTB,RB6
	#define COLUNA3 PORTB,RB7

;--- Entradas
	#define		botao		PORTC,RC0	; BOTÃO CONECTADO NA PORTA RC0
	
	; DEFINIÇÕES DO TECLADO 4X4
	#define LINHA0 PORTB,RB0
	#define LINHA1 PORTB,RB1
	#define LINHA2 PORTB,RB2
	#define LINHA3 PORTB,RB3

;--- variáveis
	CBLOCK	00h		; define as posições de memória a partir do end. definido
		R0
		; variáveis utilizadas na subrotina de atraso
		COUNTER1 
		COUNTER2
		NUM_MS
		;------------------------
		
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
	; Inicializando Portas de entrada e saída
		;MOVLB 	0xF 	; Set BSR for banked SFRs
		BANKSEL ANSELA	; SELECIONA BANCO DE MEMÓRIA DO REG. ANSELD
	
		; PortA
		CLRF 	LATA 	; Initialize PORT by clearing output data latches	
		CLRF 	ANSELA 	; Configure I/O for digital inputs	
		BCF 	TRISA,0	; CONFIGURA RA0 COMO SAÍDA
	
		; PortB
		CLRF 	LATB 	; Initialize PORT by clearing output data latches	
		CLRF 	ANSELB 	; Configure I/O for digital inputs	
		MOVLW 	0Fh 	; Value used to initialize data direction
		MOVWF 	TRISB 	; colunas como saídas e linhas como entradas
	
	
		; PortD
		CLRF 	LATD 	; Initialize PORT by clearing output data latches	
		CLRF 	ANSELD 	; Configure I/O for digital inputs	
		MOVLW 	00h 	; Value used to initialize data direction
		MOVWF 	TRISD 	; CONFIGURA PORT COMO SAÍDA PARA O DISPLAY		
	
	; VALORES INICIAIS
		BSF		DISP_MUX,0 ;ativa display 0
		
		;R0 = -1;           
		MOVLW       255        
		MOVWF       R0
		

	;*****************************************						
loop:			
		RCALL       le_teclado_debounce
;	if (R0 != -1) {
		MOVLW       255
		CPFSLT		R0 
		BRA			igual
	;	DISP = catodo[R0];
		MOVF	R0, W ; diferente
		CALL	TAB7SEG
		MOVWF	DISP7SEG
	;	PORTD.B7 = 1;
		BSF 	DISP7SEG, 7
	;	Delay_ms(100);
		MOVLW	100
		CALL 	delay_ms
	;	PORTD.B7 = 0;
		BCF		DISP7SEG, 7
	;	Delay_ms(250);
		MOVLW	250
		CALL 	delay_ms
		BRA		fim_main		
;	} else PORTD.B7 = 0;
igual:
		BCF         DISP7SEG, 7 ; apaga ponto decimal
				
fim_main:
		goto 	loop		;volta para label loop	


;*********************** SUBROTINAS******************************
;----------------------------------------------
;Nome: delay_ms
;Descrição: Espera X ms @ Tcy=500ns
;Param. Entrada: WREG
;Param. Saída: nenhum
;Altera: WREG, NUM_MS, COUNTER2, COUNTER1
;----------------------------------------------
delay_ms:	
			movwf	NUM_MS
			
loop3:
			movlw	.4
			movwf	COUNTER2
loop2:
			movlw	.165	 ;1cm 
			movwf	COUNTER1 ;1cm
loop1:		;decfsz gasta 1cm para decrementar, (1cm)
			; se seguido de instrução de 1 palavra ele gasta mais 1cm para skip, (2 cm)
			; se seguido de uma instrução de 2 palavras ele gasta mais 2cm para. (3 cm)
			decfsz	COUNTER1 ; 1 cm * counter1
			goto 	loop1	 ; 2 cm	* (counter1 - 1) + 2 skip
							 ; ---------------------------------
							 ; 3 cm * (counter1 -1) + (1 + 2)  = 3 cm * counter1 - 3 + 3
							 ; T1 = (3cm * counter1) ciclos de máquina			
			decfsz	COUNTER2 ; 1 cm
			goto	loop2	 ; 2 cm	; T2 = (5 cm + 2 + T1)*counter2 
			
			
			decfsz	NUM_MS  ; 1 cm
			goto	loop3	; 2 cm  
							;(2cm + (5 cm + T2) * num_ms + 2 (return) + 2 (call))
							; NUM_MS *(5 + (5 + 3*counter1)*counter2)+6 
							; NUM_MS*(5+4*(5+3*165))+6 = NUM_MS*2005+6
							; erro = (5*NUM_MS+6)*Tcy
			RETURN	 

;----------------------------------------------
;Nome: varre_tecla
;Descrição: Varre um teclado matricial 4x4 e retorna o valor da tecla em decimal
; obs.: linhas em pull down
;Param. Entrada: nenhum
;Param. Saída: R0
;Altera: WREG, R0, COLUNAs e LINHAs
;----------------------------------------------
	;	C0	C1	C2	C3
    ;L0	'1'	'2'	'3'	'A',
    ;L1	'4'	'5'	'6'	'B',
    ;L2	'7'	'8'	'9'	'C',
    ;L3	'*'	'0'	'#'	'D',
    
	; A = 10 (0x0A)	
	; B = 11 (0x0B)
	; C = 12 (0x0C)
	; D = 13 (0x0D)
	; # = 14 (0x0E)
	; * = 15 (0x0F)
	;NENHUMA TECLA = 0xFF
	
varre_tecla: ; 
	; testa C0L0
	BCF         COLUNA1 ;COLUNA1 = 0;
	BCF         COLUNA2; COLUNA2 = 0;
 	BCF         COLUNA3; COLUNA3 = 0;
	BSF         COLUNA0; COLUNA0 = 1; 

	; if(LINHA0==1) return 1;
	BTFSS       LINHA0 
	BRA         varre_C0_L1
	MOVLW       1
	MOVWF       R0 
	BRA         fim_varre_tecla
	
varre_C0_L1:
	; else if(LINHA1) return 4;
	BTFSS       LINHA1 
	BRA         varre_C0_L2
	MOVLW       4
	MOVWF       R0 
	BRA         fim_varre_tecla
	
varre_C0_L2:
	; else if(LINHA2) return 7;
	BTFSS       LINHA2 
	BRA         varre_C0_L3
	MOVLW       7
	MOVWF       R0 
	BRA         fim_varre_tecla
	
varre_C0_L3:
	; else if(LINHA3) return 0XF;
	BTFSS       LINHA3 
	BRA         varre_C1_L0
	MOVLW       15
	MOVWF       R0 
	BRA         fim_varre_tecla

varre_C1_L0:
	BCF         COLUNA2 ; COLUNA2 = 0;
	BCF         COLUNA3 ; COLUNA3 = 0;
	BCF         COLUNA0 ; COLUNA0 = 0;
	BSF         COLUNA1 ; COLUNA1 = 1;
; if(LINHA0==1) return 2;
	BTFSS       LINHA0 
	BRA         varre_C1_L1
	MOVLW       2
	MOVWF       R0 
	BRA         fim_varre_tecla
	
varre_C1_L1:
; else if(LINHA1) return 5;
	BTFSS       LINHA1 
	BRA         varre_C1_L2
	MOVLW       5
	MOVWF       R0 
	BRA         fim_varre_tecla
	
varre_C1_L2:
; else if(LINHA2) return 8;
	BTFSS       LINHA2 
	BRA         varre_C1_L3
	MOVLW       8
	MOVWF       R0 
	BRA         fim_varre_tecla
	
varre_C1_L3:
; else if(LINHA3) return 0;
	BTFSS       LINHA3 
	BRA         varre_C2_L0
	CLRF        R0 
	BRA         fim_varre_tecla
	
varre_C2_L0:
	BCF         COLUNA3 ; COLUNA3 = 0;
	BCF         COLUNA0 ; COLUNA0 = 0;
	BCF         COLUNA1 ; COLUNA1 = 0;
	BSF         COLUNA2 ; COLUNA2 = 1;

; if(LINHA0==1) return 3;
	BTFSS       LINHA0 
	BRA         varre_C2_L1
	MOVLW       3
	MOVWF       R0 
	BRA         fim_varre_tecla

varre_C2_L1:
; else if(LINHA1) return 6;
	BTFSS       LINHA1 
	BRA         varre_C2_L2
	MOVLW       6
	MOVWF       R0 
	BRA         fim_varre_tecla

varre_C2_L2:
; else if(LINHA2) return 9;
	BTFSS       LINHA2 
	BRA         varre_C2_L3
	MOVLW       9
	MOVWF       R0 
	BRA         fim_varre_tecla

varre_C2_L3:
; else if(LINHA3) return 0XE;
	BTFSS       LINHA3 
	BRA         varre_C3_L0
	MOVLW       14
	MOVWF       R0 
	BRA         fim_varre_tecla

varre_C3_L0:
	BCF         COLUNA0 ; COLUNA0 = 0;
	BCF         COLUNA1 ; COLUNA1 = 0;
	BCF         COLUNA2 ; COLUNA2 = 0;
	BSF         COLUNA3 ; COLUNA3 = 1;
; if(LINHA0==1) return 0xA;
	BTFSS       LINHA0 
	BRA         varre_C3_L1
	MOVLW       10
	MOVWF       R0 
	BRA         fim_varre_tecla

varre_C3_L1:
; else if(LINHA1) return 0XB;
	BTFSS       LINHA1 
	BRA         varre_C3_L2
	MOVLW       11
	MOVWF       R0 
	BRA         fim_varre_tecla

varre_C3_L2:
; else if(LINHA2) return 0XC;
	BTFSS       LINHA2 
	BRA         varre_C3_L3
	MOVLW       12
	MOVWF       R0 
	BRA         fim_varre_tecla

varre_C3_L3:
; else if(LINHA3) return 0XD;
	BTFSS       LINHA3 
	BRA         nenhuma_tecla
	MOVLW       13
	MOVWF       R0 
	BRA         fim_varre_tecla
	
nenhuma_tecla:
; return -1;
	MOVLW       255
	MOVWF       R0 
; }
fim_varre_tecla:
	RETURN      0 	; RETURN {s}. If ‘s’= 1, the contents of the shadow registers,
					;	WS, STATUSS and BSRS, are loaded into their corresponding 
					;	registers, W, STATUS and BSR. If ‘s’ = 0, no update of these
					;	registers occurs (default).
					
; end of _varre_tecla

;----------------------------------------------
;Nome: le_teclado_debounce
;Descrição: Lê o teclado com debounce, retorna um inteiro correspondente 
;				ao valor teclado ou, se nada foi teclado, retorna o valor -1
; obs.: utiliza a subrotina varre_tecla e delay_ms
;Param. Entrada: nenhum
;Param. Saída: R0
;Altera: WREG, R0, COLUNAs e LINHAs
;----------------------------------------------
le_teclado_debounce:
; if (varre_tecla()!= -1){
	RCALL       varre_tecla
	MOVF        R0, W 
	XORLW       255
	BZ          nada_teclado
; Delay_100ms(); // Durante a varredura do teclado considerar um tempo de debouncing de 100ms
	MOVLW		100
	RCALL       delay_ms
; return varre_tecla();
	RCALL       varre_tecla
	BRA         fim_varre_tecla
; }
nada_teclado:
; return -1 ;
	MOVLW       255
	MOVWF       R0 
; }
fim_le_teclado:
	RETURN      0
; end of _le_teclado

		
; **************LOOKUP TABLES
;The offset value (in WREG) specifies the number of
;bytes that the program counter should advance and
;should be multiples of two (LSb = 0).
TAB7SEG:  ;
	RLNCF	WREG ; multiplica o offset por 2 (usar isso apenas na família 18F)
	addwf PCL	;soma o offset ao Program Counter para definir a próxima instrução
	retlw b'00111111'    ;digit 0
	retlw b'00000110'    ;digit 1
	retlw b'01011011'    ;digit 2
	retlw b'01001111'    ;digit 3
	retlw b'01100110'    ;digit 4
	retlw b'01101101'    ;digit 5
	retlw b'01111101'    ;digit 6
	retlw b'00000111'    ;digit 7
	retlw b'01111111'    ;digit 8
	retlw b'01101111'    ;digit 9 
	retlw b'01110111'	 ;digit A
	retlw b'01111100'	 ;digit B	
	retlw b'00111001'	 ;digit C
	retlw b'01011110'	 ;digit D
	retlw b'01111001'	 ;digit E
	retlw b'01110001'	 ;digit F
	; a mesma tabela poderia ter sido feita com a diretiva DT
	;dt 3Fh, 06h, 5Bh, 4Fh, 66h, 6Dh, 7Bh, 07h, 7Fh, 6Fh, 77h, 7Ch, 39h, 5Eh, 79h, 71h

		
		
	end;
			

