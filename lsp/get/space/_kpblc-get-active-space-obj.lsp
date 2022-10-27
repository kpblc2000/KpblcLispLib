(defun _kpblc-get-active-space-obj (doc)
                                   ;|
*    Функция возвращает vla-активное пространство (лист / модель). 
*    Параметры вызова:
*  Нет
*    Примеры вызова:
(_kpblc-get-active-space-obj)
|;
  (setq doc (cond ((_kpblc-is-ent-document doc))
                  (t *kpblc-adoc*)
            ) ;_ end of cond
  ) ;_ end of setq
  (if (and (zerop (vla-get-activespace doc)) (equal :vlax-false (vla-get-mspace doc)))
    (vla-get-paperspace doc)
    (vla-get-modelspace doc)
  ) ;_ end of if
) ;_ end of defun
