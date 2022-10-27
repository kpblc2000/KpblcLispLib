(defun _kpblc-get-path-dotnet-local ()
                                    ;|
*    Возвращает каталог локального хранения .net-файлов с учетом версии ACAD
|;
  (strcat (_kpblc-get-path-application) "\\dotnet\\" (_kpblc-acad-version-string))
) ;_  end of defun
