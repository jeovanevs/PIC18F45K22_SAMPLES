; Exemplo Display 7 segmentos
; 
; Processador: PIC18F45K22
; Clock: 8MHz
;******************************************************************************

	;processor PIC18F45K22
	;RADIX	DEC
	list	p=PIC18F45K22, r=DEC
	
;-------- Arquivos incluídos no projeto ---
	#include p18f45k22.inc ; definições dos registradores

;--- configuração dos Fuse bits (bits de configuração) ---
	config 	FOSC=HSMP 	; HS oscillator (medium power 4-16 MHz)
	config 	WDTEN=OFF	; desabilitado o watchdo timer , 
	config 	PWRTEN=ON	; power-up timer bit abilitado

;--- Saidas
	DISP7SEG 	equ		PORTD ; DISPLAY DE 7 SEG. CAT. COMUM  NA PORTA D
	DISP_MUX	equ		PORTA ; DIS0 - RA0, DIS1 - RA1, DIS2 - RA2,  DIS3 - RA3

; Atribuindo nomes das variáveis aos endereços de mem. RAM
CBLOCK 00H
	; variáveis utilizadas na subrotina de atraso
	COUNTER1
	COUNTER2
	NUM_MS
	;-----------------
	CONT ; contador para o display 7Seg
	AUX	; variável auxiliar para mostrar apenas o primeiro Nibble do contador
ENDC

	
;--------------- Vetor de Reset ------------------------------------------
	ORG 00H	; End inicial da mem. de prog.
	GOTO INICIO
	
; -------- VETOR DE INTERRUPÇÃO
	ORG 008H ; VETOR DE ALTA PRIORIDADE
	RETFIE
	
	ORG 18H ; VETOR DE BAIXA PRIORIDADE
	RETFIE
	

;------ Programa principal
	ORG 20H
INICIO:	
;------------ Configurações iniciais ----------------
; Inicializando Portas de entrada e saída
	;MOVLB 	0xF 	; Set BSR for banked SFRs
	BANKSEL ANSELA	; SELECIONA BANCO DE MEMÓRIA DO REG. ANSELD

; PortA
	CLRF 	LATA 	; Initialize PORT by clearing output data latches	
	CLRF 	ANSELA 	; Configure I/O for digital inputs	
	MOVLW 	00h 	; Value used to initialize data direction
	MOVWF 	TRISA 	; CONFIGURA PORT COMO SAÍDA
		   
; PortD
	CLRF 	LATD 	; Initialize PORT by clearing output data latches	
	CLRF 	ANSELD 	; Configure I/O for digital inputs	
	MOVLW 	00h 	; Value used to initialize data direction
	MOVWF 	TRISD 	; CONFIGURA PORT COMO SAÍDA

	
;----------- Programa principal	
	CLRF	CONT		; inicializa contador em zero
	BSF		DISP_MUX,0	; ATIVANDO O DISPLAY 0
	MOVLW	B'00001111' ; Carregando a variável auxiliar com 0x0F
	MOVWF	AUX
LOOP:	
	MOVF	CONT,W	; WREG <- CONT
	ANDWF	AUX,W	; Zera o nibble mais significativo		
	CALL	TAB7SEG	; Carrega o valor da tabela para W
	MOVWF	DISP7SEG ; Atualiza o display
	INCF	CONT	; incrementa o contador
		
	MOVLW	250
	CALL	delay_ms ; espera 250ms
	MOVLW	250
	CALL	delay_ms ; espera 250ms
	
	GOTO	LOOP

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

	
	
	
;        DEFINIÇÕES DOS DÍGITOS UTILIZADOS NOS DISPLAYS DE 7 SEGMENTOS
;        PORT.Bit    - Segmento do Display
;
;            Px.0    - a
;            Px.1    - b
;            Px.2    - c
;            Px.3    - d
;            Px.4    - e
;            Px.5    - f
;            Px.6    - g
;            Px.7    - DP
;
;            Composição dos números decimais utilizando a especificação acima:
;
;                                                                    a
;                                                                 --------
;                                                                |        |
;                                                              f |        | b 
;                                                                |    g   |
;                                                                ---------
;                                                                |        |
;                                                              e |        | c 
;                                                                |    d   |
;                                                                  -------  
;
; SEGMENTOS:                                   g f e | d c b a    Código Hexadecimal
;-----------------------------------------
; Dígito:                  apagado             0 0 0 | 0 0 0 0         = 0x00
;                              0               0 1 1 | 1 1 1 1         = 0x3f
;                              1               0 0 0 | 0 1 1 0         = 0x06
;                              2               1 0 1 | 1 0 1 1         = 0x5b
;                              3               1 0 0 | 1 1 1 1         = 0x4f
;                              4               1 1 0 | 0 1 1 0         = 0x66
;                              5               1 1 0 | 1 1 0 1         = 0x6d
;                              6               1 1 1 | 1 1 0 0         = 0x7c
;                              7               0 0 0 | 0 1 1 1         = 0x07
;                              8               1 1 1 | 1 1 1 1         = 0x7f
;                              9               1 1 0 | 0 1 1 1         = 0x67
;
;                              A               1 1 1 | 0 1 1 1         = 0x77
;                              b               1 1 1 | 1 1 0 0         = 0x7c
;                              C               0 1 1 | 1 0 0 1         = 0x39
;                              D               1 0 1 | 1 1 1 0         = 0x5e
;                              E               1 1 1 | 1 0 0 1         = 0x79
;                              F               1 1 1 | 0 0 0 1         = 0x71
;=====                                        =====



;*********************** SUBROTINAS******************************
;----------------------------------------------
;Nome: delay_ms
;Descrição: Espera deterninado número de ms até no máximo 255 ms
;Param. Entrada: COUNTER3
;Param. Saída: nenhum
;Altera: WREG, NUM_MS, COUNTER2, COUNTER1
;----------------------------------------------
delay_ms:

	;MOVLW	200
	MOVWF	NUM_MS
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
	
	DECFSZ	NUM_MS
	GOTO	LOOP3 ;


	RETURN	 

	END