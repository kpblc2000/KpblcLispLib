(defun _kpblc-is-file-read-only (file-name / file_hangle res)
                                ;|
*    Проверяет, является ли файл "read-only". Возвращает t, если да. Проверки
* наличия файла не выполняется.
*    Параметры вызова:
*  file-name  полное имя файла, с путем.
(_kpblc-is-file-read-only "Z:\\КТО transit\\Разное\\Устройство молниезащиты.dwg")
|;
  (and file-name
       (findfile file-name)
       (or (not (vl-file-systime file-name))
           ((lambda (/ svr obj res)
              (setq svr (vlax-get-or-create-object "Scripting.FileSystemObject")
                    obj (vlax-invoke-method svr 'getfile file-name)
                    res (vlax-get-property obj 'attributes)
              ) ;_ end of setq
              (vlax-release-object obj)
              (vlax-release-object svr)
              (setq obj nil
                    svr nil
              ) ;_ end of setq
              (/= (* 2 (/ res 2)) res)
            ) ;_ end of lambda
           )
       ) ;_ end of or
  ) ;_ end of and
) ;_ end of defun
