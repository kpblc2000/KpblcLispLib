(defun _kpblc-get-interface-color ()
                                  ;|
	*    Возвращает указатель на объект обработки цветоа
	|;
  (vla-getinterfaceobject *kpblc-acad* (strcat "AutoCAD.AcCmColor." (itoa (atoi (getvar "acadver")))))
) ;_ end of defun
