(defun _kpblc-property-set (obj prop value /)
                           ;|
*    Назначение свойства объекту
*    Параметры вызова:
  obj    указатель на обрабатываемый объект
  prop  наименование свойства
  value  устанавливаемое значение
*
|;
  (if (and (setq obj (_kpblc-conv-ent-to-vla obj))
           ((lambda (/ res)
              (if (member (setq res (vl-catch-all-apply (function (lambda () (vlax-erased-p obj))))) (list t nil))
                (not (vlax-erased-p obj))
                t
              ) ;_ end of if
            ) ;_ end of lambda
           )
           (vlax-property-available-p obj prop t)
      ) ;_ end of and
    (vl-catch-all-apply
      (function
        (lambda ()
          (vlax-put-property
            obj
            prop
            ((lambda (/ tmp)
               (setq tmp (vlax-get-property obj prop))
               (cond ((member tmp (list :vlax-false :vlax-true)) (_kpblc-conv-value-bool-to-vla value))
                     ((= (type tmp) 'int) (_kpblc-conv-value-to-int value))
                     ((= (type tmp) 'real) (_kpblc-conv-value-to-real value))
                     ((= (type tmp) 'str) (_kpblc-conv-value-to-string value))
                     ((and (= (type tmp) 'list) (= (type value) 'str))
                      (apply (function append)
                             (mapcar (function (lambda (x) (_kpblc-conv-string-to-list x ",")))
                                     (_kpblc-conv-string-to-list value " ")
                             ) ;_ end of mapcar
                      ) ;_ end of apply
                     )
                     ((= (type tmp) 'list) (_kpblc-conv-value-to-list value))
                     (t tmp)
               ) ;_ end of cond
             ) ;_ end of lambda
            )
          ) ;_ end of vlax-put-property
        ) ;_ end of lambda
      ) ;_ end of function
    ) ;_ end of vl-catch-all-apply
  ) ;_ end of if
  (if (vlax-property-available-p obj prop)
    (vlax-get-property obj prop)
  ) ;_ end of if
) ;_ end of defun
