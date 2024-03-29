(defun _kpblc-xml-doc-create (file root / handle)
                             ;|
*    ���� ���� �� ����������, ������� ��� "� ����".
*    ��������� ������:
  file    ; ������ ���� ������������ xml-�����. ���������� �����, �� ��������
  root    ; ��� Root-���� ������
*    ���������� ���� ���������� ����� ���� nil � ������ ������. ���������� �����
* �� �����������.
|;
  (cond ((or (not file) (not root)) nil)
        ((findfile file))
        ((and (not (_kpblc-find-file-or-dir (vl-filename-directory file)))
              (_kpblc-dir-create (vl-filename-directory file))
         ) ;_ end of and
         ((vl-filename-directory file))
         (_kpblc-xml-doc-create file root)
        )
        ((_kpblc-find-file-or-dir (vl-filename-directory file))
         (setq handle (open file "w"))
         (foreach item (list "<?xml version=\"1.0\" encoding=\"utf-8\"?>" (strcat "<" root ">") (strcat "</" root ">"))
           (write-line item handle)
         ) ;_ end of foreach
         (close handle)
         (findfile file)
        )
  ) ;_ end of cond
) ;_ end of defun
