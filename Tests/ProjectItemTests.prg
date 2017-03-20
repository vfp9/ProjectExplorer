* This is used in Test_EditItem_CallsClassBrowserForClasslib

lparameters tcFileName
public plClassBrowserCalled
plClassBrowserCalled = .T.

*******************************************************************************
define class ProjectItemTests as FxuTestCase of FxuTestCase.prg
*******************************************************************************
	#IF .f.
	LOCAL THIS AS ProjectItemTests OF ProjectItemTests.PRG
	#ENDIF
	
	cTestFolder     = ''
	cTestDataFolder = ''
	cTestProgram    = ''
	icTestPrefix    = 'Test_'
	
	oItem           = .NULL.
	oProject        = .NULL.
	cCurrPath       = ''
	cFile           = ''
	lExecuteFileCalled    = .F.
	cExecuteFileOperation = ''
	dimension aTypes[1]

*******************************************************************************
* Setup for the tests
*******************************************************************************
	function Setup

* Get the folder the tests are running from, the name of this test
* program, and create a test data folder if necessary.

		lcProgram            = sys(16)
		This.cTestProgram    = substr(lcProgram, at(' ', lcProgram, 2) + 1)
		This.cTestFolder     = addbs(justpath(This.cTestProgram))
		This.cTestDataFolder = This.cTestFolder + 'TestData\'
		if not directory(This.cTestDataFolder)
			md (This.cTestDataFolder)
		endif not directory(This.cTestDataFolder)

* Set up other things.

		This.oItem = newobject('ProjectItem', ;
			'Source\ProjectExplorerItems.vcx')

* This array defines the different types of items and what the expected
* capability is: column 2 is whether it's a file, column 3 is whether it can be
* edited, column 4 is whether it can be included in the project, column 5 is
* whether it can be removed, column 6 is whether it can be run, column 7 is
* whether it can be the main file, column 8 is whether it can be renamed,
* column 9 is whether the item has a description.

		dimension This.aTypes[21, 9]
		This.aTypes[ 1, 1] = 'ProjectItemApplication'
		This.aTypes[ 2, 1] = 'ProjectItemClass'
		This.aTypes[ 3, 1] = 'ProjectItemClasslib'
		This.aTypes[ 4, 1] = 'ProjectItemConnection'
		This.aTypes[ 5, 1] = 'ProjectItemDatabase'
		This.aTypes[ 6, 1] = 'ProjectItemField'
		This.aTypes[ 7, 1] = 'ProjectItemForm'
		This.aTypes[ 8, 1] = 'ProjectItemFreeTable'
		This.aTypes[ 9, 1] = 'ProjectItemIndex'
		This.aTypes[10, 1] = 'ProjectItemLabel'
		This.aTypes[11, 1] = 'ProjectItemLibrary'
		This.aTypes[12, 1] = 'ProjectItemLocalView'
		This.aTypes[13, 1] = 'ProjectItemMenu'
		This.aTypes[14, 1] = 'ProjectItemOther'
		This.aTypes[15, 1] = 'ProjectItemProgram'
		This.aTypes[16, 1] = 'ProjectItemQuery'
		This.aTypes[17, 1] = 'ProjectItemRemoteView'
		This.aTypes[18, 1] = 'ProjectItemReport'
		This.aTypes[19, 1] = 'ProjectItemStoredProc'
		This.aTypes[20, 1] = 'ProjectItemTableInDBC'
		This.aTypes[21, 1] = 'ProjectItemText'
		for lnI = 1 to alen(This.aTypes, 1)
			lcType = This.aTypes[lnI, 1]
			This.aTypes[lnI, 2] = lcType == 'ProjectItemClasslib' or ;
				not inlist(lcType, 'ProjectItemClass', ;
				'ProjectItemConnection', 'ProjectItemField', ;
				'ProjectItemIndex', 'ProjectItemLocalView', ;
				'ProjectItemRemoteView', 'ProjectItemStoredProc')
				&& everything but these is a file
			This.aTypes[lnI, 3] = lcType <> 'ProjectItemLibrary'
				&& can edit anything but an API library, although there are
				&& special cases for Other and Application
			This.aTypes[lnI, 4] = not inlist(lcType, 'ProjectItemLibrary', ;
				'ProjectItemApplication') and This.aTypes[lnI, 2]
				&& can include any file except API library and application
			This.aTypes[lnI, 5] = This.aTypes[lnI, 2] or ;
				inlist(lcType, 'ProjectItemClass', 'ProjectItemConnection', ;
				'ProjectItemLocalView', 'ProjectItemRemoteView', ;
				'ProjectItemTableInDBC')
				&& can remove any file plus these items
			This.aTypes[lnI, 6] = inlist(lcType, 'ProjectItemApplication', ;
				'ProjectItemField', 'ProjectItemForm', ;
				'ProjectItemFreeTable', 'ProjectItemIndex', ;
				'ProjectItemLabel', 'ProjectItemLocalView', ;
				'ProjectItemMenu', 'ProjectItemProgram', ;
				'ProjectItemQuery', 'ProjectItemRemoteView', ;
				'ProjectItemReport', 'ProjectItemTableInDBC')
				&& can run forms, programs, reports, labels, free tables,
				&& tables in a DBC, fields, indexes, views, queries, menus, and
				&& applications
			This.aTypes[lnI, 7] = inlist(lcType, 'ProjectItemProgram', ;
				'ProjectItemForm')
				&& can set programs and forms as main
			This.aTypes[lnI, 8] = This.aTypes[lnI, 2] or ;
				inlist(lcType, 'ProjectItemClass', 'ProjectItemConnection', ;
				'ProjectItemLocalView', 'ProjectItemRemoteView', ;
				'ProjectItemTableInDBC')
				&& can rename any file plus these items
*** TODO: handle index to if necessary
			This.aTypes[lnI, 9] = This.aTypes[lnI, 2] or ;
				not inlist(lcType, 'ProjectItemStoredProc')
				&& any file plus all items except these has a description
		next lnI

* Create a project and a file.

		This.oProject = createobject('MockProject')
		This.cFile    = This.cTestDataFolder + sys(2015) + '.txt'
		strtofile('xxx', This.cFile)

* Save the current path and set it.

		This.cCurrPath = set('PATH')
		set path to 'Source' additive
	endfunc

*******************************************************************************
* Clean up on exit.
*******************************************************************************
	function TearDown
		set path to (This.cCurrPath)
		erase (This.cFile)
	endfunc

*******************************************************************************
* Helper method to bind to ExecuteFile
*******************************************************************************
	function ExecuteFileCalled(tcFileName, tcOperation)
		This.cExecuteFileOperation = tcOperation
		This.lExecuteFileCalled    = .T.
	endfunc

*******************************************************************************
* Test that ProjectItem has a Tags collection
*******************************************************************************
	function Test_Init_CreatesTags
		This.AssertTrue(vartype(This.oItem.Tags) = 'O', ;
			'Did not create Tags collection')
	endfunc

*******************************************************************************
* Test that SaveTagString saves tags
*******************************************************************************
	function Test_SaveTagString_SavesTags
		This.oItem.SaveTagString('tag1' + chr(13) + 'tag2')
		This.AssertTrue(This.oItem.Tags.Count = 2, ;
			'Did not save tags')
	endfunc

*******************************************************************************
* Test that SaveTagString only saves last tags
*******************************************************************************
	function Test_SaveTagString_OnlySavesLastTags
		This.oItem.SaveTagString('tag1' + chr(13) + 'tag2')
		This.oItem.SaveTagString('tag3' + chr(13) + 'tag4')
		This.AssertTrue(This.oItem.Tags.Count = 2, ;
			'Added to previous tags')
	endfunc

*******************************************************************************
* Test that GetTagString returns blank when no tags
*******************************************************************************
	function Test_GetTagString_ReturnsBlank_NoTags
		lcTags = This.oItem.GetTagString()
		This.AssertTrue(empty(lcTags), ;
			'Returned non-blank')
	endfunc

*******************************************************************************
* Test that GetTagString returns tags
*******************************************************************************
	function Test_GetTagString_ReturnsTags
		lcSource = 'tag1' + chr(13) + chr(10) + 'tag2' + chr(13) + chr(10)
		This.oItem.SaveTagString(lcSource)
		lcTags = This.oItem.GetTagString()
		This.AssertEquals(lcTags, lcSource, ;
			'Did not return correct tags')
	endfunc

*******************************************************************************
* Test that GetTagString returns tags comma-delimited
*******************************************************************************
	function Test_GetTagString_ReturnsTagsCommaDelimited
		lcSource = 'tag1' + chr(13) + 'tag2'
		This.oItem.SaveTagString(lcSource)
		lcTags = This.oItem.GetTagString(.T.)
		This.AssertEquals(lcTags, strtran(lcSource, chr(13), ','), ;
			'Did not return correct tags')
	endfunc

*******************************************************************************
* Test that IsFile is set the way it's supposed to be
*******************************************************************************
	function Test_IsFile_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 2], loItem.IsFile, ;
				'IsFile not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that CanEdit is set the way it's supposed to be
*******************************************************************************
	function Test_CanEdit_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			do case
				case This.aTypes[lnI, 1] = 'ProjectItemApplication'
					loItem.Path = This.cTestDataFolder + sys(2015) + '.pjx'
					strtofile('x', loItem.Path)
				case This.aTypes[lnI, 1] = 'ProjectItemOther'
					loItem.Path = This.cTestDataFolder + sys(2015) + '.bmp'
					strtofile('x', loItem.Path)
			endcase
			llCanEdit = loItem.CanEdit
			if not empty(loItem.Path)
				erase (loItem.Path)
			endif not empty(loItem.Path)
			This.AssertEquals(This.aTypes[lnI, 3], llCanEdit, ;
				'CanEdit not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that CanEdit is set the way it's supposed to be for non-existent project
*******************************************************************************
	function Test_CanEdit_Correct_NonExistentProject
		loItem = newobject('ProjectItemApplication', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = This.cTestDataFolder + sys(2015) + '.pjx'
		This.AssertFalse(loItem.CanEdit, ;
			'CanEdit not correct when no project for ProjectItemApplication')
	endfunc

*******************************************************************************
* Test that CanEdit is set the way it's supposed to be for non-image
*******************************************************************************
	function Test_CanEdit_Correct_NonImage
		loItem = newobject('ProjectItemOther', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = This.cTestDataFolder + sys(2015) + '.xxx'
		This.AssertFalse(loItem.CanEdit, ;
			'CanEdit not correct when not image for ProjectItemOther')
	endfunc

*******************************************************************************
* Test that CanInclude is set the way it's supposed to be
*******************************************************************************
	function Test_CanInclude_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 4], loItem.CanInclude, ;
				'CanInclude not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that CanRemove is set the way it's supposed to be
*******************************************************************************
	function Test_CanRemove_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 5], loItem.CanRemove, ;
				'CanRemove not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that CanRun is set the way it's supposed to be
*******************************************************************************
	function Test_CanRun_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 6], loItem.CanRun, ;
				'CanRun not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that CanSetMain is set the way it's supposed to be
*******************************************************************************
	function Test_CanSetMain_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 7], loItem.CanSetMain, ;
				'CanSetMain not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that CanRename is set the way it's supposed to be
*******************************************************************************
	function Test_CanRename_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 8], loItem.CanRename, ;
				'CanRename not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that HasDescription is set the way it's supposed to be
*******************************************************************************
	function Test_HasDescription_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 9], loItem.HasDescription, ;
				'HasDescription not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that Clone creates a clone
*******************************************************************************
	function Test_Clone_CreatesClone
		loItem = This.oItem.Clone()
		This.AssertEquals('projectitem', lower(loItem.Class), ;
			'Did not create clone of correct class')
	endfunc

*******************************************************************************
* Test that Clone clones properties
*******************************************************************************
	function Test_Clone_ClonesProperties
		This.oItem.Type = 'Z'
		loItem = This.oItem.Clone()
		This.AssertEquals('Z', loItem.Type, ;
			'Did not copy properties')
	endfunc

*******************************************************************************
* Test that Clone clones Tags
*******************************************************************************
	function Test_Clone_ClonesTags
		lcTags = 'a' + chr(13) + chr(10) + 'b' + chr(13) + chr(10)
		This.oItem.SaveTagString(lcTags)
		loItem = This.oItem.Clone()
		lcCloneTags = loItem.GetTagString()
		This.AssertEquals(lcTags, lcCloneTags, ;
			'Did not copy Tags')
	endfunc

*******************************************************************************
* Test that UpdateFromClone fails if invalid item passed (this actually tests
* all the ways it can fail)
*******************************************************************************
	function Test_UpdateFromClone_Fails_InvalidObject
		llOK = This.oItem.UpdateFromClone()
		This.AssertFalse(llOK, 'Returned .T. with no object passed')
		llOK = This.oItem.UpdateFromClone(createobject('Line'))
		This.AssertFalse(llOK, 'Returned .T. with wrong class of object passed')
	endfunc

*******************************************************************************
* Test that UpdateFromClone clones properties
*******************************************************************************
	function Test_UpdateFromClone_ClonesProperties
		This.oItem.Type = 'Z'
		loItem = This.oItem.Clone()
		loItem.Type = 'A'
		This.oItem.UpdateFromClone(loItem)
		This.AssertEquals('A', This.oItem.Type, ;
			'Did not copy properties')
	endfunc

*******************************************************************************
* Test that UpdateFromClone clones Tags
*******************************************************************************
	function Test_UpdateFromClone_ClonesTags
		loItem = This.oItem.Clone()
		lcTags = 'a' + chr(13) + chr(10) + 'b' + chr(13) + chr(10)
		loItem.SaveTagString(lcTags)
		This.oItem.UpdateFromClone(loItem)
		lcCloneTags = This.oItem.GetTagString()
		This.AssertEquals(lcTags, lcCloneTags, ;
			'Did not copy Tags')
	endfunc

*******************************************************************************
* Test that RemoveItem removes file from project
*******************************************************************************
	function Test_RemoveItem_RemovesItem
		This.oProject.Files.Add(This.cFile)
		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = This.cFile
		loItem.RemoveItem(This.oProject)
		This.AssertTrue(This.oProject.Files.Count = 0, 'Did not remove item')
	endfunc

*******************************************************************************
* Test that RemoveItem deletes the file
*******************************************************************************
	function Test_RemoveItem_DeletesFile
		loFile = This.oProject.Files.Add(This.cFile)
		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = This.cFile
		loItem.RemoveItem(This.oProject, .T.)
		This.AssertTrue(loFile.lDeleteFile, 'Did not delete file')
	endfunc

*******************************************************************************
* Test that RemoveItem deletes a class
*******************************************************************************
	function Test_RemoveItem_DeletesClass

* Create a class in a class library.

		text to lcXML noshow
<?xml version = "1.0" encoding="Windows-1252" standalone="yes"?>
<VFPData>
	<test>
		<platform>COMMENT</platform>
		<uniqueid>Class</uniqueid>
		<timestamp>0</timestamp>
		<class/>
		<classloc/>
		<baseclass/>
		<objname/>
		<parent/>
		<properties/>
		<protected/>
		<methods/>
		<objcode/>
		<ole/>
		<ole2/>
		<reserved1>VERSION =   3.00</reserved1>
		<reserved2/>
		<reserved3/>
		<reserved4/>
		<reserved5/>
		<reserved6/>
		<reserved7/>
		<reserved8/>
		<user/>
	</test>
	<test>
		<platform>WINDOWS</platform>
		<uniqueid>_4UZ0SGY1D</uniqueid>
		<timestamp>1247898146</timestamp>
		<class>custom</class>
		<classloc/>
		<baseclass>custom</baseclass>
		<objname>test</objname>
		<parent/>
		<properties>Name = "test"
</properties>
		<protected/>
		<methods/>
		<objcode/>
		<ole/>
		<ole2/>
		<reserved1>Class</reserved1>
		<reserved2>1</reserved2>
		<reserved3/>
		<reserved4/>
		<reserved5/>
		<reserved6>Pixels</reserved6>
		<reserved7/>
		<reserved8/>
		<user/>
	</test>
	<test>
		<platform>COMMENT</platform>
		<uniqueid>RESERVED</uniqueid>
		<timestamp>0</timestamp>
		<class/>
		<classloc/>
		<baseclass/>
		<objname>test</objname>
		<parent/>
		<properties/>
		<protected/>
		<methods/>
		<objcode/>
		<ole/>
		<ole2/>
		<reserved1/>
		<reserved2/>
		<reserved3/>
		<reserved4/>
		<reserved5/>
		<reserved6/>
		<reserved7/>
		<reserved8/>
		<user/>
	</test>
</VFPData>
		endtext
		lcCursor = sys(2015)
		select * from Source\ProjectExplorerMenu.vcx into cursor (lcCursor) nofilter readwrite
		delete all
		xmltocursor(lcXML, lcCursor, 8192)
		copy to (This.cTestDataFolder + 'test.vcx')
		use
		use in ProjectExplorerMenu

* Do the test.

		loItem = newobject('ProjectItemClass', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path     = This.cTestDataFolder + 'test.vcx'
		loItem.ItemName = 'test'
		loItem.RemoveItem()
		use (This.cTestDataFolder + 'test.vcx')
		locate for OBJNAME = 'test'
		llOK = not found()
		use
		erase (This.cTestDataFolder + 'test.vcx')
		erase (This.cTestDataFolder + 'test.vct')
		This.AssertTrue(llOK, 'Did not delete class')
	endfunc

*******************************************************************************
* Test that RemoveItem removes a table in a DBC.
*******************************************************************************
	function Test_RemoveItem_RemovesTable

* Create a table in a database.

		create database (This.cTestDataFolder + 'test')
		create table (This.cTestDataFolder + 'test') (field1 c(1))
		close databases

* Do the test.

		loItem = newobject('ProjectItemTableInDBC', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath = This.cTestDataFolder + 'test.dbc'
		loItem.Path       = This.cTestDataFolder + 'test.dbf'
		loItem.ItemName   = 'test'
		loItem.RemoveItem(This.oProject)
		llOK = not indbc('test', 'Table')
		close databases
		erase (This.cTestDataFolder + 'test.dbc')
		erase (This.cTestDataFolder + 'test.dct')
		erase (This.cTestDataFolder + 'test.dcx')
		erase (This.cTestDataFolder + 'test.dbf')
		This.AssertTrue(llOK, 'Did not remove table')
	endfunc

*******************************************************************************
* Test that RemoveItem deletes a table in a DBC.
*******************************************************************************
	function Test_RemoveItem_DeletesTable

* Create a table in a database.

		create database (This.cTestDataFolder + 'test')
		create table (This.cTestDataFolder + 'test') (field1 c(1))
		close databases

* Do the test.

		loItem = newobject('ProjectItemTableInDBC', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath = This.cTestDataFolder + 'test.dbc'
		loItem.Path       = This.cTestDataFolder + 'test.dbf'
		loItem.ItemName   = 'test'
		loItem.RemoveItem(This.oProject, .T.)
		close databases
		llOK = not file(This.cTestDataFolder + 'test.dbf')
		erase (This.cTestDataFolder + 'test.dbc')
		erase (This.cTestDataFolder + 'test.dct')
		erase (This.cTestDataFolder + 'test.dcx')
		This.AssertTrue(llOK, 'Did not delete table')
	endfunc

*******************************************************************************
* Test that RemoveItem removes a local view.
*******************************************************************************
	function Test_RemoveItem_RemovesLocalView

* Create a table and a view in a database.

		create database (This.cTestDataFolder + 'test')
		create table (This.cTestDataFolder + 'test') (field1 c(1))
		create view testview as select * from test
		close databases

* Do the test.

		loItem = newobject('ProjectItemLocalView', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath = This.cTestDataFolder + 'test.dbc'
		loItem.ItemName   = 'testview'
		loItem.RemoveItem(This.oProject)
		llOK = not indbc('testview', 'View')
		close databases
		erase (This.cTestDataFolder + 'test.dbc')
		erase (This.cTestDataFolder + 'test.dct')
		erase (This.cTestDataFolder + 'test.dcx')
		erase (This.cTestDataFolder + 'test.dbf')
		This.AssertTrue(llOK, 'Did not remove view')
	endfunc

*******************************************************************************
* Test that RemoveItem removes a remote view.
*******************************************************************************
	function Test_RemoveItem_RemovesRemoteView

* Create a view in a database.

		create database (This.cTestDataFolder + 'test')
		create view testview connection 'Northwind SQL' as select * from customers
		close databases

* Do the test.

		loItem = newobject('ProjectItemLocalView', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath = This.cTestDataFolder + 'test.dbc'
		loItem.ItemName   = 'testview'
		loItem.RemoveItem(This.oProject)
		llOK = not indbc('testview', 'View')
		close databases
		erase (This.cTestDataFolder + 'test.dbc')
		erase (This.cTestDataFolder + 'test.dct')
		erase (This.cTestDataFolder + 'test.dcx')
		This.AssertTrue(llOK, 'Did not remove view')
	endfunc

*******************************************************************************
* Test that RemoveItem removes a connection.
*******************************************************************************
	function Test_RemoveItem_RemovesConnection

* Create a view in a database.

		create database (This.cTestDataFolder + 'test')
		create connection testconn datasource 'Northwind SQL'
		close databases

* Do the test.

		loItem = newobject('ProjectItemConnection', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath = This.cTestDataFolder + 'test.dbc'
		loItem.ItemName   = 'testconn'
		loItem.RemoveItem(This.oProject)
		llOK = not indbc('testconn', 'Connection')
		close databases
		erase (This.cTestDataFolder + 'test.dbc')
		erase (This.cTestDataFolder + 'test.dct')
		erase (This.cTestDataFolder + 'test.dcx')
		This.AssertTrue(llOK, 'Did not remove connection')
	endfunc

*******************************************************************************
* Test that EditItem fails if the file can't be edited
*******************************************************************************
	function Test_EditItem_FailsForFile
		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.CanEdit = .F.
		llReturn = loItem.EditItem(This.oProject)
		This.AssertFalse(llReturn, 'Did not return false when cannot edit')
	endfunc

*******************************************************************************
* Test that EditItem calls Modify for a file
*******************************************************************************
	function Test_EditItem_CallsModifyForFile
		loFile = This.oProject.Files.Add(This.cFile)
		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = This.cFile
		loItem.EditItem(This.oProject)
		loItem = This.oProject.Files.Item(1)
		This.AssertTrue(loItem.lModifyCalled, 'Did not call Modify')
	endfunc

*******************************************************************************
* Test that EditItem calls Modify for a class
*******************************************************************************
	function Test_EditItem_CallsModifyForClass
		loFile = This.oProject.Files.Add(This.cFile)
		loItem = newobject('ProjectItemClass', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path     = This.cFile
		loItem.ItemName = 'test'
		loItem.EditItem(This.oProject)
		loFile = This.oProject.Files.Item(1)
		This.AssertEquals('test', loFile.cClass, 'Did not pass class to Modify')
	endfunc

*******************************************************************************
* Test that EditItem calls ExecuteFile for an image
*******************************************************************************
	function Test_EditItem_CallsExecuteFileForImage
		loItem = newobject('ProjectItemOther', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = This.cTestDataFolder + 'test.bmp'
		bindevent(loItem, 'ExecuteFile', This, 'ExecuteFileCalled', 4)
		loItem.EditItem(This.oProject)
		This.AssertEquals('Edit', This.cExecuteFileOperation, ;
			'Did not pass edit to Modify')
	endfunc

*******************************************************************************
* Test that EditItem fires a projecthook's QueryModifyFile for an image
*******************************************************************************
	function Test_EditItem_CallsQueryModifyFileForImage
		This.oProject.ProjectHook = createobject('MockProjectHook')
		lcFile = This.cTestDataFolder + 'test.bmp'
		This.oProject.Files.Add(lcFile)
		loItem = newobject('ProjectItemOther', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = lcFile
		loItem.EditItem(This.oProject)
		This.AssertEquals(lcFile, This.oProject.ProjectHook.cFile, ;
			'Did not call QueryModifyFile')
	endfunc

*******************************************************************************
* Test that EditItem calls the Class Browser for a classlib
*******************************************************************************
	function Test_EditItem_CallsClassBrowserForClasslib
		loItem = newobject('ProjectItemClasslib', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = This.cTestDataFolder + 'test.vcx'
		lcBrowser = _browser
		_browser  = This.cTestProgram
		loItem.EditItem(This.oProject)
		_browser = lcBrowser
		This.AssertTrue(plClassBrowserCalled, ;
			'Did not call Class Browser')
	endfunc

*******************************************************************************
* Test that EditItem fires a projecthook's QueryModifyFile for a classlib
*******************************************************************************
	function Test_EditItem_CallsQueryModifyFileForClasslib
		This.oProject.ProjectHook = createobject('MockProjectHook')
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oProject.Files.Add(lcFile)
		loItem = newobject('ProjectItemClasslib', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = lcFile
		lcBrowser   = _browser
		_browser    = This.cTestProgram
		loItem.EditItem(This.oProject)
		_browser = lcBrowser
		This.AssertEquals(lcFile, This.oProject.ProjectHook.cFile, ;
			'Did not call QueryModifyFile')
	endfunc

*** TODO: tests for EditItem for Application, Connection, Field, Index,
*			LocalView, RemoveView, StoredProc, TableInDBC. Problem is that they
*			open a designer

*******************************************************************************
* Test that RunItem fails if the file can't be run
*******************************************************************************
	function Test_RunItem_FailsForFile
		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.CanRun = .F.
		llReturn = loItem.RunItem(This.oProject)
		This.AssertFalse(llReturn, 'Did not return false when cannot run')
	endfunc

*******************************************************************************
* Test that RunItem calls Run for a file
*******************************************************************************
	function Test_RunItem_CallsRunForFile
		This.oProject.Files.Add(This.cFile)
		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.CanRun = .T.
		loItem.Path   = This.cFile
		loItem.RunItem(This.oProject)
		loItem = This.oProject.Files.Item(1)
		This.AssertTrue(loItem.lRunCalled, 'Did not call Run')
	endfunc

*** TODO: tests for RunItem for Application, Form, Menu, Program, Query, and TableInDBC.
*			Problem is that they actually run something

enddefine

*******************************************************************************
* Mock classes
*******************************************************************************
define class MockProject as Custom
	Files       = .NULL.
	ProjectHook = .NULL.

	function Init
		This.Files = createobject('MockFileCollection')
	endfunc
enddefine

define class MockFileCollection as Collection
	function Add(tcFile)
		loFile = createobject('MockFile')
		loFile.cFile       = tcFile
		loFile.oCollection = This
		dodefault(loFile, tcFile)
		nodefault
		return loFile
	endfunc
enddefine

define class MockFile as Custom
	cFile         = ''
	oCollection   = .NULL.
	lModifyCalled = .F.
	lRunCalled    = .F.
	lDeleteFile   = .F.
	cClass        = ''

	function Release
		This.oCollection = .NULL.
	endfunc

	function Remove(tlDelete)
		This.oCollection.Remove(This.cFile)
		This.oCollection = .NULL.
		This.lDeleteFile = tlDelete
	endfunc

	function Modify(tcClass)
		This.lModifyCalled = .T.
		This.cClass        = tcClass
	endfunc

	function Run
		This.lRunCalled = .T.
	endfunc
enddefine

define class MockProjectHook as Custom
	cFile = ''

	function QueryModifyFile(toFile)
		This.cFile = toFile.cFile
	endfunc
enddefine
