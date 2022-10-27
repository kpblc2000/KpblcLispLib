(defun _kpblc-get-date-as-string (/ ms)
                                 ;|
	*    ѕолучение текущей даты как строки (аналог (rtos (getvar "cdate") 2 9))
	|;
  (_kpblc-string-align
    (if (setq ms (getvar "millisecs"))
      (strcat (_kpblc-string-align (rtos (getvar "cdate") 2 6) 15 "0" nil)
              (substr (setq ms (itoa (getvar "millisecs"))) (- (strlen ms) 2))
      ) ;_ end of strcat
      (rtos (getvar "cdate") 2 16)
    ) ;_ end of if
    18
    "0"
    nil
  ) ;_ end of _kpblc-string-align
) ;_ end of defun
