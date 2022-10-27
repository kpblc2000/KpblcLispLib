(defun _kpblc-conv-value-bool-to-int (value)
                                     ;|
  *    Функция конвертации переданного логического значения в числовое (для sql)
  *    Параметры вызова:
    value  ; конвертируемое значение
  |;
  (cond ((= (_kpblc-conv-value-bool-to-vla value) :vlax-false) 0)
        (t -1)
  ) ;_ end of cond
) ;_ end of defun
