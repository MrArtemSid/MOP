;***************************************************************************************************
; MLAB1.ASM - �祡�� �ਬ�� ��� �믮������ 
; ������୮� ࠡ��� N1 �� ��設��-�ਥ��஢������ �ணࠬ��஢����
; 10.09.02: ������ �.�.
;***************************************************************************************************
        .MODEL SMALL
        .STACK 200h
	.386
;       �ᯮ������� ������樨 ����⠭� � ����ᮢ
        INCLUDE MLAB1.INC	
        INCLUDE MLAB1.MAC

; ������樨 ������
        .DATA    
SLINE	DB	78 DUP (CHSEP), 0
REQ	DB	"������� �.�.: ",0FFh
MINIS	DB	"������������ ����������� ���������� ���������",0
ULSTU	DB	"����������� ��������������� ����������� �����������",0
DEPT	DB	"��䥤� ���᫨⥫쭮� �孨��",0
MOP	DB	"��設��-�ਥ��஢����� �ணࠬ��஢����",0
LABR	DB	"������ୠ� ࠡ�� N 1",0
REQ1    DB      "���������(-),�᪮���(+),���(ESC),������ୠ�(f)?",0FFh
TACTS   DB	"�६� ࠡ��� � ⠪��: ",0FFh
EMPTYS	DB	0
BUFLEN = 70
BUF	DB	BUFLEN
LENS	DB	?
SNAME	DB	BUFLEN DUP (0)
PAUSE	DW	0, 0 ; ����襥 � ���襥 ᫮�� ����প� �� �뢮�� ��ப�
TI	DB	LENNUM+LENNUM/2 DUP(?), 0 ; ��ப� �뢮�� �᫠ ⠪⮢
                                          ; ����� ��� ࠧ����⥫��� "`"

var_Z db 0Dh, 0Ah, "Z = f17 ? X/4 + Y*2 : X/8 - Y/2", '$'; z7 = !z4; z2 &= z8; z2 &= z8; z6 |= z4", '$'
var_F db 0Dh, 0Ah, "f17 = x1x3 | x2x3 | !x1!x3 | !x1!x2x3 | x1x2!x3", '$'
inp_X db 0Dh, 0Ah, "Input X (20 bits): $"
inp_Y db "Input Y (20 bits): $"
out_F db  "F = ", '$'
out_Z db 0Dh, 0Ah, "Z = X/4 + Y*2", '$'
out_Z1 db 0Dh, 0Ah, "Z = X/8 - Y/2", '$'
out_Z_template db 0Dh, 0Ah, "Z = ", '$'
X dd 0
Y dd 0
X1 dd 0
X2 dd 0
X3 dd 0
X4 dd 0
F1 dd 0
Z dd 0

div10 dd 2

;========================= �ணࠬ�� =========================
        .CODE
; ����� ���������� ��ப� LINE �� ����樨 POS ᮤ�ন�� CNT ��ꥪ⮢,
; ����㥬�� ���ᮬ ADR �� �ਭ� ���� �뢮�� WFLD
BEGIN	LABEL	NEAR
	; ���樠������ ᥣ���⭮�� ॣ����
	MOV	AX,	@DATA
	MOV	DS,	AX
	; ���樠������ ����প�
	MOV	PAUSE,	PAUSE_L
	MOV	PAUSE+2,PAUSE_H
	PUTLS	REQ	; ����� �����
	; ���� �����
	LEA	DX,	BUF
	CALL	GETS	
@@L:	; 横���᪨� ����� ����७�� �뢮�� ���⠢��
	; �뢮� ���⠢��
	; ��������� ������� ������ �����
	FIXTIME
	PUTL	EMPTYS
	PUTL	SLINE	; ࠧ����⥫쭠� ���
	PUTL	EMPTYS
	PUTLSC	MINIS	; ��ࢠ� 
	PUTL	EMPTYS
	PUTLSC	ULSTU	;  �  
	PUTL	EMPTYS
	PUTLSC	DEPT	;   ��᫥���騥 
	PUTL	EMPTYS
	PUTLSC	MOP	;    ��ப�  
	PUTL	EMPTYS
	PUTLSC	LABR	;     ���⠢��
	PUTL	EMPTYS
	; �ਢ���⢨�
	PUTLSC	SNAME   ; ��� ��㤥��
	PUTL	EMPTYS
	; ࠧ����⥫쭠� ���
	PUTL	SLINE
	; ��������� ������� ��������� ����� 
	DURAT    	; ������ ����祭���� �६���
	; �८�ࠧ������ �᫠ ⨪�� � ��ப� � �뢮�
	LEA	DI,	TI
	CALL	UTOA10	
	PUTL	TACTS
	PUTL	TI      ; �뢮� �᫠ ⠪⮢
	; ��ࠡ�⪠ �������
	PUTL	REQ1
	CALL	GETCH
	CMP	AL,	'-'    ; 㤫������ ����প�?
	JNE	CMINUS
	INC	PAUSE+2        ; �������� 65536 ���
	JMP	@@L
CMINUS:	CMP	AL,	'+'    ; 㪮�稢��� ����প�?
	JNE	LAB_START
	CMP	WORD PTR PAUSE+2, 0		
	JE	BACK
	DEC	PAUSE+2        ; 㡠���� 65536 ���
BACK:	JMP	@@L

;===== ��������� ����� ����� =====
INPUT_NUMBER PROC NEAR
INPUT_NUMBER_RETRY:
    ; �뢮� �ਣ��襭��
    mov AH, 09h
    int 21h

    ; ����ன�� �����
    xor ebx, ebx
    mov AH, 01h
    mov CX, 20

INPUT_LOOP:
    int 21h
    cmp al, 0Dh          ; Enter?
    JE INPUT_END
    shl ebx, 1
    CMP AL, '0'
    JE LOOP_CONTINUE
    CMP AL, '1'
    JNE INPUT_ERROR
    ADD ebx, 1

LOOP_CONTINUE:
    DEC CX
    JNZ INPUT_LOOP

INPUT_END:
    cmp CX, 20
    JE INPUT_NUMBER_RETRY
    JMP INPUT_EXIT

INPUT_ERROR:
    JMP INPUT_NUMBER_RETRY

INPUT_EXIT:
    RET
ENDP INPUT_NUMBER

PRINT PROC
	mov ECX, 20
	shl EDX, 12


; 横���᪨� �뢮� �᫠ Z
OUTPUT_CYCLE:
	shl EDX, 1
	JC P1
	mov BL, '0'
	JMP PRINT_ELEMENT


P1:
	mov BL, '1'


PRINT_ELEMENT:
	mov ah, 02h
	mov dl, bl
	int 21h
	dec ecx
	cmp ecx, 0
	jne OUTPUT_CYCLE


	RET
ENDP PRINT


LAB_START:
    cmp al, 'f'
    jne CEXIT

	xor ebx, ebx        ; ���㫥��� EBX
	xor eax, eax        ; ���㫥��� EAX

	; �뢮� �㦥���� ᮮ�饭��
	mov ah, 09h         ; �㭪�� DOS 09h - �뢮� ��ப�
	lea edx, var_Z      ; ����㧪� ���� ��ப� var_Z
	int 21h             ; �맮� ���뢠��� ��� �뢮��
	lea edx, var_F      ; ����㧪� ���� ��ப� var2
	int 21h             ; �뢮� ��ன ��ப�
	
    ; ���� X
    lea edx, inp_X
    call INPUT_NUMBER
    mov X, ebx

    ; ���� Y
    lea edx, inp_Y
    call INPUT_NUMBER
    mov Y, ebx

    ; �஢�ઠ �������権 ��� F1
    xor eax, eax
    mov ah, 09h
    lea edx, out_F
    INT 21h

    ; ���᫥��� ���祭�� �㭪樨 F17
    xor ebx, ebx
    mov ebx, X
    and ebx, 1110b
    cmp ebx, 0010b
    je SET_F0
    mov F1, '1'
    jmp PRINT_F

SET_F0:
    mov F1, '0'

PRINT_F:
    mov edx, F1
    mov ah, 02h
    int 21h

    ; �뢮� ���室�饩 �㭪樨 Z
    cmp F1, '0'
    je LOAD_Z_FALSE
    lea edx, out_Z
    jmp PRINT_Z_TEMPLATE

LOAD_Z_FALSE:
    lea edx, out_Z1

PRINT_Z_TEMPLATE:
    mov ah, 09h
    int 21h

    xor eax, eax
    xor ebx, ebx
   
    ; ���᫥��� ���室�饩 �㭪樨 Z
CALC_Z: ;Z = X/4 + Y*2
    cmp F1, '0'
    je CALC_Z_FALSE
    mov eax, X
    shr eax, 2 ; X / 4
    mov ebx, Y
    shl ebx, 1 ; Y * 2
    add eax, ebx ; X / 4 + Y * 2
    mov Z, eax
    jmp PRINT_Z

CALC_Z_FALSE: ; Z = X/8 - Y/2
    mov eax, X
    shr eax, 3 ; X / 8
    mov ebx, Y
    shr ebx, 1 ; Y / 2
    sub eax, ebx ; X / 8 - Y / 2
    mov Z, eax

    ; �뢮� ����砫쭮� Z
PRINT_Z:
	xor edx, edx

	lea edx, out_Z_template
	mov ah, 09h
	INT 21h


	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx


	mov edx, Z
	call PRINT


; �ਬ������ ᫥����� ��ࠦ����
    ;z7 = !z4; 
    ;z2 &= z8; 
    ;z6 |= z4
    xor ebx, ebx
    mov ebx, Z

CALC_Z_PAIR1: ;z7 = !z4
    bt ebx, 4                ; �஢��塞 (z4)
    jc CLEAR_BIT4
    bts ebx, 7               ; ��⠭����� ��� (z7)
    jmp CALC_Z_PAIR2

CLEAR_BIT4:
    btr ebx, 7              ; ����� ��� (z7)

CALC_Z_PAIR2: ;z2 &= z8
    bt ebx, 8                ; �஢��塞 (z8)
    jc SET_BIT2              ; �᫨ z8 ��⠭�����, ���室�� � ��⠭���� ��� z2
    btr ebx, 2               ; ����뢠�� ��� z2, �᫨ z8 �� ��⠭�����
    jmp CALC_Z_PAIR3

SET_BIT2:
    bts ebx, 2               ; ��⠭�������� ��� z2, �᫨ z8 ��⠭�����

CALC_Z_PAIR3: ;z6 |= z4
    bt ebx, 4                ; �஢��塞 (z4)
    jc SET_BIT6              ; �᫨ z4 ��⠭�����, ���室�� � ��⠭���� ��� z6
    jmp PRINT_NEW_Z           ; �᫨ z4 �� ��⠭�����, ���室�� � �����襭��

SET_BIT6:
    bts ebx, 6               ; ��⠭�������� ��� z6, �᫨ z4 ��⠭�����

; �뢮� ����������� Z
PRINT_NEW_Z:
    mov Z, ebx               ; ���࠭��� �⢥�
	xor edx, edx

	lea edx, out_Z_template
	mov AH, 09h
	int 21h

	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx


	mov edx, Z
	call PRINT


CEXIT:	CMP	AL,	CHESC	
	JE	@@E
	TEST	AL,	AL
	JNE	BACK
	CALL	GETCH
	JMP	@@L
	; ��室 �� �ணࠬ��
@@E:	EXIT	
        EXTRN	PUTSS:  NEAR
        EXTRN	PUTC:   NEAR
	EXTRN   GETCH:  NEAR
	EXTRN   GETS:   NEAR
	EXTRN   SLEN:   NEAR
	EXTRN   UTOA10: NEAR
	END	BEGIN
