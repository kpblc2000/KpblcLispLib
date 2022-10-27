(defun _kpblc-xml-doc-save (node-or-doc / doc)
                           ;|
*    Сохранение xml-документа
*    Параметры вызова:
  node-or-doc    ; указатель на объект XML_DOMDocument или один из узлов документа
|;
  (if (setq doc (cond ((_kpblc-property-get node-or-doc 'ownerdocument))
                      (t node-or-doc)
                ) ;_ end of cond
      ) ;_ end of setq
    (_kpblc-error-catch
      (function
        (lambda ()
          (vlax-invoke-method
            doc
            'save
            (_kpblc-string-replace-noreg
              (vl-string-left-trim "file:" (_kpblc-string-replace-noreg (_kpblc-property-get doc 'url) "%20" " "))
              "/"
              "\\"
            ) ;_ end of _kpblc-string-replace-noreg
          ) ;_ end of vlax-invoke-method
        ) ;_ end of lambda
      ) ;_ end of function
      '(lambda (x) (_kpblc-error-print "_kpblc-xml-doc-save" x))
    ) ;_ end of _kpblc-error-catch
  ) ;_ end of if
) ;_ end of defun
