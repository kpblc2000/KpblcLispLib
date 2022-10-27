(defun _kpblc-get-path-desktop (/ path)
                               ;|
  *    Возвращает каталог "Рабочий стол" текущего пользователя
  |;
  (_kpblc-dir-path-no-splash
    (cond
      ((vl-registry-read
         "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders"
         "Desktop"
       ) ;_ end of vl-registry-read
      )
      (t (strcat (getenv "HOMEDRIVE") (getenv "HOMEPATH") "\\Desktop"))
    ) ;_ end of cond
  ) ;_ end of _kpblc-dir-path-no-splash
) ;_ end of defun
