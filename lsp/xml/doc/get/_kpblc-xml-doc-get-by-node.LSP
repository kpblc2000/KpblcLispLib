(defun _kpblc-xml-doc-get-by-node (obj)
                                  ;|
*    ��������� ��������� �� ��������-�������� ����.
*    ��������� ������:
  obj  ; ��������� �� �������������� ����. ���� ��� ��������� �� �������� xml, �� �� � ������������
|;
  (cond ((_kpblc-property-get obj 'ownerdocument))
        (t obj)
  ) ;_ end of cond
) ;_ end of defun
