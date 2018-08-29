' resave.v4.0.vbs
' VBScript program to resave CodeSoft Files
'
' ----------------------------------------------------------------------------
' Requires
' - CodeSoft Entreprise 15 or later
'	from https://www.teklynx.com/en-EMEA/products/label-design-solutions/codesoft
' - GraphicsMagick Image Processing System
'	from http://www.graphicsmagick.org/download.html
'	ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/windows/GraphicsMagick-1.3.30-Q8-win64-dll.exe
'	(would work similarly with ImageMagick, just slower)
' ----------------------------------------------------------------------------
' Copyright (c) 2018 Benjamin Vigier
' Version 4.0 - July 20, 2018
'
' LICENSE: https://raw.githubusercontent.com/tuxfre/scripts/master/LICENSE
'
' This program is free software: you can redistribute it and/or modify
' it under the terms of the GNU General Public License as published by
' the Free Software Foundation, either version 3 of the License, or
' (at your option) any later version.
' 
' This program is distributed in the hope that it will be useful,
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' GNU General Public License for more details.
' 
' You should have received a copy of the GNU General Public License
' along with this program.  If not, see <https://www.gnu.org/licenses/>.
'
' ----------------------------------------------------------------------------
' Contains code from:
' - Paul Frankovich		(vbScript logger)				https://bit.ly/2m7DkPP
' - Jeremy England		(Browse for folder)				https://gist.github.com/simply-coded/d5d28643b60aaa1d4a1405200a854904
' - Mike Harris 		(SO answer: Date format)		https://stackoverflow.com/a/28808377
' - Polynomial 			(SO answer: Ternary Operator)	https://stackoverflow.com/a/20353438
' - rory.ap 			(SO answer: List folder)		https://stackoverflow.com/a/18921133
' - Mark Ribau 			(SO answer: Error handling)		https://stackoverflow.com/a/5904831
' - snotmare			(recursive folder creation)		https://www.tek-tips.com/viewthread.cfm?qid=1032777
' - Rob van der Woude	(recursive folder creation UNC)	http://www.robvanderwoude.com/vbstech_folders_md.php
' - Teklynx				(CodeSoft VB Samples)			C:\Users\Public\Documents\Teklynx\CODESOFT 2015\Samples\Integration

' ----------------------------------------------------------------------------
' Let's make our life harder by having to explicitely declare all variables, just for the lolz
Option Explicit
' Custom error handlers => disable error dialog
On Error Resume Next
' Clear the error stack (better safe than sorry)
Err.Clear

' ----------------------------------------------------------------------------
' Let's initialise some variables
Dim intSubdirs, intAnswer1DCodes, intAnswer2DCodes, intAnswerImages, intImageBitsPerPx, intImageRotation, intImageScaling, b, sngMeanAbsoluteErrorTotal, intImageThreshold
Dim strFolderPath, strTargetFileExtension, strDestinationLabFolder, strDestinationLabFile, strDestinationImgFolder, strDestinationImgFile, strImageExtension, strBeforeImageFullPath, strAfterImageFullPath, strDiffImageFullPath, strPath, strNewFolder, strPathO, strFileOwnwerList, strGMOutput, strProblemLabelList, strPowershellCmd
Dim dtmInstallDate, objOperatingSystem, objItem, objCodeSoftDocument, objCodeSoftBarcodes, objWscriptShellExec, objPowerShell, objMatch, objRegistry, dtEnd, colItems
Dim blnHas1D, blnHas2D
Dim dictSymbolgy :			Set dictSymbolgy =			CreateObject("scripting.dictionary")
Dim dtmConvertedDate :		Set dtmConvertedDate =		CreateObject("WbemScripting.SWbemDateTime")
Dim objWMIService :			Set objWMIService =			GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
Dim colOperatingSystems :	Set colOperatingSystems =	objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
Dim objStringBuilder :		Set objStringBuilder =		CreateObject("System.Text.StringBuilder")
Dim objFileSys :			Set objFileSys =			CreateObject("Scripting.FileSystemObject")
Dim objNetwork :			Set objNetwork =			CreateObject("Wscript.Network")
Dim objWscriptShell :		Set objWscriptShell =		CreateObject("WScript.Shell")
Dim objCodeSoft :			Set objCodeSoft =			CreateObject ("lppx2.application")
Dim objRE :					Set objRE = New RegExp
Dim objLogFile :			Set objLogFile =			objFileSys.CreateTextFile(CStr(objFileSys.GetParentFolderName(WScript.ScriptFullName)) & "\log." & CStr(objFileSys.GetFileName(WScript.ScriptFullName)) & "." & sprintf("{0:yyyyMMddhhmm}", Array(now())) & ".log")
Dim dtStart :				dtStart = now()
Dim intReadSize :			intReadSize = 0
Dim intWriteSize :			intWriteSize = 0
Dim intNum1DBarcodes :		intNum1DBarcodes = 0
Dim intNum2DBarcodes :		intNum2DBarcodes = 0
Dim intNumImagesGenerated :	intNumImagesGenerated = 0
Dim intProblemImages :		intProblemImages = 0
Dim i :						i = 0
Dim l :						l = 0

' ----------------------------------------------------------------------------
' Config
' Config / Target file extension (what we search for)
strTargetFileExtension = "lab"

' Config / Image export options
strImageExtension =	"png"	' "bmp", "pcx", "dcx", "eps", "tif", "jpg" or "png"
intImageBitsPerPx =	1		' 0, 1, 4, 8 or 24
intImageRotation =	0		' 0 -> 360
intImageScaling =	500		' 10 -> 1000

' Config / Image compare difference threshold (0=0% difference, 1=100% difference)
intImageThreshold = 0.1

' Config / GM Output regex
objRE.Pattern	= "\n\s+Total:\s([0-9\.]+)\s+([0-9\.]+)"
objRE.IgnoreCase	= True
objRE.Global		= True
objRE.MultiLine	= True

' Config / Symbologies
dictSymbolgy(49) =	"Code 11"
dictSymbolgy(50) =	"25 Interleave"
dictSymbolgy(51) =	"Code 39"
dictSymbolgy(52) =	"Code 49"
dictSymbolgy(53) =	"Maxicode"
dictSymbolgy(54) =	"Code 16K"
dictSymbolgy(55) =	"German Postcode"
dictSymbolgy(56) =	"EAN 8"
dictSymbolgy(57) =	"UPCE"
dictSymbolgy(58) =	"BC 412"
dictSymbolgy(59) =	"MicroPDF"
dictSymbolgy(65) =	"Code 93"
dictSymbolgy(66) =	"25 Beared"
dictSymbolgy(67) =	"Code 128"
dictSymbolgy(68) =	"EAN 128"
dictSymbolgy(69) =	"EAN 13"
dictSymbolgy(70) =	"Code 39 Full"
dictSymbolgy(71) =	"Code 128 Auto"
dictSymbolgy(72) =	"Codablock F"
dictSymbolgy(73) =	"25 Industrial"
dictSymbolgy(74) =	"25 Standard"
dictSymbolgy(75) =	"Codabar"
dictSymbolgy(76) =	"Logmars"
dictSymbolgy(77) =	"MSI"
dictSymbolgy(78) =	"Codablock A"
dictSymbolgy(79) =	"Postnet"
dictSymbolgy(80) =	"Plessey"
dictSymbolgy(81) =	"Code 128 SSCC"
dictSymbolgy(83) =	"UPC Extended"
dictSymbolgy(85) =	"UPC A"
dictSymbolgy(86) =	"UPC EXT2"
dictSymbolgy(87) =	"UPC EXT5"
dictSymbolgy(88) =	"Code 25 PRDG"
dictSymbolgy(89) =	"UPC WEIGHT"
dictSymbolgy(97) =	"UPC E PLUS 2"
dictSymbolgy(98) =	"UPC E PLUS 5"
dictSymbolgy(99) =	"UPC A PLUS 2"
dictSymbolgy(100) =	"UPC A PLUS 5"
dictSymbolgy(101) =	"EAN 8 PLUS 2"
dictSymbolgy(102) =	"EAN 8 PLUS 5"
dictSymbolgy(103) =	"EAN 13 PLUS 2"
dictSymbolgy(104) =	"EAN 13 PLUS 5"
dictSymbolgy(105) =	"ITF"
dictSymbolgy(106) =	"25 Matrix European"
dictSymbolgy(107) =	"25 Matrix Japan"
dictSymbolgy(120) =	"Datamatrix"
dictSymbolgy(121) =	"ITF 14"
dictSymbolgy(122) =	"PDF"
dictSymbolgy(123) =	"QRcode"
dictSymbolgy(124) =	"RSS"
dictSymbolgy(125) =	"Composite"
dictSymbolgy(126) =	"TLC 39"
dictSymbolgy(127) =	"CIP"
dictSymbolgy(128) =	"Aztec"
dictSymbolgy(129) =	"Aztec Mesa"
dictSymbolgy(130) =	"EAN 14"
dictSymbolgy(131) =	"Bookland"
dictSymbolgy(132) =	"Planet"
dictSymbolgy(133) =	"Pharmacode"
dictSymbolgy(134) =	"ITF 16"
dictSymbolgy(135) =	"Vericode"
dictSymbolgy(136) =	"Code 93i"
dictSymbolgy(137) =	"RM4SCC"
dictSymbolgy(138) =	"FIM"
dictSymbolgy(139) =	"Intelligent Mail"
dictSymbolgy(140) =	"ISBN 13"
dictSymbolgy(141) =	"Chinese Sensible Code"
dictSymbolgy(142) =	"Micro QR"
dictSymbolgy(143) =	"ISBT 128"
dictSymbolgy(144) =	"GS1 128 CC UPCA"
dictSymbolgy(145) =	"GS1 128 CC EAN13"
dictSymbolgy(146) =	"Japan Post"
dictSymbolgy(147) =	"Kix Code"
dictSymbolgy(148) =	"Australian Post"
dictSymbolgy(149) =	"Korean Post"
dictSymbolgy(150) =	"Telepen"
dictSymbolgy(151) =	"Code One"

' Config / File list header (for Excel copy-paste)
strProblemLabelList = """Image full path""" & vbTab & """Mean Absolute Error (Total)""" & vbTab & """File owner""" & vbTab & """Has 1D Code?""" & vbTab & """Has 2D Code?""" & vbTab & """Destination Label File""" & vbTab & """Source Label File""" & vbNewLine

' ----------------------------------------------------------------------------
' Utilities
' Utilities / Date formatting
Function sprintf(sFmt, aData)
	objStringBuilder.AppendFormat_4 sFmt, (aData)
	sprintf = objStringBuilder.ToString()
	objStringBuilder.Length = 0
End Function

' Utilities / Logging
Function addLogEntry(strLevel, strMessage)
	objLogFile.WriteLine "[" & sprintf("{0:yyyy MM dd HH:mm:ss}", Array(now())) & " | " & strLevel & "]	" & strMessage  
End Function

' Utilities / File owner
Function GetFileOwner(strPathO)
	strPowershellCmd = "powershell -windowstyle hidden -nologo -Noninteractive -noprofile -command ""get-acl " & Chr(34) & Chr(34) & Chr(34) & strPathO & Chr(34) & Chr(34) & Chr(34) & " | Select -ExpandProperty Owner"""
	Set objPowerShell = objWscriptShell.Exec(strPowershellCmd)
	objPowerShell.StdIn.Close
	GetFileOwner = Replace(Trim(objPowerShell.StdOut.ReadAll), vbNewLine, vbNullString)
End Function

' Utilities / Browse for folder
Function BrowseForFolder()
	Dim oFolder
	Set oFolder = CreateObject("Shell.Application").BrowseForFolder(0,"Select the root folder where to start processing files", &H0001 + &H0010 + &H0020,0)
	If (oFolder Is Nothing) Then
		BrowseForFolder = Empty
	Else
		BrowseForFolder = oFolder.Self.Path
	End If
End Function

' Utilities / Ternary function
Function IIf(bClause, sTrue, sFalse)
	If CBool(bClause) Then
		IIf = sTrue
	Else
		IIf = sFalse
	End If
End Function

' Utilities / Recursive folder creation
Sub subCreateFolders(strPath)
	If (Right(strPath, 1) <> "\") Then
		strPath = strPath & "\"
	End If
	strNewFolder = ""
	Do Until strPath = strNewFolder
		strNewFolder = Left(strPath, InStr(Len(strNewFolder) + 1, strPath, "\"))
		If (objFileSys.FolderExists(strNewFolder) = False) Then
					Call addLogEntry("INFO", "(File " & l & ")		Creating destination folder:		" & strNewFolder)
			objFileSys.CreateFolder(strNewFolder)
			If (err.Number <> 0) Then
				Call addLogEntry("ERROR", err.Number & " (" & hex(err.Number) & ")		" & err.Source & ": " & err.Description & " on " & objfile.Path & vbNewLine)
				Err.Clear
			End if
		End If
	Loop
End Sub

' Utilities / Better recursive folder creation
Sub CreateDirs( MyDirName )
     Dim arrDirs, i, idxFirst, objFSO, strDir, strDirBuild
     Set objFSO = CreateObject( "Scripting.FileSystemObject" )
     strDir = objFSO.GetAbsolutePathName( MyDirName )
     arrDirs = Split( strDir, "\" )
     If Left( strDir, 2 ) = "\\" Then
         strDirBuild = "\\" & arrDirs(2) & "\" & arrDirs(3) & "\"
         idxFirst    = 4
     Else
         strDirBuild = arrDirs(0) & "\"
         idxFirst    = 1
     End If
     For i = idxFirst to Ubound( arrDirs )
         strDirBuild = objFSO.BuildPath( strDirBuild, arrDirs(i) )
         If Not objFSO.FolderExists( strDirBuild ) Then 
             objFSO.CreateFolder strDirBuild
         End if
     Next
     Set objFSO= Nothing
 End Sub

' ----------------------------------------------------------------------------
' Let's gather some debug infos
Call addLogEntry("APP", "** Starting " & CStr(objFileSys.GetFileName(WScript.ScriptFullName)) & "..." & vbNewLine)

Call addLogEntry("SYS", "Computer name:		" & objNetwork.ComputerName)
Call addLogEntry("SYS", "User:				" & IIF(IsEmpty(objNetwork.ComputerName), objNetwork.UserName, objNetwork.UserDomain & "\" & objNetwork.UserName))
For Each objOperatingSystem in colOperatingSystems
	dtmConvertedDate.Value = objOperatingSystem.InstallDate
	dtmInstallDate = dtmConvertedDate.GetVarDate
	Call addLogEntry("SYS", "Boot Device:		" & objOperatingSystem.BootDevice)
	Call addLogEntry("SYS", "Build Number:		" & objOperatingSystem.BuildNumber)
	Call addLogEntry("SYS", "Build Type:			" & objOperatingSystem.BuildType)
	Call addLogEntry("SYS", "Caption:			" & objOperatingSystem.Caption)
	Call addLogEntry("SYS", "Code Set:			" & objOperatingSystem.CodeSet)
	Call addLogEntry("SYS", "Country Code:		" & objOperatingSystem.CountryCode)
	Call addLogEntry("SYS", "Debug:				" & objOperatingSystem.Debug)
	Call addLogEntry("SYS", "Encryption Level:	" & objOperatingSystem.EncryptionLevel)
	Call addLogEntry("SYS", "Install Date:		" & dtmInstallDate)
	Call addLogEntry("SYS", "Licensed Users:		" &  objOperatingSystem.NumberOfLicensedUsers)
	Call addLogEntry("SYS", "Organization:		" & objOperatingSystem.Organization)
	Call addLogEntry("SYS", "OS Language:		" & objOperatingSystem.OSLanguage)
	Call addLogEntry("SYS", "OS Product Suite:	" & objOperatingSystem.OSProductSuite)
	Call addLogEntry("SYS", "OS Type:			" & objOperatingSystem.OSType)
	Call addLogEntry("SYS", "Primary:			" & objOperatingSystem.Primary)
	Call addLogEntry("SYS", "Registered User:	" & objOperatingSystem.RegisteredUser)
	Call addLogEntry("SYS", "Serial Number:		" & objOperatingSystem.SerialNumber)
	Call addLogEntry("SYS", "Version:			" & objOperatingSystem.Version & vbNewLine)
Next

' ----------------------------------------------------------------------------
' Checks / PowerShell
objRegistry = objWscriptShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\")
If Not(Err.Number = 0) Then
	Call addLogEntry("FAIL", "PowerShell not installed, exiting." & vbNewLine)
	Msgbox "This tool uses Microsoft PowerShell, but it is not installed." & vbNewLine & vbNewLine & "-----------------------------------" & vbNewLine & "This program will now terminate." & vbNewLine & "-----------------------------------", vbCritical + vbOKOnly, "PowerShell not detected"
	Wscript.Quit
End If

' ----------------------------------------------------------------------------
' Wizard
' Wizard / Folder
Call addLogEntry("INFO", "Prompting user for working folder")
Do While IsEmpty(strFolderPath) 
	strFolderPath = BrowseForFolder()
Loop
Call addLogEntry("INFO", "User selected """ & strFolderPath & """" & vbNewLine)
Call addLogEntry("INFO", "Prompting user for processing subdirectories")
intSubdirs = Msgbox("Should we also process ." & strTargetFileExtension & " files in subdirectories of " & strFolderPath & " as well?", vbQuestion + vbYesNo, "Subdirectories")
Call addLogEntry("INFO", "User selected " & IIF(intSubdirs = vbYes, """Yes""", """No""") & " for subdirectories" & vbNewLine)

' Wizard / Barcodes
Call addLogEntry("INFO", "Prompting user for resaving 1D Barcodes")
intAnswer1DCodes = Msgbox("Should we change the printer 1D/Linear Codes to graphic?", vbQuestion + vbYesNo, "1D Codes")
Call addLogEntry("INFO", "User selected " & IIF(intAnswer1DCodes = vbYes, """Yes""", """No""") & " for 1D codes" & vbNewLine)

Call addLogEntry("INFO", "Prompting user for resaving 2D Barcodes")
intAnswer2DCodes = Msgbox("Should we change the printer 2D/QR Codes to graphic?", vbQuestion + vbYesNo, "2D Codes")
Call addLogEntry("INFO", "User selected " & IIF(intAnswer2DCodes = vbYes, """Yes""", """No""") & " for 2D codes" & vbNewLine)

' Wizard / Images
Call addLogEntry("INFO", "Prompting user for generating QC images")
intAnswerImages = Msgbox("Should we generate images for quality control?" & vbNewLine & vbNewLine & "We will generate a " & strImageExtension & " image of each label upon opening, one other upon saving and they will be compared automatically against each other.", vbQuestion + vbYesNo, "Quality control images")
Call addLogEntry("INFO", "User selected " & IIF(intAnswerImages = vbYes, """Yes""", """No""") & " for QC images" & vbNewLine)


' ----------------------------------------------------------------------------
' Checks / GraphicsMagick
If (intAnswerImages = vbYes And (InStr(Replace(Trim(objWscriptShell.Exec("cmd /c ECHO %PATH%").StdOut.ReadAll), vbNewLine, vbNullString), "graphicsmagick") = 0)) Then
	Call addLogEntry("FAIL", "GraphicsMagick not present in '%PATH%' exiting." & vbNewLine)
	Msgbox "You chose to generate QC images, this feature requires the free thrid-party software 'GraphicsMagick' to be installed." & vbNewLine & vbNewLine & "Yet, GraphicsMagick was not detected in the environment variable '%PATH%'." & vbNewLine & vbNewLine & "Please go to <http://www.graphicsmagick.org/download.html> to obtain a copy of the Windows installer [GraphicsMagick-X.Y.ZZ-Q8-win64-dll.exe] and install it." & vbNewLine & vbNewLine & "-----------------------------------" & vbNewLine & "This program will now terminate." & vbNewLine & "-----------------------------------", vbCritical + vbOKOnly, "GraphicsMagick not detected"
	Wscript.Quit
End If


' ----------------------------------------------------------------------------
' Folder listing
' Clear the error stack
Err.Clear
' Call the folder/file recursor
Call addLogEntry("INFO", "Searching "& strFolderPath &" for ." & strTargetFileExtension & " files" &vbNewLine)
Recurse objFileSys.GetFolder(strFolderPath)

' ----------------------------------------------------------------------------
' End infos
Call addLogEntry("INFO", "Finished searching "& strFolderPath &" for ." & strTargetFileExtension & " files. Found " & l & " files in " & i & " folders.")
Call addLogEntry("INFO", "Closing all files still opened in CodeSoft")
objCodeSoft.Documents.CloseAll (false)
Call addLogEntry("INFO", "Closing CodeSoft" & vbNewLine)
objCodeSoft.quit

' ----------------------------------------------------------------------------
' Dump last error to log file
If (err.Number <> 0) Then
	Call addLogEntry("ERROR", err.Number & " (" & hex(err.Number) & ")		" & err.Source & ": " & err.Description & " on " & objfile.Path & vbNewLine)
	Err.Clear
End if

' ----------------------------------------------------------------------------
' Stats
dtEnd = now()
Call addLogEntry("APP", "** End of " & CStr(objFileSys.GetFileName(WScript.ScriptFullName)) & "..." & vbNewLine)
Call addLogEntry("STAT", "** Stats")
Call addLogEntry("STAT", "Start time:			" & sprintf("{0:HH:mm:ss}", Array(dtStart)))
Call addLogEntry("STAT", "End time:			" & sprintf("{0:HH:mm:ss}", Array(dtEnd)))
Call addLogEntry("STAT", "Duration:			" & Abs(DateDiff("n", dtStart, dtEnd)) & "		minute(s)")
Call addLogEntry("STAT", "Total processed:	" & i & "		folder(s)" )
Call addLogEntry("STAT", "Total processed:	" & l & "		file(s)" )
Call addLogEntry("STAT", "Total processed:	" & intNum1DBarcodes & "		1D barcode(s)" )
Call addLogEntry("STAT", "Total processed:	" & intNum2DBarcodes & "		2D barcode(s)" )
Call addLogEntry("STAT", "Total generated:	" & intNumImagesGenerated & "		images(s)" )
If (intAnswerImages = vbYes) Then
	Call addLogEntry("STAT", "Total:				" & intProblemImages & "		images(s) with error bigger than " & Round(intImageThreshold * 100, 0) & "%")
End If
Call addLogEntry("STAT", "Total read:			" & Round((intReadSize / (1024 * 1024)), 2) & "	Mb" )
Call addLogEntry("STAT", "Total written:		" & Round((intWriteSize / (1024 * 1024)), 2) & "	Mb" )
Call addLogEntry("STAT", "Avg. processed:		" & Round(intNum1DBarcodes / Abs(DateDiff("s", dtStart, dtEnd)), 2) & "	1D barcode(s)/second" )
Call addLogEntry("STAT", "Avg. processed:		" & Round(intNum2DBarcodes / Abs(DateDiff("s", dtStart, dtEnd)), 2) & "	2D barcode(s)/second" )
Call addLogEntry("STAT", "Avg. processed:		" & Round(l / Abs(DateDiff("s", dtStart, dtEnd)), 2) & "	file(s)/second" )
Call addLogEntry("STAT", "Avg. processed:		" & Round(i / Abs(DateDiff("s", dtStart, dtEnd)), 2) & "	folder(s)/second" )
Call addLogEntry("STAT", "Avg. read:			" & Round((intReadSize / (1024 * 1024)) / Abs(DateDiff("s", dtStart, dtEnd)), 2) & "	Mb/second" )
Call addLogEntry("STAT", "Avg. written:		" & Round((intWriteSize / (1024 * 1024)) / Abs(DateDiff("s", dtStart, dtEnd)), 2) & "	Mb/second" )
Call addLogEntry("STAT", "** Stats end" & vbNewLine)
If (intAnswerImages = vbYes) Then
	Call addLogEntry("FILES", "** Problem label files / Files with differences over " & Round(intImageThreshold * 100, 0) & "%")
	Call addLogEntry("FILES", "** Total " & intProblemImages & " files")
	Call addLogEntry("FILES", "** Just copy-paste the following lines in Excel" & vbNewLine)
	objLogFile.WriteLine strProblemLabelList
	Call addLogEntry("FILES", "** Problem label files end" & vbNewLine)
End If

' ----------------------------------------------------------------------------
' Main recursor
Sub Recurse(objFolder)
	Dim objFile, objSubFolder
	i = i + 1
	Call addLogEntry("INFO", "(Iteration " & i & ")	Recursing:								"& objFolder)
	For Each objFile In objFolder.Files
	If (LCase(objFileSys.GetExtensionName(objFile.Name)) = LCase(strTargetFileExtension)) Then
	If (err.Number <> 0) Then
		Call addLogEntry("ERROR", err.Number & " (" & hex(err.Number) & ")		" & err.Source & ": " & err.Description & " on " & objfile.Path & vbNewLine)
		Err.Clear
	End if
	l = l + 1
			If objFileSys.FileExists(objfile.Path) Then
				Call addLogEntry("INFO", "(File " & l & ")		Processing source file:				" & objfile.Path)
				Call addLogEntry("INFO", "(File " & l & ")		File owner:							" & GetFileOwner(objfile.Path))
				strDestinationLabFolder = Replace(CStr(objfile.ParentFolder), CStr(strFolderPath), CStr(strFolderPath & "_resaved_" & sprintf("{0:yyyyMMddHHmm}", Array(dtStart))))
				strDestinationImgFolder = Replace(CStr(objfile.ParentFolder), CStr(strFolderPath), CStr(strFolderPath & "_images_" & sprintf("{0:yyyyMMddHHmm}", Array(dtStart))))
				strDestinationLabFile = strDestinationLabFolder & "\" & objFile.Name
				strDestinationImgFile = strDestinationImgFolder & "\" & objFileSys.GetBaseName(objFile.Name)
				If (Not objFileSys.FolderExists(strDestinationLabFolder)) Then
					Call CreateDirs(strDestinationLabFolder)
				End If '/ If (Not objFileSys.FolderExists(strDestinationLabFolder)) Then
				If (Not objFileSys.FolderExists(strDestinationImgFolder)) Then
					Call CreateDirs(strDestinationImgFolder)
				End If '/ If (Not objFileSys.FolderExists(strDestinationImgFolder)) Then
				Call addLogEntry("INFO", "(File " & l & ")		Opening source file:				" & objfile.Name)
				Set objCodeSoftDocument = objCodeSoft.documents.open(Cstr(objfile.Path), True)
				If (intAnswerImages = vbYes) Then
					intNumImagesGenerated = intNumImagesGenerated + 1
					strBeforeImageFullPath = objCodeSoftDocument.CopyImageToFile(intImageBitsPerPx, strImageExtension, intImageRotation, intImageScaling, strDestinationImgFile & "_01_before")
					Call addLogEntry("INFO", "(File " & l & ")		Creating before image in 			"& strBeforeImageFullPath)
				End If
				Set objCodeSoftBarcodes = objCodeSoftDocument.DocObjects.Barcodes
				If (err.Number <> 0) Then
					Call addLogEntry("ERROR", err.Number & " (" & hex(err.Number) & ")		" & err.Source & ": " & err.Description & " on " & objfile.Path & vbNewLine)
					Err.Clear
				End if
				intReadSize = intReadSize + objfile.Size
				blnHas1D = false
				blnHas2D = false
				For b = 1 to objCodeSoftBarcodes.Count
					If ((intAnswer1DCodes = vbYes Or intAnswer2DCodes = vbYes) And (CInt(objCodeSoftBarcodes.Count) > 0)) Then
						Call addLogEntry("INFO", "(File " & l & ")		Processing barcode " & b & " of " & CInt(objCodeSoftDocument.DocObjects.Barcodes.Count) & " from:		"& objfile.Name)
						If (objCodeSoftBarcodes.Item(b).is2D() And objCodeSoftBarcodes.Item(b).Device = True And intAnswer2DCodes = vbYes) Then
							blnHas2D = true
							Call addLogEntry("INFO", "(File " & l & ")		Processing 2D barcode #" & b & " from:		" & objfile.Name)
							Call addLogEntry("INFO", "(File " & l & ")		2D barcode #" & b & "'s symbology is: " & dictSymbolgy(objCodeSoftBarcodes.Item(b).Symbology))
							Call addLogEntry("INFO", "(File " & l & ")		2D barcode #" & b & "'s variable name is: " & objCodeSoftBarcodes.Item(b).VariableName)
							Call addLogEntry("INFO", "(File " & l & ")		2D barcode #" & b & "'s value is: " & objCodeSoftBarcodes.Item(b).Value)
							Call addLogEntry("INFO", "(File " & l & ")		2D barcode #" & b & " is " & IIF(objCodeSoftBarcodes.Item(b).Device = True, "generated on printer", "graphic"))
							If (objCodeSoftBarcodes.Item(b).Device) Then
								objCodeSoftBarcodes.Item(b).Device = False
								Call addLogEntry("INFO", "(File " & l & ")		2D barcode #" & b & " changed to graphic")
							End If '/ If (objCodeSoftBarcodes.Item(b).Device)'
							intNum2DBarcodes = intNum2DBarcodes + 1
						ElseIf (Not(objCodeSoftBarcodes.Item(b).is2D()) And objCodeSoftBarcodes.Item(b).Device = True And intAnswer1DCodes = vbYes) Then
							blnHas1D = true
							Call addLogEntry("INFO", "(File " & l & ")		Processing 1D #" & b & " barcode from:		" & objfile.Name)
							Call addLogEntry("INFO", "(File " & l & ")		1D barcode #" & b & "'s symbology is: " & dictSymbolgy(objCodeSoftBarcodes.Item(b).Symbology))
							Call addLogEntry("INFO", "(File " & l & ")		1D barcode #" & b & "'s variable name is: " & objCodeSoftBarcodes.Item(b).VariableName)
							Call addLogEntry("INFO", "(File " & l & ")		1D barcode #" & b & "'s value is: " & objCodeSoftBarcodes.Item(b).Value)
							Call addLogEntry("INFO", "(File " & l & ")		1D barcode #" & b & " is " & IIF(objCodeSoftBarcodes.Item(b).Device = True, "generated on printer", "graphic"))
							If (objCodeSoftBarcodes.Item(b).Device) Then
								objCodeSoftBarcodes.Item(b).Device = False
								Call addLogEntry("INFO", "(File " & l & ")		1D barcode #" & b & " changed to graphic")
							End If '/ If (objCodeSoftBarcodes.Item(b).Device)'
								intNum1DBarcodes = intNum1DBarcodes + 1
						Else
							If Not(objCodeSoftBarcodes.Item(b).Device) Then
								Call addLogEntry("INFO", "(File " & l & ")		Barcode #" & b & " skipped (already graphic).")
							ElseIf (Not(objCodeSoftBarcodes.Item(b).is2D()) And intAnswer1DCodes = vbNo) Then
								Call addLogEntry("INFO", "(File " & l & ")		Barcode #" & b & " skipped (barcode is 1D and user doesn't want to convert 1D codes).")
							ElseIf (objCodeSoftBarcodes.Item(b).is2D() And intAnswer2DCodes = vbNo) Then
								Call addLogEntry("INFO", "(File " & l & ")		Barcode #" & b & " skipped (barcode is 2D and user doesn't want to convert 2D codes).")
							End If
						End If '/ If (objCodeSoftBarcodes.Item(b).is2D() And intAnswer2DCodes = vbYes) Then
					End If '/ If ((intAnswer1DCodes = vbYes Or intAnswer2DCodes = vbYes) And (CInt(objCodeSoftDocument.DocObjects.Barcodes.Count) > 0)) Then
				Next '/ For b = 0 to objCodeSoftDocument.DocObjects.Barcodes.Count
				Call addLogEntry("INFO", "(File " & l & ")		Saving destination file:			"& strDestinationLabFile)
				' Saves the label file in the new folder
				objCodeSoftDocument.SaveAs(strDestinationLabFile)
				If (err.Number <> 0) Then
					Call addLogEntry("ERROR", err.Number & " (" & hex(err.Number) & ")		" & err.Source & ": " & err.Description & " on " & objfile.Path & vbNewLine)
					Err.Clear
				End if
				intWriteSize = intWriteSize + objFileSys.GetFile(strDestinationLabFile).Size
				If (intAnswerImages = vbYes) Then
					intNumImagesGenerated = intNumImagesGenerated + 1
					strAfterImageFullPath = objCodeSoftDocument.CopyImageToFile(intImageBitsPerPx, strImageExtension, intImageRotation, intImageScaling, strDestinationImgFile & "_02_after")
					strDiffImageFullPath = strDestinationImgFile & "_03_diff." & strImageExtension
					Call addLogEntry("INFO", "(File " & l & ")		Creating after image in				"& strAfterImageFullPath)
					If (objFileSys.FileExists(strBeforeImageFullPath) And objFileSys.FileExists(strAfterImageFullPath)) Then
						Call addLogEntry("INFO", "(File " & l & ")		Both images exist, starting comparison")
						Call addLogEntry("INFO", "(File " & l & ")		Creating difference image in		"& strDiffImageFullPath)
						Set objWscriptShellExec = objWscriptShell.Exec("gm compare -highlight-style assign -highlight-color red -metric MAE -file """ & strDiffImageFullPath & """ """ & strBeforeImageFullPath & """ """ & strAfterImageFullPath & """ : 2>&1")
						Do While objWscriptShellExec.Status = 0
							WScript.Sleep 100
						Loop
						strGMOutput = objWscriptShellExec.StdOut.ReadAll
						Set objMatch = objRE.Execute(strGMOutput)
						sngMeanAbsoluteErrorTotal = CSng(objMatch.Item(0).Submatches(1))
						If (sngMeanAbsoluteErrorTotal > intImageThreshold) Then
							intProblemImages = intProblemImages + 1
							strProblemLabelList = strProblemLabelList & Chr(34) & "=HYPERLINK(" & Chr(34) & Chr(34) & strDiffImageFullPath & Chr(34) & Chr(34) & ")" & Chr(34) & vbTab & sngMeanAbsoluteErrorTotal &vbTab & Chr(34) & Replace(Trim(GetFileOwner(objfile.Path)), vbNewLine, vbNullString) & Chr(34) & vbTab & blnHas1D & vbTab & blnHas2D & vbTab & Chr(34) & "=HYPERLINK(" & Chr(34) & Chr(34) & strDestinationLabFile & Chr(34) & Chr(34) & ")" & Chr(34) & vbTab & Chr(34) & "=HYPERLINK(" & Chr(34) & Chr(34) & objfile.Path & Chr(34) & Chr(34) & ")" & Chr(34) & vbNewLine
							Call addLogEntry("WARN", "(File " & l & ")		Mean Absolute Error (Total): " & Round(sngMeanAbsoluteErrorTotal * 100, 1) & "% *** Differences found! Please check " & strDestinationLabFile & " ***")
						Else
							Call addLogEntry("INFO", "(File " & l & ")		Mean Absolute Error (Total): " & Round(sngMeanAbsoluteErrorTotal * 100, 1) & "% (below " & Round(intImageThreshold * 100, 0) & "% threshold)")
						End If
						Call addLogEntry("INFO", "(File " & l & ")		Comparison finished")
					End If
				End If
				Call addLogEntry("INFO", "(File " & l & ")		Closing file:						" & objFile.Name & vbNewLine)
				objCodeSoftDocument.Close(false)
				If (err.Number <> 0) Then
					Call addLogEntry("ERROR", err.Number & " (" & hex(err.Number) & ")		" & err.Source & ": " & err.Description & " on " & objfile.Path & vbNewLine)
					Err.Clear
				End if
			End If '/ If objFileSys.FileExists(objfile.Path) Then
		End If '/ If (LCase(objFileSys.GetExtensionName(objFile.Name)) = LCase(strTargetFileExtension)) Then
	Next
	If (intSubdirs = vbYes) Then
		For Each objSubFolder In objFolder.SubFolders
			Recurse objSubFolder
		Next
	End If
End Sub