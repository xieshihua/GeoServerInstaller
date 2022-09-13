RequestExecutionLevel admin
!define TEMP1 $R0 ;Temp variable

# https://nsis.sourceforge.io/How_can_I_use_conditional_execution_(If_..._EndIf_equivalent)
!include LogicLib.nsh

# https://nsis.sourceforge.io/Logging:Enable_Logs_Quickly
!define ENABLE_LOGGING
!include "logging.nsh"

# https://nsis.sourceforge.io/ZipDLL_plug-in
#!include /CHARSET=CP1252 zipdll.nsh	#doesn't work

;Things that need to be extracted on startup (keep these lines before any File command!)
;Only useful for BZIP2 compression
;Use ReserveFile for your own InstallOptions INI files too!

ReserveFile /plugin InstallOptions.dll
ReserveFile "Config.ini"

;Order of pages
Page custom SetCustom ValidateCustom ": Testing InstallOptions" ;Custom page. InstallOptions gets called in SetCustom.
Page instfiles

# define name of installer
OutFile "GeoServerInstaller.exe"
 
# define installation directory
InstallDir "C:\Apps\GeoServer"
ShowInstDetails show
Var hasJava

# start default section
Section

	SetOutPath "$INSTDIR"
	
    # create the uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
 
    # create a shortcut to the uninstaller
    CreateShortcut "$SMPROGRAMS\uninstall GeoServer.lnk" "$INSTDIR\uninstall.exe"
	
    # set the installation directory as the destination for the following actions
    SetOutPath "$TEMP\GeoServer"
SectionEnd

# https://nsis.sourceforge.io/Embedding_other_installers
Section -Prerequisites
	# read Java Version from the registry into the $0 register
	ReadRegStr $hasJava HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" CurrentVersion
	ReadINIStr ${TEMP1} "$PLUGINSDIR\Config.ini" "Field 2" "State"
	StrCmp $hasJava  "" JavaStart
	StrCmp ${TEMP1} "1" JavaStart JavaDone
	
	JavaStart:
		MessageBox MB_OK "Java not found. Install Java."
		# Install Java
		File ".\Prerequisites\jre-8u341-windows-x64.exe"
#		ExecWait '"jre-8u341-windows-x64.exe" /s INSTALLDIR="C:\Apps\java\jre" /L "C:\Apps\java\setup.log"'
		ExecWait '"jre-8u341-windows-x64.exe"'
	JavaDone:
SectionEnd

Section "Geo Server" SEC02
	ReadINIStr ${TEMP1} "$PLUGINSDIR\Config.ini" "Field 3" "State"
	${If} ${TEMP1} == "1"
		LogText "Install Geo Server"
		File "geoserver-2.21.1-bin.zip"
		ExecWait 'PowerShell Expand-Archive -Path "geoserver-2.21.1-bin.zip" -DestinationPath "$INSTDIR"'
		#ExecWait 'geoserver-2.21.1-bin.exe "$INSTDIR"'
	${EndIf}
SectionEnd

Section "GeoServer Extension - App Schema" SEC03
	ReadINIStr ${TEMP1} "$PLUGINSDIR\Config.ini" "Field 4" "State"
	${If} ${TEMP1} == "1"
		LogText "Install Extension - App Schema"
		File ".\Extensions\geoserver-2.21.1-app-schema-plugin.zip"
		#ExecWait 'geoserver-2.21.1-app-schema-plugin.exe "$INSTDIR"'
		#!insertmacro ZIPDLL_EXTRACT "geoserver-2.21.1-app-schema-plugin.zip" "$INSTDIR\webapps\geoserver\WEB-INF\lib" "<ALL>"
		LogText 'PowerShell Expand-Archive -Force -Path "geoserver-2.21.1-app-schema-plugin.zip" -DestinationPath "$INSTDIR\webapps\geoserver\WEB-INF\lib"'
		ExecWait 'PowerShell Expand-Archive -Force -Path "geoserver-2.21.1-app-schema-plugin.zip" -DestinationPath "$INSTDIR\webapps\geoserver\WEB-INF\lib"'
	${EndIf}
SectionEnd
 
Section "GeoServer Extension - Oracle" SEC04
	ReadINIStr ${TEMP1} "$PLUGINSDIR\Config.ini" "Field 5" "State"
	${If} ${TEMP1} == "1"
		LogText "Install Extension - Oracle"
		File ".\Extensions\geoserver-2.21.1-oracle-plugin.zip"
		; LogText 'PowerShell Expand-Archive -Force -Path "geoserver-2.21.1-app-schema-plugin.zip" -DestinationPath "$INSTDIR\webapps\geoserver\WEB-INF\lib"'
		ExecWait 'PowerShell Expand-Archive -Force -Path "geoserver-2.21.1-oracle-plugin.zip" -DestinationPath "$INSTDIR\webapps\geoserver\WEB-INF\lib"'
	${EndIf}
SectionEnd
 
Section "GeoServer Extension - JPEG2K" SEC05
	ReadINIStr ${TEMP1} "$PLUGINSDIR\Config.ini" "Field 6" "State"
	${If} ${TEMP1} == "1"
		LogText "Install Extension - JPEG2K"
		File ".\Extensions\geoserver-2.21.1-jp2k-plugin.zip"
		; LogText 'PowerShell Expand-Archive -Force -Path "geoserver-2.21.1-jp2k-plugin.zip" -DestinationPath "$INSTDIR\webapps\geoserver\WEB-INF\lib"'
		ExecWait 'PowerShell Expand-Archive -Force -Path "geoserver-2.21.1-jp2k-plugin.zip" -DestinationPath "$INSTDIR\webapps\geoserver\WEB-INF\lib"'
	${EndIf}
SectionEnd
 
# uninstaller section start
Section "uninstall"
	# Stop GeoServer
	ExecWait '"$INSTDIR\bin\shutdown"'
	
    # Remove the link from the start menu
    Delete "$SMPROGRAMS\uninstall GeoServer.lnk"
 
    # Delete the uninstaller
    Delete $INSTDIR\uninstaller.exe
 
	# Remove Geo Server
    RMDir /r "$INSTDIR"
# uninstaller section end
SectionEnd

# https://nsis-dev.github.io/NSIS-Forums/html/t-204059.html
# https://bz.apache.org/ooo/show_bug.cgi?id=49861
Section -Post
	SetOutPath "$TEMP"
	RMDir /r "$TEMP\GeoServer"
SectionEnd

Function .onInit
  ; Extract InstallOptions files
  ; $PLUGINSDIR will automatically be removed when the installer closes
  InitPluginsDir
  File /oname=$PLUGINSDIR\Config.ini "Config.ini"
  
  SetOutPath $INSTDIR
  LogSet on
FunctionEnd

Function SetCustom

  ;Display the InstallOptions dialog

  Push ${TEMP1}

    InstallOptions::dialog "$PLUGINSDIR\Config.ini"
    Pop ${TEMP1}
  
  Pop ${TEMP1}

FunctionEnd

Function ValidateCustom

  ReadINIStr ${TEMP1} "$PLUGINSDIR\Config.ini" "Field 2" "State"
  StrCmp ${TEMP1} 1 done
  
  ReadINIStr ${TEMP1} "$PLUGINSDIR\Config.ini" "Field 3" "State"
  StrCmp ${TEMP1} 1 done

  ReadINIStr ${TEMP1} "$PLUGINSDIR\Config.ini" "Field 4" "State"
  StrCmp ${TEMP1} 1 done
  
  ReadINIStr ${TEMP1} "$PLUGINSDIR\Config.ini" "Field 5" "State"
  StrCmp ${TEMP1} 1 done
  
  ReadINIStr ${TEMP1} "$PLUGINSDIR\Config.ini" "Field 6" "State"
  StrCmp ${TEMP1} 1 done
    MessageBox MB_ICONEXCLAMATION|MB_OK "You must select at least one install option!"
    Abort

  done:
  
FunctionEnd
