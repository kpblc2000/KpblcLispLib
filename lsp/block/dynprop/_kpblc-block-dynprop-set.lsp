(defun _kpblc-block-dynprop-set (blk-ref lst / pr prop_list)
                                ;|
*    Устанавливает динамическое свойство блока
*    Параметры вызова:
  blk-ref  ; вхождение блока
  lst      ; список точечных пар вида '((<ИмяСвойства> . <НовоеЗначение>) <...>).
*    Примеры вызова:
(_kpblc-block-dynprop-set (car (entsel)) '(("Длина" . 6000.)))
|;
  (if (setq blk-ref (_kpblc-conv-ent-to-vla blk-ref))
    (progn (setq prop_list (mapcar (function (lambda (x) (cons (strcase (vla-get-propertyname x)) x)))
                                   (_kpblc-block-dynprop-get blk-ref nil)
                           ) ;_ end of mapcar
           ) ;_ end of setq
           (foreach item lst
             (if (setq pr (cond ((cdr (assoc (strcase (car item)) prop_list)))
                                (t (car (_kpblc-block-dynprop-get blk-ref (car item))))
                          ) ;_ end of cond
                 ) ;_ end of setq
               (vl-catch-all-apply (function (lambda () (vla-put-value pr (cdr item)))))
             ) ;_ end of if
           ) ;_ end of foreach
    ) ;_ end of progn
  ) ;_ end of if
  (vla-update blk-ref)
) ;_ end of defun
