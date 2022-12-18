;==========================================================
;              FEELT - UFU - Patos de Minas
;                Microprocessadores 2022/1 
;               <Nome do projeto/programa> 
;==========================================================
;   Versão : <número>  Data: <data> 
;   <descrição da finalidade e operação do programa> 
;   Cristal  <clock>  --  Ti = <tempo de instrução> 
;	Hardware: EasyPic_v7
;
;   <nome do aluno> < número de matrícula>
;==========================================================
#include <P18F45K22.INC> ; microcontrolador a ser utilizado 
CONFIG <opções>          ; configurações do programa 
    
; *** Variáveis 
    CBLOCK  20h 
        <variáveis> 
    ENDC 

; *** Definições de Hardware 

; *** Software 
    ORG 0000H   		; vetor de reset 

    GOTO 	INICIO 		; inicio do programa principal 

; *** Tratamento de interrupção 
    ORG 0008H 			; vetor de interrupção 
    
; 	<aqui deve estar o salvamento de contexto> 
; 	<aqui devem ser inseridas as rotinas de tratamento 
;					  de interrupções, quando houverem > 
; 	<aqui deve estar o retorno de contexto> 
    RETFIE 
    
; *** Rotina principal 
INICIO: 
    ; < aqui fica a inicialização> 
PRINCIPAL : 
    ; < a rotina principal fica aqui > 
    GOTO PRINCIPAL ; loop principal 

; *** Sub—Rotinas 
;	< as sub—rotinas podem ser inseridas aqui > 
;----------------------------------------------------------
<nome da sub-rotina>: 
; 	Descrição da função da sub—rotina
; 	Entrada: < parâmetros de entrada> 
; 	Saída: < parâmetros de saída > 

;	<aqui vem o código da sub—rotina 
	RETURN 
;----------------------------------------------------------	
	END ; FIM DO CÓDIGO 