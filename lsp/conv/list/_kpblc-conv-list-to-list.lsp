(defun _kpblc-conv-list-to-list (lst)
                                ;|
  *    Функция конвертации списка точечных пар в обычный список подсписков
  *    Параметры вызова:
    lst  обрабатываемый список
  *    Примеры вызова:
  (_kpblc-conv-list-to-list '((1 . 2) (3 . 4) (5 6 7 8))) ;-> ((1 2) (3 4) (5 6 7 8))
  |;
  (mapcar
    (function
      (lambda (x)
        (if (= (type (cdr x)) 'list)
          (if (= (length (cdr x)) 1)
            (list (car x) (cadr x))
            (cons (car x) (cdr x))
          ) ;_ end of if
          (list (car x) (cdr x))
        ) ;_ end of if
      ) ;_ end of lambda
    ) ;_ end of function
    lst
  ) ;_ end of mapcar
) ;_ end of defun
