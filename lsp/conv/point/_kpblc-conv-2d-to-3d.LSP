(defun _kpblc-conv-2d-to-3d (point) 
  ;|
  *    �������������� 2�-����� � 3�
  *    ��������� ������:
    point  ������ ������������ ����� (�����)
  *    ������� ������:
  (_kpblc-conv-2d-to-3d (getpoint))
  |;
  (list (car point) 
        (cadr point)
        (cond 
          ((caddr point))
          (t 0.0)
        ) ;_ end of cond
  ) ;_ end of list
) ;_ end of defun
