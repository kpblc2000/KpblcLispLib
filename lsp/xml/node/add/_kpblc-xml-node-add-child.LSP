(defun _kpblc-xml-node-add-child (parent tag save / res)
                                 ;|
*    Добавление подчиненного узла
*    Параметры вызова:
  parent    ; указатель на родительский узел, в который и выполняется добавление
  tag       ; тэг нового узла
  save      ; выполнять или нет сохранение документа для parent'a
|;
  (_kpblc-error-catch
    (function
      (lambda ()
        (setq res (vlax-invoke-method
                    parent
                    'appendchild
                    (vlax-invoke-method (_kpblc-xml-doc-get-by-node parent) 'createelement tag)
                  ) ;_ end of vlax-invoke-method
        ) ;_ end of setq
        (if save
          (_kpblc-xml-doc-save (_kpblc-xml-doc-get-by-node node))
        ) ;_ end of if
      ) ;_ end of lambda
    ) ;_ end of function
    '(lambda (x) (_kpblc-error-print "_kpblc-xml-node-add-child" x) (setq res nil))
  ) ;_ end of _kpblc-error-catch
  res
) ;_ end of defun
