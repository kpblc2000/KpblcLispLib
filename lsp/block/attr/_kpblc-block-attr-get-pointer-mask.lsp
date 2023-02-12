(defun _kpblc-block-attr-get-pointer-mask (blk mask / res)
                                          ;|
*    Получение списка атрибутов блока по маске. Учитываются также постоянные атрибуты.
*    Параметры вызова:
  blk     ; указатель на вставку блока
  mask    ; строка с маской тэга атрибута
*    Примеры вызова:
(_kpblc-block-attr-get-pointer-mask (car (entsel "\nSelect block : ")) nil)
|;
  (setq blk (_kpblc-conv-ent-to-vla blk)
        res (apply (function append)
                   (mapcar (function (lambda (x)
                                       (if (vlax-method-applicable-p blk x)
                                         (_kpblc-conv-vla-to-list (vlax-invoke-method blk x))
                                       ) ;_ end of if
                                     ) ;_ end of lambda
                           ) ;_ end of function
                           '("getattributes" "getconstantattributes")
                   ) ;_ end of mapcar
            ) ;_ end of apply
  ) ;_ end of setq
  (if (or (not mask) (= mask "*"))
    res
    (vl-remove-if-not
      (function (lambda (x) (wcmatch (strcase (vla-get-tagstring x)) (strcase mask))))
      res
    ) ;_ end of vl-remove-if-not
  ) ;_ end of if
) ;_ end of defun