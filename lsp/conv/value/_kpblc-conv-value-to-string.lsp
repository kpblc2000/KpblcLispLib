(defun _kpblc-conv-value-to-string (value /)
                                   ;|
  *    конвертация значения в строку.
  |;
  (cond
    ((= (type value) 'str) value)
    ((= (type value) 'int) (itoa value))
    ((and (= (type value) 'real)
          (equal value (_kpblc-eval-value-round value 1.) 1e-6)
          (equal value (fix value) 1e-6)
     ) ;_ end of and
     (itoa (fix value))
    )
    ((and (= (type value) 'real)
          (equal value (_kpblc-eval-value-round value 1.) 1e-6)
          (not (equal value (fix value) 1e-6))
     ) ;_ end of and
     (rtos value 2)
    )
    ((= (type value) 'real) (rtos value 2 14))
    ((not value) "")
    (t (vl-princ-to-string value))
  ) ;_ end of cond
) ;_ end of defun
