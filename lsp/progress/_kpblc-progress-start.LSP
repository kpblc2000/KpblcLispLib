(defun _kpblc-progress-start (msg range)
                             ;|
*    Инициализирует прогресс-бар
*    Параметры вызова:
  msg    показываемое сообщение
  range  общая длина прогресс-бара
|;
  (setq *kpblc-settings-doc*
         (_kpblc-list-add-or-subst *kpblc-settings-doc* "progress" (min 32000 range))
        range (cdr (assoc "progress" *kpblc-settings-doc*))
  ) ;_ end of setq
  (cond ((and msg progressbar) (progressbar msg range))
        ((and (not msg) progressbar) (progressbar range))
        ((and msg acet-ui-progress) (acet-ui-progress msg range))
        ((and (not msg) acet-ui-progress) (acet-ui-progress range))
        (t (_kpblc-progress-cmd msg range))
  ) ;_ end of cond
) ;_ end of defun
