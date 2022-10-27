(defun _kpblc-conv-value-to-nth (value lst)
                                ;|
  *    ѕреобразовывает переданное значение в пор€дковый номер элемента в списке
  *    ѕараметры вызова:
     value   ; преобразовываемое значение (строка или целое)
     lst     ; список, внутри которого надо контролировать вхождение
  |;
  (cond ((and (= (type value) 'int) (< value (length lst))) value)
        ((and (= (type value) 'str)
              (= (_kpblc-conv-value-to-string (_kpblc-conv-value-to-int value)) value)
              (< (atoi value) (length lst))
         ) ;_ end of and
         (atoi value)
        )
        (t (vl-position value lst))
  ) ;_ end of cond
) ;_ end of defun
