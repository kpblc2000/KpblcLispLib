(defun _kpblc-xml-nodes-get-child-by-tag (parent tag)
                                         ;|
  *    Получение списка подчиненных узлов, у которых тэг совпадает с указанным
  *    Параметры вызова:
    parent    ; указатель на "родительский" узел
    tag       ; маска имени тэга. nil -> "*"
  |;
  (setq tag (if tag
              (strcase tag)
              "*"
            ) ;_ end of if
  ) ;_ end of setq
  (vl-remove-if-not
    (function
      (lambda (x)
        (wcmatch (strcase (_kpblc-conv-value-to-string (_kpblc-property-get x 'tagname))) tag)
      ) ;_ end of lambda
    ) ;_ end of function
    (_kpblc-xml-nodes-get-child parent)
  ) ;_ end of vl-remove-if-not
) ;_ end of defun
