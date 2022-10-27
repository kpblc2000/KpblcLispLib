(defun _kpblc-xml-doc-get (file / doc)
                          ;|
*    Получение указателя на xml-DOMDocument
*    Параметры вызова:
  file    ; xml-файл. Валидность не проверяется
|;
  (if (findfile file)
    (_kpblc-error-catch
      (function (lambda ()
                  (setq doc (vlax-get-or-create-object "MSXML2.DOMDocument.3.0"))
                  (vlax-put-property doc 'async :vlax-false)
                  (vlax-invoke-method doc 'load file)
                ) ;_ end of lambda
      ) ;_ end of function
      '(lambda (x) (_kpblc-error-print "_kpblc-xml-doc-get" x) (setq doc nil))
    ) ;_ end of _kpblc-error-catch
  ) ;_ end of if
  doc
) ;_ end of defun
