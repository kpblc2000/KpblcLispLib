(defun _kpblc-odbx (/)
                   ;|
*    функция возвращает интерфейс IAxDbDocument (для работы с файлами DWG без их открытия). Если интерфейс не поддерживается, возвращает nil.
*    Автор - Fatty aka Олег jr. Моего только адаптация под общую систему и переименование
*    Примеры вызова:
(_kpblc-odbx)
|;
  (vla-getinterfaceobject
    (vlax-get-acad-object)
    (strcat "ObjectDBX.AxDbDocument." (itoa (atoi (getvar "acadver"))))
  ) ;_ end of vla-getinterfaceobject
) ;_ end of defun
