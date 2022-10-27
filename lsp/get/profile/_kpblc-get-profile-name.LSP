(defun _kpblc-get-profile-name ()
                               ;|
*    ЗАмена стандартному (getvar "cprofile")
|;
  (vl-list->string
    (vl-remove-if-not
      (function
        (lambda (x)
          (or (<= 48 x 57)
              (<= 65 x 90)
              (<= 97 x 122)
              (= x 32)
              (<= 224 x 255)
              (<= 192 x 223)
          ) ;_ end of or
        ) ;_ end of LAMBDA
      ) ;_ end of function
      (vl-string->list (getvar "cprofile"))
    ) ;_ end of vl-remove-if
  ) ;_ end of VL-LIST->STRING
) ;_ end of defun
