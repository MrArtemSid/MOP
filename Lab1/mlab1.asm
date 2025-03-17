;***************************************************************************************************
; MLAB1.ASM - учебный пример для выполнения 
; лабораторной работы N1 по машинно-ориентированному программированию
; 10.09.02: Негода В.Н.
;***************************************************************************************************
        .MODEL SMALL
        .STACK 200h
	.386
;       Используются декларации констант и макросов
        INCLUDE MLAB1.INC	
        INCLUDE MLAB1.MAC

; Декларации данных
        .DATA    
SLINE	DB	78 DUP (CHSEP), 0
REQ	DB	"Фамилия И.О.: ",0FFh
MINIS	DB	"МИНИСТЕРСТВО ОБРАЗОВАНИЯ РОССИЙСКОЙ ФЕДЕРАЦИИ",0
ULSTU	DB	"УЛЬЯНОВСКИЙ ГОСУДАРСТВЕННЫЙ ТЕХНИЧЕСКИЙ УНИВЕРСИТЕТ",0
DEPT	DB	"Кафедра вычислительной техники",0
MOP	DB	"Машинно-ориентированное программирование",0
LABR	DB	"Лабораторная работа N 1",0
REQ1    DB      "Замедлить(-),ускорить(+),выйти(ESC),лабораторная(f)?",0FFh
TACTS   DB	"Время работы в тактах: ",0FFh
EMPTYS	DB	0
BUFLEN = 70
BUF	DB	BUFLEN
LENS	DB	?
SNAME	DB	BUFLEN DUP (0)
PAUSE	DW	0, 0 ; младшее и старшее слова задержки при выводе строки
TI	DB	LENNUM+LENNUM/2 DUP(?), 0 ; строка вывода числа тактов
                                          ; запас для разделительных "`"

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

;========================= Программа =========================
        .CODE
; Макрос заполнения строки LINE от позиции POS содержимым CNT объектов,
; адресуемых адресом ADR при ширине поля вывода WFLD
BEGIN	LABEL	NEAR
	; инициализация сегментного регистра
	MOV	AX,	@DATA
	MOV	DS,	AX
	; инициализация задержки
	MOV	PAUSE,	PAUSE_L
	MOV	PAUSE+2,PAUSE_H
	PUTLS	REQ	; запрос имени
	; ввод имени
	LEA	DX,	BUF
	CALL	GETS	
@@L:	; циклический процесс повторения вывода заставки
	; вывод заставки
	; ИЗМЕРЕНИЕ ВРЕМЕНИ НАЧАТЬ ЗДЕСЬ
	FIXTIME
	PUTL	EMPTYS
	PUTL	SLINE	; разделительная черта
	PUTL	EMPTYS
	PUTLSC	MINIS	; первая 
	PUTL	EMPTYS
	PUTLSC	ULSTU	;  и  
	PUTL	EMPTYS
	PUTLSC	DEPT	;   последующие 
	PUTL	EMPTYS
	PUTLSC	MOP	;    строки  
	PUTL	EMPTYS
	PUTLSC	LABR	;     заставки
	PUTL	EMPTYS
	; приветствие
	PUTLSC	SNAME   ; ФИО студента
	PUTL	EMPTYS
	; разделительная черта
	PUTL	SLINE
	; ИЗМЕРЕНИЕ ВРЕМЕНИ ЗАКОНЧИТЬ ЗДЕСЬ 
	DURAT    	; подсчет затраченного времени
	; Преобразование числа тиков в строку и вывод
	LEA	DI,	TI
	CALL	UTOA10	
	PUTL	TACTS
	PUTL	TI      ; вывод числа тактов
	; обработка команды
	PUTL	REQ1
	CALL	GETCH
	CMP	AL,	'-'    ; удлиннять задержку?
	JNE	CMINUS
	INC	PAUSE+2        ; добавить 65536 мкс
	JMP	@@L
CMINUS:	CMP	AL,	'+'    ; укорачивать задержку?
	JNE	LAB_START
	CMP	WORD PTR PAUSE+2, 0		
	JE	BACK
	DEC	PAUSE+2        ; убавить 65536 мкс
BACK:	JMP	@@L

;===== ПРОЦЕДУРА ВВОДА ЧИСЛА =====
INPUT_NUMBER PROC NEAR
INPUT_NUMBER_RETRY:
    ; Вывод приглашения
    mov AH, 09h
    int 21h

    ; Настройка ввода
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


; циклический вывод числа Z
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

	xor ebx, ebx        ; Обнуление EBX
	xor eax, eax        ; Обнуление EAX

	; Вывод служебных сообщений
	mov ah, 09h         ; Функция DOS 09h - вывод строки
	lea edx, var_Z      ; Загрузка адреса строки var_Z
	int 21h             ; Вызов прерывания для вывода
	lea edx, var_F      ; Загрузка адреса строки var2
	int 21h             ; Вывод второй строки
	
    ; Ввод X
    lea edx, inp_X
    call INPUT_NUMBER
    mov X, ebx

    ; Ввод Y
    lea edx, inp_Y
    call INPUT_NUMBER
    mov Y, ebx

    ; Проверка комбинаций для F1
    xor eax, eax
    mov ah, 09h
    lea edx, out_F
    INT 21h

    ; Вычисление значения функции F17
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

    ; Вывод подходящей функции Z
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
   
    ; Вычисление подходящей функции Z
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

    ; Вывод изначальной Z
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


; Применение следующих выражений
    ;z7 = !z4; 
    ;z2 &= z8; 
    ;z6 |= z4
    xor ebx, ebx
    mov ebx, Z

CALC_Z_PAIR1: ;z7 = !z4
    bt ebx, 4                ; Проверяем (z4)
    jc CLEAR_BIT4
    bts ebx, 7               ; установить бит (z7)
    jmp CALC_Z_PAIR2

CLEAR_BIT4:
    btr ebx, 7              ; сбросить бит (z7)

CALC_Z_PAIR2: ;z2 &= z8
    bt ebx, 8                ; Проверяем (z8)
    jc SET_BIT2              ; Если z8 установлен, переходим к установке бита z2
    btr ebx, 2               ; Сбрасываем бит z2, если z8 не установлен
    jmp CALC_Z_PAIR3

SET_BIT2:
    bts ebx, 2               ; Устанавливаем бит z2, если z8 установлен

CALC_Z_PAIR3: ;z6 |= z4
    bt ebx, 4                ; Проверяем (z4)
    jc SET_BIT6              ; Если z4 установлен, переходим к установке бита z6
    jmp PRINT_NEW_Z           ; Если z4 не установлен, переходим к завершению

SET_BIT6:
    bts ebx, 6               ; Устанавливаем бит z6, если z4 установлен

; Вывод обновленной Z
PRINT_NEW_Z:
    mov Z, ebx               ; Сохранить ответ
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
	; Выход из программы
@@E:	EXIT	
        EXTRN	PUTSS:  NEAR
        EXTRN	PUTC:   NEAR
	EXTRN   GETCH:  NEAR
	EXTRN   GETS:   NEAR
	EXTRN   SLEN:   NEAR
	EXTRN   UTOA10: NEAR
	END	BEGIN
