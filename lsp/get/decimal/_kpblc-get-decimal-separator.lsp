(defun _kpblc-get-decimal-separator ()
                                    ;|
	*    Возвращает установленный в системе разделитель целой и дробной части
	|;
  (vl-registry-read "HKEY_CURRENT_USER\\Control panel\\International" "sDecimal")
) ;_ end of defun
