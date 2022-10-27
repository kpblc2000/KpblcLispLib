(defun _kpblc-xml-node-get-main (obj / res)
                                ;|
*    Получение главного (верхнего) узла xml-дерева. Валидность xml-файла не
* проверяется
*    Параметры вызова:
  obj    ; указатель на объект XML-документа
*    Примеры вызова:
(setq obj (_kpblc-xml-doc-get (findfile (strcat (_kpblc-dir-path-and-splash(_kpblc-get-path-root-xml))"tables.xml"))))
(_kpblc-xml-node-get-main obj)
|;
  (_kpblc-error-catch
    (function
      (lambda () (setq res (car (_kpblc-xml-conv-nodes-to-list (_kpblc-property-get obj 'childnodes)))))
    ) ;_ end of function
    '(lambda (x) (_kpblc-error-print "_kpblc-xml-node-get-main" x) (setq res nil))
  ) ;_ end of _kpblc-error-catch
  res
) ;_ end of defun
