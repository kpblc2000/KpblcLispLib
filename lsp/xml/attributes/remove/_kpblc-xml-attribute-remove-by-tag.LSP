(defun _kpblc-xml-attribute-remove-by-tag (node tag / attr)
                                          ;|
*    Удаление атрибута из узла. Если атрибута нет, ничего не выполняется
*    Параметры вызова:
  node    ; указатель на узел xml-дерева
  tag     ; имя (тэг) атрибута
|;
  (if (and node
           (setq tag (if tag
                       (strcase tag)
                       "*"
                     ) ;_ end of if
           ) ;_ end of setq
      ) ;_ end of and
    (foreach attr (vl-remove-if-not
                    (function (lambda (x) (wcmatch (strcase x) tag)))
                    (mapcar (function (lambda (a) (_kpblc-property-get a 'nodename)))
                            (_kpblc-xml-attributes-get-by-node node)
                    ) ;_ end of mapcar
                  ) ;_ end of vl-remove-if
      (_kpblc-error-catch
        (function (lambda () (vlax-invoke-method node 'removeattribute attr)))
        '(lambda (x) (_kpblc-error-print "_kpblc-xml-attribute-remove" x))
      ) ;_ end of _kpblc-error-catch
    ) ;_ end of foreach
  ) ;_ end of if
) ;_ end of defun
