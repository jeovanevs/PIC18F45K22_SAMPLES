; Programa que soma 2 inteiros de 8 bits em assembly
; Processador: PIC18F45K22
; Clock: 8MHz

; Atribuindo nomes das variáveis aos endereços de mem. RAM
	R0 EQU 00H
	R1 EQU 01H
	R2 EQU 02H

; Início do programa
INICIO:
	MOVLW	H'38'
	MOVWF	R0
	
	MOVLW	0X2F
	MOVWF	R1
	
	MOVF	R0,W
	ADDWF	R1,W
	MOVWF	R2
	
	GOTO	$
	END
	