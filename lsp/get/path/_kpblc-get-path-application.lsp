(defun _kpblc-get-path-application ()
                                   ;|
  *    ¬озвращает родительский каталог дл€ приложени€ (в текущей реализации - %AppData%\kpblcLib)
  |;
  (strcat (_kpblc-dir-path-and-splash (_kpblc-get-path-root-appdata)) "KpblcLib")
) ;_ end of defun
