ModelMuse � Version 3.6.2.0

NOTE: Any use of trade, product or firm names is for descriptive purposes 
      only and does not imply endorsement by the U.S. Government.

This version of ModelMuse is packaged for personal computers using
the Microsoft Windows XP, Vista, 7, 8 or 8.1 operating systems.  Executable 
files for personal computers are provided as well as the source code. Although 
not a supported operating system, some users have reported success on using 
ModelMuse on Linux computers under WINE.

Instructions for installation, execution, and compiling are provided below.



                            TABLE OF CONTENTS

                         A. DISTRIBUTION FILE
                         B. INSTALLING
                         C. EXECUTING THE SOFTWARE
                         D. EXAMPLES
                         E. COMPILING


A. DISTRIBUTION FILES

ModelMuse is distributed as either an installer or a zip file.
Either version may be used for installing ModelMuse.  Both contain
the same version of ModelMuse for use on personal computers:

For 32 or 64-bit operating systems:
         ModelMuseSetup32_3_6_2.exe
         ModelMuse32_3_6_2.zip
For 64-bit operating systems:
         ModelMuseSetup64_3_6_2.exe
         ModelMuse64_3_6_2.zip

Both distribution files contain:

          Compiled runfiles for ModelMuse, ModelMonitor,
            and MF2005_Importer.exe.
          ModelMuse documentation in PDF files.
          Example models
          Supplementary materials

The file ModelMuseSource3_6_2.zip contains the source code for ModelMuse, 
         ModelMonitor, and MF2005_Importer.exe.

B. INSTALLING

The distribution file is an installer.  Execution of the distribution 
file will install ModelMuse in a directory chosen by the user. By default,
ModelMuse will be installed in C:\Program Files\USGS\ModelMuse3_6_2 or
C:\Program Files (x86)\USGS\ModelMuse3_6_2. If 
the new version of ModelMuse is installed over an older version, the 
program may be installed in the same directory as the older version of the 
program. The installer will associate files with the extensions .gpt, 
.gpb, and .mmZlib with ModelMuse.  The following directory structure will 
be created in the installation directory:

   |--ModelMuse3_6_2
   |  |--bin          ; ModelMuse, ModelMonitor, and MF2005_Importer 
   |  |                   executables.
   |  |--doc          ; Documentation file

ModelMuse will also create a subdirectory of the "My Documents" directory named 
"ModelMuse Examples" containing sample models and data.
   |  |--data         ; Data files and example models described in the 
   |  |                   documentation or the ModelMuse help.
   |  |--examples     ; Sample models.

Included in directory ModelMuse3_6_2\doc is the report on ModelMuse as a 
Portable Document Format (PDF) file. The PDF file is readable and 
printable on various computer platforms using Acrobat Reader from Adobe.
The Acrobat Reader is freely available from the following World Wide Web
site:
      http://www.adobe.com/

The zip file contains the same files in the same directory structure. 
To install it, unzip the file retaining the directory structure of the zip
file. Unlike the installer, unzipping the files from a zip file will not 
associate ModelMuse project files with extensions .gpt, .gpb, or .mmZLib 
with ModelMuse.  This can be done manually.  The manual method used to 
associate ModelMuse project files with ModelMuse varies among the various 
Windows operating systems.  Consult your operating system help for more 
details.  Searching the operating system help for "To associate a file 
name extension with a file type" may give the required information.

C. EXECUTING THE SOFTWARE

There are several ways to execute the software.
1. Double click on it in Windows Exporer.
2. Double-click on the desktop short cut for ModelMuse that is optionally
   created by the installer.
3. Double click on a file with one of the extensions associated with 
   ModelMuse (.gpt, gpb, mmZlib).

D. EXAMPLES

Several example models are included in the "ModelMuse Examples\examples" 
folder under Public Documents. Many of the  ones for PHAST reproduce sample 
models distributed with PHAST or described in the ModelMuse help. Most of 
the ones for MODFLOW are described in the ModelMuse help.  Data files used 
in the examples described in the ModelMuse documentation or help are in the 
"ModelMuse Examples\data" folder.

E. COMPILING

The 32 and 64-bit version of ModelMuse are both compiled with Delphi XE2 from Embarcadero. 
http://www.embarcadero.com/ 

ModelMonitor is compiled with Delphi XE2 from Embarcadero. 
http://www.embarcadero.com/

The help system for ModelMuse is compiled with Help and Manual version 5
from EC Software. http://www.helpandmanual.com/

MF2005_Importer is compiled with the Intel Fortran compiler.

ModelMuse uses a number of custom components which must be installed 
in Delphi XE2 before compiling ModelMuse.  Some are included  
with the ModelMuse source code.  Additional required files or components are 
listed below.  In some cases, the files must be altered before they 
can be used with ModelMuse.  The required changes are listed below.

General instructions for installing packages in Delphi XE2
1. If the component comes with an installer, run the installer.
2. If you are compiling the components from source code, you need to add the 
directories containing the source code to the Library path for both the 
Windows 32 and Windows 64 bit platforms.. (Tools|Options) 
then look in "Environment Options|Delphi Options|Library".
3. If you are compiling the components from source code and the components 
are separated into run-time and design-time packages, you build the runtime 
package and then build and install the design-time package.

Install JCL and JVCL They can be obtained from http://www.delphi-jedi.org/
Add the following JCL directories to the Library path if they are not added
automatically when installing the JCL.
source\common
source\windows
Version 3.48 was used in compiling ModelMuse. The following changes were made prior to installing. These changes may not be strictly neccessary for installing on Delphi XE1 and XE2 but are helpful for installing in Delphi 7 and 2006

JvRichEdit.pas
line 6013
Change
    dwCookie := DWORD_PTR(AConverter);
to
    dwCookie := {$IFDEF COMPILER19_UP}DWORD_PTR{$ELSE}Longint{$ENDIF}(AConverter);

line 6065
Change
      dwCookie := DWORD_PTR(Cookie);
to
      dwCookie := {$IFDEF COMPILER19_UP}DWORD_PTR{$ELSE}Longint{$ENDIF}(Cookie);

JvAppIniStorage.pas
Line 277
Change
{$IFDEF DELPHI8_UP}
to
{$IFDEF DELPHI2007_UP}



Installing Graphics32
http://graphics32.org/wiki/
Download the latest version of Graphics32. It should be version 
graphics32-1-9-1 or more recent.
Comment out MouseUp(mbLeft, [], 0, 0); in TCustomImage32.DblClick in 
GR32_Image.pas.
Build the runtime package first. Then install the design time package.  
To compile the design-time package, you may need to edit the search path for 
the design time Project (Project|Options|Delphi compiler|Search path) so that 
it includes the dcp and/or bpl
output directories. For example:
C:\Users\Public\Documents\RAD Studio\9.0\Dcp;C:\Users\Public\Documents\RAD Studio\9.0\Bpl

Installing GLScene
http://glscene.sourceforge.net
For compiling with Delphi XE2, use GLScene_v1.3.
Open and read the readme.html file in the source directory of GLScene. 
Graphics 32 support must be added by modifing GLScene.inc so make the 
required change. This is done by changing 
{.$DEFINE GLS_Graphics32_SUPPORT}
to
{$DEFINE GLS_Graphics32_SUPPORT}

Required changes to the GLScene source code to compile it with Delphi XE2
include the following:
In FXCollectionEditor.pas, remove System.Actions from the uses list.
In GLSceneEdit.pas, remove System.Actions from the uses list.
In GLSMemo.pas, change line 417 from 
    FScrollBars: System.UITypes.TScrollStyle;
to 
    FScrollBars: Vcl.StdCtrls.TScrollStyle;
In GLSMemo.pas, change line 448 from 
    procedure SetScrollBars(Value: System.UITypes.TScrollStyle);
to 
    procedure SetScrollBars(Value: Vcl.StdCtrls.TScrollStyle);
In GLSMemo.pas, change line 3598 from 
procedure TGLSCustomMemo.SetScrollBars(Value: TScrollStyle);
to
procedure TGLSCustomMemo.SetScrollBars(Value: Vcl.StdCtrls.TScrollStyle);

Add the source directory for GLScene for both 32 and 64-bit compilation.

Build DelphiXE2\GLScene_RunTime.dpk and then install 
DelphiXE2\GLScene_DesignTime.dpk.
As with Graphics32 the projects search path may need to include the dcp and/or 
bpl output directories. Typical paths for those would be the following.
C:\Users\Public\Documents\RAD Studio\9.0\Bpl
C:\Users\Public\Documents\RAD Studio\9.0\Dcp
In the design time package, be sure that the correct package is listed under 
"Requires".

Get and install VirtualTreeView version 5.5.3 or later.
http://www.jam-software.com/virtual-treeview/
https://github.com/Virtual-TreeView/Virtual-TreeView-XE2

MadExcept version 4 or later must be installed.  It can be obtained from 
http://www.madshi.net/

TurboPower Abbrevia
http://sourceforge.net/projects/tpabbrevia/
Deactivate UnzipZipxSupport in AbDefine.inc

The Components directory has additional components that need to be installed. 
They are in the following subdirectories of the Components directory.
addbtn95
ade
ButtonEdit
datagrid
GLWidget
ModelCube
MMJLabel
QMostRecentlyUsedFiles
Quadtree
QZoomBox2
RbwController
RbwDataGrid
RbwDynamicCursor
RbwEdit
RbwParser
RbwRuler
xbase

The GraphicEX and xygraph directories do not have packages but they need to be
added to the search path.





