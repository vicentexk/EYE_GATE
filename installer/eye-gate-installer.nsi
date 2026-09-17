/* ============================================================
   EYE GATE — Instalador Windows (NSIS 3)
   Compila no Linux (makensis) e no GitHub Actions.
   Payload esperado: pasta ../build/app com o Electron montado
   (EyeGate.exe + resources/app + locales mínimas).
   Saída: EyeGate-Setup-2.0.1.exe na raiz do repositório.
   ============================================================ */

Unicode true
ManifestDPIAware true
RequestExecutionLevel admin
SetCompressor /SOLID lzma

!define PRODUCT      "eye gate"
!define EXE          "EyeGate.exe"
!define VERSION      "2.0.1"
!define UNINSTKEY    "eye gate"

Name "eye gate"
OutFile "..\EyeGate-Setup-2.0.1.exe"
InstallDir "$PROGRAMFILES64\eye gate"
Icon "..\img\logo.ico"
UninstallIcon "..\img\logo.ico"

VIProductVersion "2.0.1.0"
VIAddVersionKey /LANG=1046 "ProductName" "eye gate"
VIAddVersionKey /LANG=1046 "FileDescription" "Instalador do eye gate — sistema de acesso escolar"
VIAddVersionKey /LANG=1046 "FileVersion" "2.0.1"
VIAddVersionKey /LANG=1046 "ProductVersion" "2.0.1"
VIAddVersionKey /LANG=1046 "LegalCopyright" "© 2026 eye gate"

Page directory
Page instfiles

Section "Instalar"
  SetOutPath "$INSTDIR"
  File /r "..\build\app\*.*"

  ; desinstalação aparece no Painel de Controle
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTKEY}" "DisplayName" "${PRODUCT}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTKEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTKEY}" "Publisher" "Equipe eye gate"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTKEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTKEY}" "DisplayIcon" "$INSTDIR\${EXE}"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTKEY}" "EstimatedSize" 230000

  ; atalhos: menu iniciar + área de trabalho
  CreateDirectory "$SMPROGRAMS\${PRODUCT}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT}\${PRODUCT}.lnk" "$INSTDIR\${EXE}"
  CreateShortCut "$DESKTOP\${PRODUCT}.lnk" "$INSTDIR\${EXE}"

  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

Function .onInstSuccess
  MessageBox MB_YESNO|MB_ICONQUESTION "eye gate instalado com sucesso! Abrir agora?" IDYES abrir IDNO fechar
  abrir:
    Exec '"$INSTDIR\${EXE}"'
    Goto fechar
  fechar:
FunctionEnd

Section "Uninstall"
  nsExec::Exec "taskkill /F /IM ${EXE}"
  Sleep 600
  Delete "$DESKTOP\${PRODUCT}.lnk"
  Delete "$SMPROGRAMS\${PRODUCT}\${PRODUCT}.lnk"
  RMDir "$SMPROGRAMS\${PRODUCT}"
  RMDir /r "$INSTDIR"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTKEY}"
SectionEnd
