(defun _kpblc-xml-attributes-get-by-node (node)
                                         ;|
*    ��������� ��������� ���� XML-������.
*    ��������� ������:
  node  ; ����������� ����
|;
  (if (vlax-property-available-p node 'attributes)
    (_kpblc-xml-conv-nodes-to-list
      (_kpblc-property-get node 'attributes)
    ) ;_ end of _kpblc-xml-conv-nodes-to-list
  ) ;_ end of if
) ;_ end of defun
