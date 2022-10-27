(defun _kpblc-xml-conv-nodes-to-list (nodes / i res)
                                     ;|
  *    Преобразование указателя на коллекцию Nodes xml-объекта в список.
  *    Исключаются описания не узлов (комментарии, DATA-узлы и т.п.)
  *    Параметры вызова:
    nodes    ; указатель на коллекцию узлов xml-документа
  |;
  (_kpblc-error-catch
    (function
      (lambda ()
        (setq i 0)
        (while (< i (_kpblc-property-get nodes 'length))
          (setq res (cons (vlax-get-property nodes 'item i) res)
                i   (1+ i)
          ) ;_ end of setq
        ) ;_ end of while
        (setq res (vl-remove-if-not
                    (function (lambda (x) (member (_kpblc-property-get x 'nodetype) '(1 2))))
                    (reverse res)
                  ) ;_ end of vl-remove-if-not
        ) ;_ end of setq
      ) ;_ end of lambda
    ) ;_ end of function
    '(lambda (x) (_kpblc-error-print "_kpblc-xml-conv-nodes-to-list" x) (setq res nil))
  ) ;_ end of _kpblc-error-catch
  res
) ;_ end of defun
