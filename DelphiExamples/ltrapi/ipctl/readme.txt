Пример требует версию библиотек ltr не ниже 1.29.4!

Данный пример демонстрирует работу функций ltrapi для управления записями IP-адресов сервера из среды Delphi.
Пример содержит файл проекта для среды "Delphi 7" (ltr210_delphi.dpr) и для
среды "Embarcadero Delphi XE" (ltr210_delphi.dproj).

В проекте необходимо указать путь к файлам ltrapi.pas, ltrapidefine.pas,
ltrapitypes.pas новой версии, которые устанавливаются вместе
с библиотеками ltr и необходимы для сборки данного примера
(LTR_INSTALL_DIR/include/pascal2).

Путь можно задать следующим образом:
    Delphi 7    - "Project->Options->Directories/Conditionals->Search path",
    Delphi XE2  - "Project->Options->Delphi Compiler->Search path"