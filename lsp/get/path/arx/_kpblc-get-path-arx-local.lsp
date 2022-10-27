(defun _kpblc-get-path-arx-local ()
                                 ;|
*    Возвращает каталог локального хранения .net-файлов с учетом версии ACAD
|;
  (strcat (_kpblc-get-path-application) "\\arx\\" (_kpblc-acad-version-with-bit))
) ;_  end of defun
