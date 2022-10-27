(defun _kpblc-conv-ver-to-string (lst / sublst)
                                 ;|
*    Выполняет преобразование переданной версии в строку
*    Параметры вызова:
  lst  варианты:
    строка вида "Major.Minor.Assembly". Пропущенные элементы заменяются на 0.
    список вида '(Major Minor Assembly). Пропущенные элементы заменяются на 0.
    список вида '(("major" . <Major>) ("minor" . <Minor>) ("ass" . <Assembly>))
*    Ограничения: Если в списке больше 3 элементов, то берутся для вычисления только первые 3 элемента
*    Примеры вызова:
_$ (_kpblc-conv-ver-to-string '(("minor" . 0) ("ass" . 16)))
"0.0.16"
_$ (_kpblc-conv-ver-to-string "0. 2 . 5@")
"0.2.5"
_$ (_kpblc-conv-ver-to-string '(0 2 5))
"0.2.5"
|;
  (cond ((not lst) "0.0.0")
        ((= (type lst) 'str)
         (_kpblc-conv-ver-to-string
           (mapcar (function (lambda (x) (atoi x))) (_kpblc-conv-string-to-list lst "."))
         ) ;_ end of _kpblc-conv-ver-to-string
        )
        ((and (= (type lst) 'list) (not (apply (function and) (mapcar (function listp) lst))))
         (_kpblc-conv-ver-to-string
           (list (cons "major" (car lst)) (cons "minor" (cadr lst)) (cons "ass" (caddr lst)))
         ) ;_ end of _kpblc-conv-ver-to-string
        )
        ((and (= (type lst) 'list) (apply (function and) (mapcar (function listp) lst)))
         (_kpblc-conv-list-to-string
           (mapcar (function (lambda (x / tmp) (itoa (_kpblc-conv-value-to-int (cdr x)))))
                   (mapcar (function (lambda (a) (assoc a lst))) '("major" "minor" "ass"))
           ) ;_ end of mapcar
           "."
         ) ;_ end of _kpblc-conv-list-to-string
        )
        ((or (= (type lst) 'int) (= (type lst) 'real))
         ((lambda (/ aa)
            (setq aa (reverse
                       (mapcar (function (lambda (x) (atoi (vl-list->string (reverse (vl-string->list x))))))
                               (_kpblc-conv-string-to-list-by-strlen
                                 (vl-list->string (reverse (vl-string->list (itoa (fix lst)))))
                                 4
                               ) ;_ end of _kpblc-conv-string-to-list-by-strlen
                       ) ;_ end of mapcar
                     ) ;_ end of reverse
            ) ;_ end of setq
            (while (< (length aa) 3) (setq aa (append '(0) aa)))
            (_kpblc-conv-ver-to-string aa)
          ) ;_ end of lambda
         )
        )
  ) ;_ end of cond
) ;_ end of defun
