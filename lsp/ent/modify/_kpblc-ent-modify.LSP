(defun _kpblc-ent-modify (ent bit value / ent_list old_dxf new_dxf)
                         ;|
*    ������� ����������� ���������� ���� ���������
*    ��������� ������:
*  entity  - ��������, ���������� ����� (entsel), (entlast) etc
*  bit  - dxf-���, �������� �������� ���� ����������
*  value  - ����� ��������
*    ������� ������:
(_kpblc-ent-modify (entlast) 8 "0")  ; ��������� ��������� �������� �� ���� 0
(_kpblc-ent-modify (entsel) 62 10)  ; ���������� ���������� ��������� ���� 10
*    ������������ ��������:
*  �������� � ���������������� dxf-�������. �������� ������������� 
* ����������������.
|;
  (_kpblc-ent-modify-autoregen ent bit value t)
) ;_ end of defun
