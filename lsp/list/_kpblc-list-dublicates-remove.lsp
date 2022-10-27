(defun _kpblc-list-dublicates-remove (lst / result)
                                     ;|
*    Функция исключения дубликатов элементов списка. Строковые значения обрабатываются, наплевав на регистр
*    Параметры вызова:
*  lst ; обрабатываемый список
*    Возвращаемое значение: список без дубликатов соседних элементов
*    Примеры вызова:
(_kpblc-list-dublicates-remove '((0.0 0.0 0.0) (10.0 0.0 0.0) (10.0 0.0 0.0) (0.0 0.0 0.0)) nil) ; ((0.0 0.0 0.0) (10.0 0.0 0.0) (0.0 0.0 0.0))
|;
  (foreach x lst
    (if (not (if (= (type x) 'list)
               (apply (function or) (mapcar (function (lambda (a) (_kpblc-is-list-equal a x))) result))
               (member (if (= (type x) 'str)
                         (strcase x)
                         x
                       ) ;_ end of if
                       (mapcar (function (lambda (a)
                                           (if (= (type a) 'str)
                                             (strcase a)
                                             a
                                           ) ;_ end of if
                                         ) ;_ end of lambda
                               ) ;_ end of function
                               result
                       ) ;_ end of mapcar
               ) ;_ end of member
             ) ;_ end of member
        ) ;_ end of not
      (setq result (cons x result))
    ) ;_ end of if
  ) ;_ end of foreach
  (reverse result)
) ;_ end of defun
