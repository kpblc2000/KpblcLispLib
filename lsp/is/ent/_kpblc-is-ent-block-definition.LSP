(defun _kpblc-is-ent-block-definition (ent) ;|
*    Проверяет, является ли переданный примитив описанием блока
|;
  (and (= (_kpblc-property-get ent 'objectname) "AcDbBlockTableRecord")
       (equal (_kpblc-property-get ent 'islayout) :vlax-false)
       (equal (_kpblc-property-get ent 'isxref) :vlax-false)
  ) ;_ end of and
) ;_ end of defun
