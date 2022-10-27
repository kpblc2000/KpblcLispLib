(defun _kpblc-xml-attribute-add-or-modify (node tag value save /)
                                          ;|
*    Добавление атрибута к узлу дерева с установкой значения. Если такой атрибут
* уже есть, он заменяется
*    Параметры вызова:
  node    ; обрабатываемый узел дерева
  tag     ; имя (тэг) добавляемого атрибута
  value   ; значение атрибута
  save    ; сохранять или нет документ
|;
  (_kpblc-error-catch
    (function
      (lambda ()
        (_kpblc-xml-attribute-remove-by-tag node tag)
        (vlax-invoke-method node 'setattribute tag value)
        (if save
          (_kpblc-xml-doc-save (_kpblc-xml-doc-get-by-node node))
        ) ;_ end of if
      ) ;_ end of lambda
    ) ;_ end of function
    '(lambda (x) (_kpblc-error-print "_kpblc-xml-attribute-remove-by-tag" x))
  ) ;_ end of _kpblc-error-catch
) ;_ end of defun
