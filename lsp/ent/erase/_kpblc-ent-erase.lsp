(defun _kpblc-ent-erase (ent / lay status fun_restore)
                        ;|
*    Удаление примитива
*    Параметры вызова:
*  ent  указатель на удаляемый графический примитив.
*    Удаление примитива выполняется независимо от состояния замороженности
* и заблокированности слоя, на котором примитив находится.
|;
  (defun fun_restore (layer)
    (vl-catch-all-apply (function (lambda () (vla-put-freeze lay (cdr (assoc "freeze" status))))))
    (vla-put-lock lay (cdr (assoc "lock" status)))
  ) ;_ end of defun
  (cond ((= (type ent) 'list) (mapcar (function _kpblc-ent-erase) ent))
        ((= (type ent) 'pickfirst) (mapcar (function _kpblc-ent-erase) (_kpblc-conv-selset-to-vla ent)))
        (t
         (_kpblc-error-catch
           (function (lambda ()
                       (if (and ent (setq ent (_kpblc-conv-ent-to-vla ent)) (not (vlax-erased-p ent)))
                         (progn (setq lay    (vla-item (vla-get-layers (vla-get-document ent)) (vla-get-layer ent))
                                      status (list (cons "freeze" (vla-get-freeze lay)) (cons "lock" (vla-get-lock lay)))
                                ) ;_ end of setq
                                (vl-catch-all-apply (function (lambda () (vla-put-freeze lay :vlax-false))))
                                (vla-put-lock lay :vlax-false)
                                (vla-erase ent)
                                (fun_restore lay)
                         ) ;_ end of progn
                       ) ;_ end of if
                     ) ;_ end of lambda
           ) ;_ end of function
           '(lambda (x) (fun_restore lay) (_kpblc-error-print "_kpblc-ent-erase" x))
         ) ;_ end of _kpblc-error-catch
        )
  ) ;_ end of cond
) ;_ end of defun
