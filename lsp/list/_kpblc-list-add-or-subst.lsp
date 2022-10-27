(defun _kpblc-list-add-or-subst (lst key value)
                                ;|
*    Производит замену или дополнение элемента списка новым
*    Параметры вызова:
  lst     ; обрабатываемый список
  key     ; ключ
  value   ; устанавливаемое значение
|;
  (if (not value)
    (vl-remove-if (function (lambda (x) (= (car x) key))) lst)
    (if (cdr (assoc key lst))
      (subst (cons key value) (assoc key lst) lst)
      (cons (cons key value) (vl-remove-if (function (lambda (x) (= (car x) key))) lst))
    ) ;_ end of if
  ) ;_ end of if
) ;_ end of defun
