(defun _kpblc-xml-doc-release (doc)
                              ;|
*    Освобождение ресурсов XML-документа
*    Параметры вызова:
  doc    ; указатель на XML-документ.
*    Примеры вызова:
(setq obj (_kpblc-xml-get-document
            (findfile (strcat (_kpblc-dir-path-and-splash (_kpblc-get-path-root-xml)) "tables.xml"))
            ) ;_ end of _kpblc-xml-get-document
      ) ;_ end of setq
<...>
(_kpblc-xml-doc-release obj)
|;
  (vl-catch-all-apply (function (lambda () (vlax-release-object doc) (setq doc nil))))
) ;_ end of defun
