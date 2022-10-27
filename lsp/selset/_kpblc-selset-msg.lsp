(defun _kpblc-selset-msg (msg fun-ssget / sysvar res)
                         ;|
*    Запрос объектов с пользовательским приглашением
*    Параметры вызова:
  msg    выводимое приглашение
  fun-ssget функция формирования набора, без ssget
*    Примеры вызова:
(_kpblc-selset-msg "Выберите окружность" (function (lambda() (ssget "_+.:S:E" '((0 . "CIRCLE"))))))
|;
  (setq sysvar (_kpblc-error-sysvar-save-by-list '(("sysmon" . 0) ("cmdecho" . 0) ("menuecho" . 0) ("nomutt" . 1))))
  (princ (strcat "\n" (vl-string-trim " \n\t:" msg) " <Отмена> : "))
  (setq res (vl-catch-all-apply fun-ssget))
  (_kpblc-error-sysvar-restore-by-list sysvar)
  (if (= (type res) 'pickset)
    res
  ) ;_ end of if
) ;_ end of defun
