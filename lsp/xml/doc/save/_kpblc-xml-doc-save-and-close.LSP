(defun _kpblc-xml-doc-save-and-close (node-or-doc / doc)
                                     ;|
*    Сохранение и закрытие xml-документа
*    Параметры вызова:
  node-or-doc  ; указатель на объект XML_DOMDocument или один из узлов документа
|;
  (if (setq doc (cond ((_kpblc-property-get node-or-doc 'ownerdocument))
                      (t node-or-doc)
                ) ;_ end of cond
      ) ;_ end of setq
    (progn (_kpblc-xml-doc-save doc) (_kpblc-xml-doc-release doc))
  ) ;_ end of if
) ;_ end of defun
