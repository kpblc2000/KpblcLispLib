(defun _kpblc-xml-text-set-by-node (node text save)
                                   ;|
  *    ���������� text'a ����
  *    ��������� ������:
    node   ; ��������� �� ���� ������
    text   ; ����������� �����. ������, ��� �� �����������
    save   ; ��������� ��� ��� ������ xml-�����.
  |;
  (_kpblc-error-catch
    (function
      (lambda ()
        (vlax-put-property node 'text text)
        (if save
          (_kpblc-xml-doc-save (_kpblc-xml-doc-get-by-node node))
        ) ;_ end of if
      ) ;_ end of lambda
    ) ;_ end of function
    '(lambda (x)
       (_kpblc-error-print "_kpblc-xml-text-set-by-node" x)
     ) ;_ end of lambda
  ) ;_ end of _kpblc-error-catch
  (_kpblc-xml-text-get-by-node node)
) ;_ end of defun
