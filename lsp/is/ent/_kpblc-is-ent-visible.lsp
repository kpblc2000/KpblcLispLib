(defun _kpblc-is-ent-visible (doc ent / layer)
                             ;|
*    Проверяет, видим ли примитив (BlockRef)
*    Параметры вызова:
  doc    указатель на документ примитива
  ent    собственно примитив
|;
  (and (equal (vla-get-visible ent) :vlax-true)
       (cond ((= (type
                   (setq layer (vl-catch-all-apply (function (lambda () (vla-item (vla-get-layers doc) (vla-get-layer ent))))))
                 ) ;_ end of type
                 'vla-object
              ) ;_ end of =
              (and (equal (vla-get-layeron layer) :vlax-true) (equal (vla-get-freeze layer) :vlax-false))
             )
             ((/= (type layer) 'vla-object) t)
       ) ;_ end of cond
  ) ;_ end of and
) ;_ end of defun
