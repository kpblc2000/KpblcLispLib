(defun _kpblc-acad-version-with-bit-and-loc () 
  ;|
  *    Возвращает строковое представление версии AutoCAD (2008 / 2009 / 2010 etc) и его разрядность (x32 / x64) с учетом локализации
  |;
  (strcat (_kpblc-acad-version-with-bit) 
          (if (_kpblc-is-app-ncad) 
            ""
            (strcat "-" 
                    (vl-registry-read (strcat "HKEY_LOCAL_MACHINE\\" (vlax-product-key)) "LocaleID")
            )
          )
  ) ;_ end of strcat
) ;_ end of defun
