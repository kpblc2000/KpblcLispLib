(defun _kpblc-get-objectid (obj / util)
                           ;|
*    ��������� ObjectID ���������� �� ������ AutoCAD
*    ��������� ������:
  obj    ; ��������� �� ������������� ������ (vla- ���� ename-)
|;
  (cond ((vlax-property-available-p (setq obj (_kpblc-conv-ent-to-vla obj)) "objectid")
         (vla-get-objectid obj)
        )
        ((vlax-property-available-p obj "objectid32") (vla-get-objectid32 obj))
  ) ;_ end of cond
) ;_ end of defun
