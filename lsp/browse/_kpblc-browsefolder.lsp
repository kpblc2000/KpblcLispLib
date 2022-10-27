(defun _kpblc-browsefolder (caption / shlobj folder fldobj outval)
                           ;|
  http://www.autocad.ru/cgi-bin/f1/board.cgi?t=21054YY    
  *    Без отображения файлов
  *    Параметры вызова:
  	caption		; показываемый заголовок (пояснение) окна
  *    Примеры вызова:
  (_kpblc-browsefolder "Выберите каталог")
  |;
  (setq shlobj (vla-getinterfaceobject (vlax-get-acad-object) "Shell.Application")
        folder (vlax-invoke-method
                 shlobj
                 'browseforfolder
                 (vla-get-hwnd (vlax-get-acad-object))
                 caption
                 (+ 512 16)
               ) ;_ end of vlax-invoke-method
  ) ;_ end of setq
  (vlax-release-object shlobj)
  (if folder
    (progn (setq fldobj (vlax-get-property folder 'self)
                 outval (vlax-get-property fldobj 'path)
           ) ;_ end of setq
           (vlax-release-object folder)
           (vlax-release-object fldobj)
    ) ;_ end of progn
  ) ;_ end of if
  outval
) ;_ end of defun
