(defun _kpblc-is-ent-block-ref
                               (ent / name)
                               ;|
*    Проверяет, является ли переданный примитив блоком (и при этом не внешняя ссылка)
*    Параметры вызова:
  ent    указатель на обрабатывамый примитив
|;
  (and (setq ent (_kpblc-conv-ent-to-vla ent))
       (wcmatch (strcase (vla-get-objectname ent)) "*BLOCKREF*")
       (not (vlax-property-available-p ent 'path))
       (not (_kpblc-conv-value-to-bool (_kpblc-property-get ent 'isxref)))
  ) ;_ end of and
) ;_ end of defun
