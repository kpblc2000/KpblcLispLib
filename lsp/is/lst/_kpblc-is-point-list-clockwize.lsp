(defun _kpblc-is-point-list-clockwize (pt-list)
                                      ;|
*    Если порядок точек по часовой, возвращает t
*    Параметры вызова:
  pt-list    список точек для проверки
*    Примеры вызова:
(_kpblc-is-point-list-clockwize '((-50.0 -100.0) (-70.0 0.0) (70.0 0.0) (50.0 -100.0))) ; nil
(_kpblc-is-point-list-clockwize '((50.0 -100.0) (70.0 0.0) (-70.0 0.0) (-50.0 -100.0))) ; T
|;
  (not (minusp (apply (function +)
                      (mapcar (function (lambda (a b) (* (+ (car a) (car b)) (- (cadr a) (cadr b)))))
                              (cons (last pt-list) pt-list)
                              pt-list
                      ) ;_ end of mapcar
               ) ;_ end of apply
       ) ;_ end of minusp
  ) ;_ end of not
) ;_ end of defun
