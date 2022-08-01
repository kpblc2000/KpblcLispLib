(defun _kpblc-ent-modify-table-format-borders (table rows / row col)
                                              ;|
*    Форматирование таблицы (веса линий) для таблицы
*    Параметры вызова:
  table    ; vla-указатель на обрабатываемую таблицу
  rows     ; номера строк, которые надо делать "полужирными"
*    Примеры вызова:
(_kpblc-ent-modify-table-format-borders (vlax-ename->vla-object (car (entsel))) nil)
|;
  (setq row  0
        rows (_kpblc-conv-value-to-list rows)
  ) ;_ end of setq
  (while (< row (vla-get-rows table))
    (setq col 0)
    (while (< col (vla-get-columns table))
      (vla-setgridlineweight2
        table
        row
        col
        (+ (if (member row rows)
             (+ achorzbottom achorztop)
             0
           ) ;_ end of if
           acvertleft
           acvertright
        ) ;_ end of +
        aclnwt030
      ) ;_ end of vla-SetGridLineWeight2
      (setq col (1+ col))
    ) ;_ end of while
    (setq row (1+ row))
  ) ;_ end of while
  (setq col 0
        row (1- (vla-get-rows table))
  ) ;_ end of setq
  (while (< col (vla-get-columns table))
    (vla-setgridlineweight2 table row col achorzbottom aclnwt030)
    (setq col (1+ col))
  ) ;_ end of while
) ;_ end of defun
