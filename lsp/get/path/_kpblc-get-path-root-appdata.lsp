(defun _kpblc-get-path-root-appdata ();|
*    Возвращает каталог Мои Документы текущего пользователя
|;
  (vl-string-right-trim
    "\\"
    (vl-registry-read
      "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders"
      "AppData"
    ) ;_ end of vl-registry-read
  ) ;_ end of vl-string-right-trim
) ;_ end of defun
