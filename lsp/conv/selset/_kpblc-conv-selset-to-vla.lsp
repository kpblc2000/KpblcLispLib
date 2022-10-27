(defun _kpblc-conv-selset-to-vla (selset)
                                 ;|
  *    Преобразование набора примитивов в список vla-представлений примитивов
  *    Параметры вызова:
    selset  ; набор, сформированный (ssget)
  |;
  (mapcar (function _kpblc-conv-ent-to-vla) (_kpblc-conv-selset-to-ename selset))
) ;_ end of defun
