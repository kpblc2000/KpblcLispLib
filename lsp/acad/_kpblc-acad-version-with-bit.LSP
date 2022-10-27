(defun _kpblc-acad-version-with-bit ()
                                    ;|
  *    Возвращает строковое представление версии AutoCAD (2008 / 2009 / 2010 etc) и его разрядность (x32 / x64)
  |;
  (strcat (itoa (_kpblc-acad-version-string))
          "x"
          (if (and (getvar "platform") (wcmatch (strcase (getvar "platform")) "*X64*"))
            "64"
            "32"
          ) ;_ end of if
  ) ;_ end of strcat
) ;_ end of defun
