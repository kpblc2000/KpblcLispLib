(defun _kpblc-is-ent-annotative (ent / lst temp)
                                ;|
*    Проверяет, является ли объект аннотативным
*    Параметры вызова:
  ent      ; указатель на обрабатываемый объект
|;
  (and ent
       (setq ent (_kpblc-conv-ent-to-ename ent))
       (or (and (setq temp (cdr (assoc "AcadAnnotative" (cdr (assoc -3 (entget ent '("*")))))))
                (setq temp (cdr (member '(1000 . "AnnotativeData") temp)))
                ((lambda (/ lst f sum res)
                   (setq lst temp
                         sum 0
                   ) ;_ end of setq
                   (while (and (not f) lst)
                     (cond ((= (cdar lst) "{") (setq lst (cdr lst)))
                           ((= (cdar lst) "}")
                            (setq lst (cdr lst)
                                  f   t
                            ) ;_ end of setq
                           )
                           ((= (caar lst) 1070)
                            (setq sum (+ sum (min 1 (cdar lst)))
                                  res (cons (car lst) res)
                                  lst (cdr lst)
                            ) ;_ end of setq
                           )
                     ) ;_ end of cond
                   ) ;_ end of while
                   (= sum (length res))
                 ) ;_ end of lambda
                )
           ) ;_ end of and
           (and (= "MLEADERSTYLE" (cdr (assoc 0 (entget ent)))) (= 1 (cdr (assoc 296 (entget ent)))))
       ) ;_ end of or
  ) ;_ end of and
) ;_ end of defun
