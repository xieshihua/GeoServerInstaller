GeoServer (https://geoserver.org) is an open source server for sharing geospatial data. It requires a Java 8 or Java 11 environment. This GeoServer Installer is built for your convenience. It includes a Java 8 runtime, GeoServer, and three extensions.

GeoServerInstaller.exe runs under Windows systems. After your downloading, you may run GeoServerInstaller.exe to install GeoServer. If you do not have a Java installed, it will install the packed Java automatically. You also have the option to install the packed Java even if you have already installed another Java. The package includes the following components:
•	Java runtime 8.0.341
•	GeoServer 2.21.1
•	GeoServer App Schema Extension 2.21.1
•	GeoServer Oracle Extension 2.21.1
•	GeoServer JPEG2K Extension 2.21.1

The installer itself is based on the nullsoft scriptable install system (NSIS, https://nsis.sourceforge.io/Main_Page). If you are interested in building your own installer, please feel free to download the scripting (InstallGeoServer.nsh) and configure (Config.ini) file, modify them to include other extensions. After you downloaded NSIS (https://nsis.sourceforge.io/Download), you need to download the advanced logging build (https://nsis.sourceforge.io/Special_Builds) to patch your standard installation. You also need to download logging.nsh and copy it to the Your_NSIS_Install\Include folder. Typically, it would be C:\Program Files (x86)\NSIS\Include. Enjoy!

File List:
•	Readme.txt
•	GeoServerInstaller.exe - The GeoServer package installer
•	InstallGeoServer.nsi - The GeoServer package builder script
•	logging.nsh - The script required for logging
•	install.log - A install log of GeoServerInstaller.exe installation
•	geoserver.log - A log of a running GeoServer installed by using GeoServerInstaller.exe installer