(defun _kpblc-xml-nodes-get-child (parent / node childs res)
                                  ;|
*    Получение подчиненных элементов xml-дерева
*    Параметры вызова
  parent    ; указатель на узел, для которого получаем Child. nil недопустим
*    Примеры вызова:
(setq obj (_kpblc-xml-get-document (findfile (strcat (_kpblc-dir-path-and-splash(_kpblc-get-path-root-xml))"tables.xml")))) (_kpblc-xml-get-nodes-child (_kpblc-xml-node-get-main obj))
|;
  (if (and parent
           (vlax-method-applicable-p parent 'haschildnodes)
           (equal (vlax-invoke-method parent 'haschildnodes) :vlax-true)
           (setq childs (_kpblc-property-get parent 'childnodes))
      ) ;_ end of and
    (_kpblc-xml-conv-nodes-to-list childs)
  ) ;_ end of if
) ;_ end of defun
