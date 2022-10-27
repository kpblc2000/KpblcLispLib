(defun _kpblc-progress-end ()
                           ;|
*    Завершение прогресс-бара
|;
  (setq *kpblc-settings-doc* (_kpblc-list-add-or-subst *kpblc-settings-doc* "progress" nil))
  (cond (progressbar (progressbar))
        (acet-ui-progress (acet-ui-progress))
        (t (princ))
  ) ;_ end of cond
) ;_ end of defun
