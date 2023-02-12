(defun _kpblc-block-dynprop-get (blk-ref name / blk_def blk_name)
                                ;|
*    Возвращает динамическое свойство блока по имени свойства. Свойство ORIGIN исключается
*    Параметры вызова:
  blk-ref   ; указатель на вхождение блока. Не контролируется
  name      ; имя запрашиваемого свойства. nil -> возвращаются все.
*    Примеры вызова:
(_kpblc-block-dynprop-get (car (entsel)) nil)
|;
  (setq name    (if (or (not name) (= (strcase name) "ORIGIN"))
                  "*"
                  (strcase name)
                ) ;_ end of if
        blk-ref (_kpblc-conv-ent-to-vla blk-ref)
  ) ;_ end of setq
  (if (and blk-ref (vlax-method-applicable-p blk-ref 'getdynamicblockproperties))
    (vl-remove-if (function (lambda (x)
                              (or (= (strcase (vla-get-propertyname x)) "ORIGIN")
                                  (not (wcmatch (strcase (vla-get-propertyname x)) name))
                              ) ;_ end of or
                            ) ;_ end of LAMBDA
                  ) ;_ end of function
                  (_kpblc-conv-vla-to-list (vla-getdynamicblockproperties blk-ref))
    ) ;_ end of vl-remove-if
  ) ;_ end of if
) ;_ end of defun
