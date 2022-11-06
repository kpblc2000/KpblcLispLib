(defun _kpblc-string-align (string str-len sym is-left / sym_count)
                           ;|
*    Выравнивает строку до указанной длины
*    Параметры вызова:
  string  ; обрабатываемая строка. Передаваемое значение в строку преобразовывается
  str-len ;  нужная результирующая длина строки
  sym     ; добавляемый символ (строка, длиной 1)
  is-left ; добавляет слева (t) или справа (nil)
*    Align string to required length
*    Call params:
  string  ; string to proceed. Converts to string if requires
  str-len ; result string length
  sym     ; symbol to append
  is-left ; append to left (t) or to right (nil)
*    Примеры вызова:
*    Call samples:
(_kpblc-string-align "121" 20 "0" T)   ; "00000000000000000121"
(_kpblc-string-align "121" 20 "0" NIL) ; "12100000000000000000"
(_KPBLC-STRING-ALIGN nil 3 "0" t)      ; "000"
|;
  (setq string (_kpblc-conv-value-to-string string))
  (if (>= (setq sym_count (- str-len (strlen string))) 1)
    (repeat sym_count
      (setq string (if is-left
                     (strcat sym string)
                     (strcat string sym)
                   ) ;_ end of if
      ) ;_ end of setq
    ) ;_ end of repeat
  ) ;_ end of if
  string
) ;_ end of defun
