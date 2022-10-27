(defun _kpblc-is-point-in-boundary (point boundary / farpoint check)
                                   ;|
  ;;mip_ispointinside (point boundary / farpoint check)
          ;* алгоритм вз€т на http://algolist.manual.ru/maths/geom/belong/poly2d.php
          ;* Ќа основе vk_IsPointInside
          ;* ќпубликовано
          ;* http://www.caduser.ru/forum/index.php?PAGE_NAME=message&FID=23&TID=36191&MID=205580&sessid=79096aca9605acaa6da486d593128e41&order=&FORUM_ID=23
          ;* Boundary Ч список нормализованных [т.е. только либо (X Y) либо (X Y Z)] точек
          ;* Point - провер€ема€ точка
 ;_ѕровер€ет Boundary на условие car и last одна и та же точка
 |;
  (if (not (equal (car boundary) (last boundary) 1e-6))
    (setq boundary (append boundary (list (car boundary))))
  ) ;_ end of if
  (setq farpoint (cons (+ (apply (function max) (mapcar (function car) boundary)) 1.0) (cdr point)))
  (or (not
        (zerop
          (rem (length
                 (vl-remove nil
                            (mapcar (function (lambda (p1 p2) (inters point farpoint p1 p2))) boundary (cdr boundary))
                 ) ;_ end of vl-remove
               ) ;_ end of length
               2
          ) ;_ end of rem
        ) ;_ end of zerop
      ) ;_ end of not
      (vl-some (function (lambda (x) x))
               (mapcar (function (lambda (p1 p2)
                                   (or check
                                       (if (equal (+ (distance point p1) (distance point p2)) (distance p1 p2) 1e-3)
                                         (setq check t)
                                         nil
                                       ) ;_ end of if
                                   ) ;_ end of or
                                 ) ;_ end of lambda
                       ) ;_ end of function
                       boundary
                       (cdr boundary)
               ) ;_ end of mapcar
      ) ;_ end of vl-some
  ) ;_ end of or
) ;_ end of defun
