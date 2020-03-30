# 8086emuAssembler

;
; calculate        /   a^2+x           , when x < c+a
;              y = |   2b-a            , when x = c+a
;                  \   (c+5b)/(x-c+a)  , when x > c+a
; positive numbers
; Duomenys a - word, b - byte, c - word, x - word, y - byte
