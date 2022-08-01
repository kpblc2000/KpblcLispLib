(defun _kpblc-conv-2d-to-3d (point)
                            ;|
*    Преобразование 2Д-точки в 3Д
*    Параметры вызова:
*  point  список вещественных чисел (точка)
*    Примеры вызова:
(_kpblc-conv-2d-to-3d (getpoint))
|;
  (list (car point)
        (cadr point)
        (cond ((caddr point))
              (t 0.0)
        ) ;_ end of cond
  ) ;_ end of list
) ;_ end of defun
