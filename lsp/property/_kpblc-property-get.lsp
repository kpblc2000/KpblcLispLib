(defun _kpblc-property-get (obj property / res)
                           ;|
*    Получение значения свойства объекта
|;
  (vl-catch-all-apply
    (function
      (lambda ()
        (if (and obj (vlax-property-available-p (setq obj (_kpblc-conv-ent-to-vla obj)) property))
          (setq res (vlax-get-property obj property))
        ) ;_ end of if
      ) ;_ end of lambda
    ) ;_ end of function
  ) ;_ end of vl-catch-all-apply
  res
) ;_ end of defun
