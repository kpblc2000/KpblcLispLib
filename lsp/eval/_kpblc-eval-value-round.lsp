(defun _kpblc-eval-value-round (value to / tmp)
                               ;|
  ;; http://forum.dwg.ru/showthread.php?p=301275
  *    Выполняет округление числа до указанной точности
  *    Примеры вызова:
  (_kpblc-eval-value-round 16.365 0.01) ; 16.37
  |;
  (if (zerop to)
    value
    (cond ((and value (listp value)) (mapcar (function (lambda (x) (_kpblc-eval-value-round x to))) value))
          (value
           (if (or (= (type to) 'int) (equal (fix to) to))
             (* (atoi (rtos (/ (float value) to) 2 0)) to)
             (if (or (> (setq tmp (abs (- (fix (/ (float value) to)) (/ (float value) to)))) 0.5)
                     (equal tmp 0.5 1e-9)
                 ) ;_ end of or
               (* (fix (1+ (/ (float value) to))) to)
               (* (fix (/ (float value) to)) to)
             ) ;_ end of if
           ) ;_ end of if
          )
    ) ;_ end of cond
  ) ;_ end of if
) ;_ end of defun
