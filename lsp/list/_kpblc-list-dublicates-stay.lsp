(defun _kpblc-list-dublicates-stay (lst / res)
                                   ;|
*    Оставляет дубликаты списка
|;
  (if (and lst (= (type lst) 'list))
    (progn (foreach item lst
             (if (member item (cdr (member item lst)))
               (setq res (cons item res))
             ) ;_ end of if
           ) ;_ end of foreach
           (setq res (_kpblc-list-dublicates-remove (reverse res)))
    ) ;_ end of progn
  ) ;_ end of if
  res
) ;_ end of defun
