(defun _kpblc-xml-nodes-get-child-by-name-or-id (parent value)
                                                ;|
*    �������� ������ ����������� xml-�����
*    ��������� ������:
  parent    ; vla-��������� �� ������������ ����. nil ����������
  value      ; �������� (���������) �������� name ��� ID. ��������� �������� ID. nil ����������
*    ������������ ��������: ������ ��������, � ������� ��������� ID ��� name
|;
  (cond ((_kpblc-xml-nodes-get-child-by-attribute parent "id" value))
        ((_kpblc-xml-nodes-get-child-by-attribute parent "name" value))
  ) ;_ end of cond
) ;_ end of defun
