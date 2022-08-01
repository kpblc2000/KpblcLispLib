(defun _kpblc-conv-3d-to-2d (point)
                            ;|
*    Преобразование 3Д-точки в 2Д
*    Параметры вызова:
*  point  список вещественных чисел (точка)
*    Примеры вызова:
(_kpblc-conv-3d-to-2d (getpoint))
|;
  (list (car point) (cadr point))
) ;_ end of defun
