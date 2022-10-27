(defun _kpblc-conv-list-to-pairs (lst param / res f pos)
                                 ;|
  *    Преобразовывает список вида '(1 2 3) в список пар '((1 2) (2 3))
  *    Параметры вызова:
    lst   ; обрабатываемый список
    param ; дополнительные параметры вызова вида
     '(("back" . <>) ; делать финальную "обратную" пару. Для примера '((1 2) (2 3) (3 1))
       )
  *    Примеры вызова:
  (_kpblc-conv-list-to-pairs '(1 2 3 4) nil)  ; '((1 2) (2 3) (3 4))
  (_kpblc-conv-list-to-pairs '(1 2 3 4) '(("back" . t))) ; '((1 2) (2 3) (3 4) (4 1))
  |;
  (setq res (list (list (car lst)))
        pos 1
  ) ;_ end of setq
  (while (< pos (length lst))
    (setq res (cons (list (nth pos lst)) (subst (append (car res) (list (nth pos lst))) (car res) res))
          pos (1+ pos)
    ) ;_ end of setq
  ) ;_ end of while
  (setq res (cdr res))
  (if (cdr (assoc "back" param))
    (setq res (cons (list (last lst) (car lst)) res))
  ) ;_ end of if
  (reverse res)
) ;_ end of defun
