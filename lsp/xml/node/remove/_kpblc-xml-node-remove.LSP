(defun _kpblc-xml-node-remove (node / parent res)
                              ;|
*    �������� ���� xml-������. ��� �������� �������� ���������� t
*    ��������� ������:
  node    ; ��������� �� ��������� ����. �� ����� ���� ������������ ����� ������. �������� ����������� � ��� ����� � ��� ����������� �����
|;
  (if (and (setq parent (_kpblc-property-get node 'parentnode))
           (not (equal parent node))
      ) ;_ end of and
    (_kpblc-error-catch
      (function
        (lambda ()
          (vlax-invoke-method parent 'removechild node)
          (setq res t)
        ) ;_ end of lambda
      ) ;_ end of function
      (function
        (lambda (x)
          (_kpblc-error-print "_kpblc-xml-node-remove" x)
          (setq res nil)
        ) ;_ end of lambda
      ) ;_ end of function
    ) ;_ end of _kpblc-error-catch
  ) ;_ end of if
  res
) ;_ end of defun
