(defun _kpblc-acad-version-string () 
  ;|
  *    ��������� ������ AutoCAD / nanoCad � ���� ������
  *    ���������� ��������� ������������� ������� ������ AutoCAD
  |;
  (atoi 
    (if (_kpblc-is-app-ncad) 
      (vla-get-version (vlax-get-acad-object))
      (vl-string-trim "VISUALP " (strcase (ver)))
    )
  )
) ;_ end of defun
