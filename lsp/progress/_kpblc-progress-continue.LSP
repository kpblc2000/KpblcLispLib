(defun _kpblc-progress-continue (msg pos)
                                ;|
*    Заполняет прогресс-бар
*    Параметры вызова:
  msg    выводимое сообщение
  pos    текущая позиция
|;
  (setq pos (- pos
               (* (cdr (assoc "progress" *kpblc-settings-doc*))
                  (/ pos (cdr (assoc "progress" *kpblc-settings-doc*)))
               ) ;_ end of *
            ) ;_ end of -
  ) ;_ end of setq
  (cond (progressbar (progressbar (rem pos 32765)))
        (acet-ui-progress (acet-ui-progress (rem pos 32765)))
        (t (_kpblc-progress-cmd msg pos))
  ) ;_ end of cond
) ;_ end of defun
