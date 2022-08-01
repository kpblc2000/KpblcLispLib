(defun _kpblc-conv-points-to-rect (pt-list)
                                  ;|
*    Конвертация набора точек в прямоугольник (отрисовывается против часовой стрелки)
*    Параметры вызова:
  pt-list  ; список координат 3D- или 2D-точек
*    Возвращает список точек описывающего прямоугольника против часовой стрелки
|;
  (setq pt-list (mapcar (function _kpblc-conv-3d-to-2d) (eea-bb-pts pt-list)))
  (list (car pt-list)
        (list (caadr pt-list) (cadar pt-list))
        (cadr pt-list)
        (list (caar pt-list) (cadadr pt-list))
  ) ;_ end of list
) ;_ end of defun
