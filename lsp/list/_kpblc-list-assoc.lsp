(defun _kpblc-list-assoc (key lst)
                         ;|
  *    Замена стандартному assoc
  *    Параметры вызова:
    key ; ключ
    lst ; обрабатываеымй список
  |;
  (if (= (type key) 'str)
    (setq key (strcase key))
  ) ;_ end of if
  (car
    (vl-remove-if-not
      (function (lambda (a / b)
                  (and (setq b (car a))
                       (or (and (= (type b) 'str)
                                (= (strcase b) key)
                           ) ;_ end of and
                           (equal b key)
                       ) ;_ end of or
                  ) ;_ end of and
                ) ;_ end of lambda
      ) ;_ end of function
      lst
    ) ;_ end of vl-remove-if-not
  ) ;_ end of car
) ;_ end of defun
