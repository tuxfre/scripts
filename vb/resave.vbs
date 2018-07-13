' resave.vbs
' VBScript program to resave CodeSoft Files
'
' ----------------------------------------------------------------------------
' Requires
' - Microsoft Access Database Engine 2010 Redistributable 64bits
'   (AccessDatabaseEngine_X64.exe)
'   from  https://www.microsoft.com/en-gb/download/details.aspx?id=13255
' - CodeSoft Entreprise 15 or later
'   from https://www.teklynx.com/en-EMEA/products/label-design-solutions/codesoft
' 
' ----------------------------------------------------------------------------
' Copyright (c) 2018 Benjamin Vigier
' Version 1.0 - July 10, 2018
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
' - Richard L. Mueller	(ReadCSVFile.vbs)				http://www.rlmueller.net/ReadCSV.htm
' - PatricK				(Select file answer on SO)		https://stackoverflow.com/a/21565999
' - Mike Harris 		(Date format answer on SO)		https://stackoverflow.com/a/28808377
' - Paul Frankovich		(vbScript logger)				https://bit.ly/2m7DkPP
' - Teklynx				(CodeSoft VB Samples)			C:\Users\Public\Documents\Teklynx\CODESOFT 2015\Samples\Integration
'
' ----------------------------------------------------------------------------

' Let's make our life harder by having to explicitely declare all variables, just for the lolz
Option Explicit
' ----------------------------------------------------------------------------

' Let's declare (all) our variables
Dim adoCSVConnection, adoCSVRecordSet
Dim strRenamedFolderSuffix, strUploadCSV, strPathCSVFile, strNameCSVFile, strCurrentLabel, strPathCurrentLabel, strNameCurrentLabel, strPathNewLabel
Dim objFileUploadShell, objFileUploadShellExec, objFSOCSVFile, objCSVFile, objFSOLabelFile, objLabelFile, objFSOLogFile, objLogFile
Dim objStringBuilder : Set objStringBuilder = CreateObject("System.Text.StringBuilder")
Dim dt : dt = now()
Dim k, numCSVPathColNum
Dim objCodeSoft, objCSDocument
' ----------------------------------------------------------------------------

' Utilities
Function sprintf(sFmt, aData)
	objStringBuilder.AppendFormat_4 sFmt, (aData)
	sprintf = objStringBuilder.ToString()
	objStringBuilder.Length = 0
End Function

' Logging
Set objFSOLogFile = CreateObject("Scripting.FileSystemObject")
Set objLogFile = objFSOLogFile.CreateTextFile(CStr(objFSOLogFile.GetParentFolderName(WScript.ScriptFullName)) & "\resave-vbs_log_"& sprintf("{0:yyyyMMddhhmm}", Array(dt)) & ".log")
Function addLogEntry(strLevel, strMessage)
	objLogFile.WriteLine "[" & sprintf("{0:yyyy MM dd HH:mm:ss}", Array(now())) & " | " & strLevel & "]	" & strMessage  
End Function

' ----------------------------------------------------------------------------

' Configuration
' Column that holds the the path to our label file (beware first column has index 0), user will also be prompted for this
numCSVPathColNum = 7
' The subfolder where we will store the resaved files 
strRenamedFolderSuffix = "_resaved_" & sprintf("{0:yyyyMMddHHmm}", Array(dt))
' ----------------------------------------------------------------------------

' Program
' Creates a file select dialog for our CSV Source file 
' Creates the Wscript shell object used to browse the filesystem
Set objFileUploadShell = CreateObject("WScript.Shell")
' Shows the file upload window
Set objFileUploadShellExec = objFileUploadShell.Exec("mshta.exe ""about:<input type=file id=FILE><script>FILE.click();new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).WriteLine(FILE.value);close();resizeTo(0,0);</script>""")
' Returns the path
strUploadCSV = objFileUploadShellExec.StdOut.ReadLine
' Creates a File System Object in order to parse file path
Set objFSOCSVFile = CreateObject("Scripting.FileSystemObject")
' Uses the path from our previously selected file
Set objCSVFile = objFSOCSVFile.GetFile(strUploadCSV)
strPathCSVFile = objFSOCSVFile.GetParentFolderName(objCSVFile)
strNameCSVFile = objFSOCSVFile.GetFileName(objCSVFile)

' Asks the user which column index to use for the full path to the label file (ex. L:\Labels\Production_CS15_wrong\Labels\SAP\Customer\L0009AAC_2.lab)
numCSVPathColNum = CInt(InputBox("Please enter the index (number) of the column that contains the full label path" & vbNewLine & vbNewLine & vbNewLine & "(Beware! column #1 has index 0, column #2 has index 1, etc...)", "Path" , numCSVPathColNum))

' Opens connection to the CSV file.
Set adoCSVConnection = CreateObject("ADODB.Connection")
Set adoCSVRecordSet = CreateObject("ADODB.Recordset")

' Opens CSV file with header line.
adoCSVConnection.Open "Provider=Microsoft.ACE.OLEDB.12.0;" & _
	"Data Source=" & strPathCSVFile & ";" & _
	"Extended Properties=""text;HDR=YES;FMT=Delimited"""

' Extracts data via an ADO/SQL request on the CSV file (basic request)
adoCSVRecordset.Open "SELECT * FROM [" & strNameCSVFile & "]", adoCSVConnection

' Creates a CodeSoft oject
Set objCodeSoft = createObject ("lppx2.application")
'objCodeSoft.Application.Visible = true

' Create a File System Object to manipulate label file names and paths
Set objFSOLabelFile = CreateObject("Scripting.FileSystemObject")

Call addLogEntry("INFO", "Starting reading CSV file ..." & vbNewLine)

' Reads the CSV file.
Do Until adoCSVRecordset.EOF
	' Stores the path to the current label file 
	strCurrentLabel = CStr(adoCSVRecordset.Fields(numCSVPathColNum).Value)
	' Checks if the file exists on the filesystem
	If objFSOLabelFile.FileExists(strCurrentLabel) Then
		' Gets path and name for the current file
		Set objLabelFile = objFSOLabelFile.GetFile(strCurrentLabel)
		strPathCurrentLabel = objFSOLabelFile.GetParentFolderName(objLabelFile)
		strNameCurrentLabel = objFSOLabelFile.GetFileName(objLabelFile)
		' Generates the new path where the file will be saved
		strPathNewLabel = CStr(strPathCurrentLabel & "\" & strRenamedFolderSuffix)
		' Creates the destination folder if it doesn't exist
		If Not objFSOLabelFile.FolderExists(strPathNewLabel) Then 
			objFSOLabelFile.CreateFolder (strPathNewLabel) 
		End If
		' Opens the label file in CodeSoft
		Set objCSDocument = objCodeSoft.documents.open(strCurrentLabel, false)
		' Sqves the label file in the new folder
		objCSDocument.SaveAs(strPathNewLabel & "\" & strNameCurrentLabel)
		' Closes the label file
		objCSDocument.Close(false)
		Call addLogEntry("INFO", "Resaved file	" & strCurrentLabel & vbNewLine & "										to		" & strPathNewLabel & "\" & strNameCurrentLabel & vbNewLine)
	End If
	adoCSVRecordset.MoveNext
Loop

' Cleans up 
adoCSVRecordset.Close
adoCSVConnection.Close
objCodeSoft.Documents.CloseAll (false)
objCodeSoft.quit
Call addLogEntry("INFO", "Finished reading CSV file ...")