(defun _kpblc-get-path-application-dotnet-local ()
                                                ;|
  *    Возвращает и создает путь локального хранения .NET-файлов
  |;
  (_kpblc-dir-create (strcat (_kpblc-dir-path-no-splash (_kpblc-get-path-application)) "\\dotnet"))
) ;_ end of defun
