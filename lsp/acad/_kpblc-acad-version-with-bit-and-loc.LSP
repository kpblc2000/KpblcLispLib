(defun _kpblc-acad-version-with-bit-and-loc () 
  ;|
  *    ���������� ��������� ������������� ������ AutoCAD (2008 / 2009 / 2010 etc) � ��� ����������� (x32 / x64) � ������ �����������
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
