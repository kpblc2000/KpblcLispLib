(defun _kpblc-layer-status-save-by-list (doc lst options / res name) 
  ;|
  *    Функция разблокировки и разморозки слоев
  *    Параметры вызова:
    doc  указатель на обрабатываемый документ. nil -> текущий
    lst  список имен слоев.
      <ИмяСлоя>  ; допускается использование масок
      nil -> обрабатывать все
    options список предпринимаемых действий:
        '(("on" . <Включать слои>)    ; t | nil
          ("thaw" . <Размораживать слои>)    ; t | nil
          ("unlock" . <Разблокировать слои>)  ; t | nil
          )
      nil -> '(("on" . nil) ("thaw" . t) ("unlock" . t))
  *    Возвращает список вида
  '((<vla-указатель на слой> ("layeron" . :vlax-true) ("freeze" . :vlax-false) ("lock" . :vlax-true)))
  
  *    Unlock and thaw layers
  *    Call params:
    doc      pointer to document for proceeding. nil -> use current document
    lst      layer names list. Can use wildcards. nil -> proceed all layers
    options  list of actions:
      '(("on" . <Make layers on>)
        ("thaw" . <Thaw layers>)
        ("unlock" . <Unlock layers>)
       )
       if options equals nil it means '(("on" . nil) ("thaw" . t) ("unlock" . t))
  *   Returns list like
   '((vla-pointer to layer> ("layeron" . :vlax-true) ("freeze" . :vlax-false) ("lock" . :vlax-true)))
  |;
  (if (not options) 
    (setq options '(("thaw" . t) ("unlock" . t)))
  ) ;_ end of if
  (setq doc (cond 
              (doc)
              (t *kpblc-adoc*)
            ) ;_ end of cond
        lst (cond 
              (lst (strcase (_kpblc-conv-list-to-string (_kpblc-conv-value-to-list lst) ",")))
              (t "*")
            ) ;_ end of cond
  ) ;_ end of setq
  (foreach layer 
    (vl-remove-if-not 
      (function (lambda (x) (wcmatch (_kpblc-strcase (vla-get-name x)) (_kpblc-strcase lst))))
      (_kpblc-conv-vla-to-list (vla-get-layers doc))
    ) ;_ end of vl-remove-if-not
    (setq res  (cons 
                 (cons layer 
                       (mapcar (function (lambda (x) (cons x (_kpblc-property-get layer x)))) '("layeron" "freeze" "lock"))
                 ) ;_ end of cons
                 res
               ) ;_ end of cons
          name (strcase (vla-get-name layer))
    ) ;_ end of setq
    (if (wcmatch name lst) 
      (progn 
        (if (cdr (assoc "on" options)) 
          (vla-put-layeron layer :vlax-true)
        ) ;_ end of if
        (if (cdr (assoc "unlock" options)) 
          (vla-put-lock layer :vlax-false)
        ) ;_ end of if
        (if (cdr (assoc "thaw" options)) 
          (vl-catch-all-apply '(lambda () (vla-put-freeze layer :vlax-false)))
        ) ;_ end of if
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of vlax-for
  res
) ;_ end of defun
