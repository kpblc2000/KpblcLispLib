(defun _kpblc-conv-list-to-2dpoints (lst / res)
                                    ;|
  *    Функция конвертации списка чисел в список 3-мерных точек.
  *    Параметры вызова:
    lst  список чисел
  *    Примеры вызова:
  (_kpblc-conv-list-to-2dpoints '(1 2 3 4 5 6)) ;-> ((1 2) (3 4) (5 6))
  (_kpblc-conv-list-to-2dpoints '(1 2 3 4 5))   ;-> ((1 2) (3 4) (5 0.))
  |;
  (cond ((not lst) nil)
        (t
         (setq res (cons (list (car lst)
                               (cond ((cadr lst))
                                     (t 0.)
                               ) ;_ end of cond
                         ) ;_ end of list
                         (_kpblc-conv-list-to-2dpoints (cddr lst))
                   ) ;_ end of cons
         ) ;_ end of setq
        )
  ) ;_ end of cond
  res
) ;_ end of defun
