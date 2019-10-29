;
; suskaiciuoti     /   a^2+x           , kai x < c+a
;              y = |   2b-a            , kai x = c+a
;                  \   (c+5b)/(x-c+a)  , kai x > c+a
; skaiciai be zenklo
; Duomenys a - w, b - b, c - w, x - w, y - b

stekas  SEGMENT STACK
DB 256 DUP(0)
stekas  ENDS

duom    SEGMENT
a    DB 15  ;10000 ; perpildymo situacijai
b    DW 10
c    DW 20
x    DW 35,10,20,30,36,125,5,40
kiek    = ($-x)/2
y    DB kiek dup(0AAh)
isvb    DB 'x=',6 dup (?), ' y=',6 dup (?), 0Dh, 0Ah, '$'
perp    DB 'Perpildymas', 0Dh, 0Ah, '$'
daln    DB 'Dalyba is nulio', 0Dh, 0Ah, '$'
netb    DB 'Netelpa i baita', 0Dh, 0Ah, '$'
spausk  DB 'Skaiciavimas baigtas, spausk bet kuri klavisa,', 0Dh, 0Ah, '$'
duom    ENDS

prog    SEGMENT
assume ss:stekas, ds:duom, cs:prog
pr:  
MOV ax, duom
MOV ds, ax
XOR si, si      ; (suma mod 2) si = 0
XOR di, di      ; di = 0
c_pr:   
MOV cx, kiek
JCXZ pab
cikl:     
XOR ah, ah
MOV al, a
MOV bx, c
ADD ax, bx
XOR bx, bx
CMP x[si], ax
JE f2
JB f3
f1:
MOV ax, 5h
MUL b
MOV dx, c
ADD ax, dx
JC kl1    
XCHG ax, dx
XOR ax, ax
MOV ax, c
MOV bl, a
ADD ax, bx    ; (c+a)
JC kl1
MOV bx, x[si]
SUB bx, ax    ; x-(c+a)
JC kl1
CMP bx, 0
JE kl2    ; dalyba is 0
MOV ax, dx
XOR dx, dx
DIV bx    ; ax=rez
JMP re
f2:
MOV ax, 2
MUL b
JC kl1  ; sandauga netilpo i ax  
XOR bx, bx
MOV bl, a
SUB ax, bx
JC kl1
JMP re
f3:
MOV al, a
MUL a   ; a*a
JC kl1  ; sandauga netilpo i ax
ADD ax, x[si] ;a*a+x
JC kl1
re:
CMP ah, 0     ;ar telpa rezultatasi baita
JE ger
JMP kl3
ger:
MOV y[di], al
INC si
INC si
INC di
LOOP cikl
pab:
;rezultatu isvedimas i ekrana
;============================
XOR si, si
XOR di, di
MOV cx, kiek
JCXZ is_pab
is_cikl:
MOV ax, x[si]  ; isvedamas skaicius x yra ax reg.
PUSH ax
MOV bx, offset isvb+2
PUSH bx
CALL binasc
MOV al, y[di]
XOR ah, ah        ; isvedamas skaicius y yra ax reg.
PUSH ax
MOV bx, offset isvb+11
PUSH bx
CALL binasc

MOV dx, offset isvb
MOV ah, 9h
INT 21h
;============================
INC si
INC si
INC di
LOOP is_cikl
is_pab:
;===== PAUZE ===================
;===== paspausti bet kuri klavisa ===
LEA dx, spausk
MOV ah, 9
INT 21h
MOV ah, 0
INT 16h
;============================
MOV ah, 4Ch   ; programos pabaiga, grizti i OS
INT 21h
;============================

kl1:    LEA dx, perp
MOV ah, 9
INT 21h
XOR al, al
JMP ger
kl2:    LEA dx, daln
MOV ah, 9
INT 21h
XOR al, al
JMP ger
kl3:    LEA dx, netb
MOV ah, 9
INT 21h
XOR al, al
JMP ger

; skaiciu vercia i desimtaine sist. ir issaugo
; ASCII kode. Parametrai perduodami per steka
; Pirmasis parametras ([bp+6])- verciamas skaicius
; Antrasis parametras ([bp+4])- vieta rezultatui

binasc    PROC NEAR
PUSH bp
MOV bp, sp
; naudojamu registru issaugojimas
PUSHA
; rezultato eilute uzpildome tarpais
MOV cx, 6
MOV bx, [bp+4]
tarp:    MOV byte ptr[bx], ' '
INC bx
LOOP tarp
; skaicius paruosiamas dalybai is 10
MOV ax, [bp+6]
MOV si, 10
val:    XOR dx, dx
DIV si
;  gauta liekana verciame i ASCII koda
ADD dx, '0'   ; galima--> ADD dx, 30h
;  irasome skaitmeni i eilutes pabaiga
DEC bx
MOV [bx], dl
; skaiciuojame pervestu simboliu kieki
INC cx
; ar dar reikia kartoti dalyba?
CMP ax, 0
JNZ val

POPA
POP bp
RET
binasc    ENDP
prog    ENDS
END pr

