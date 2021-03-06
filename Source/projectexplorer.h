#include ProjectExplorerTreeView.H

#define ccVFP_OPTIONS					'Software\Microsoft\VisualFoxPro\9.0\Options'
	&& the HKEY_CURRENT_USER location for VFP options
#define ccPROJECT_EXPLORER_KEY			'Software\ProjectExplorer'
	&& the HKEY_CURRENT_USER location for Project Explorer options

#define ccSOLUTION_FILE					'Solution.xml'
	&& the name of the solution file
#define ccMETADATA_FILE					'_MetaData.dbf'
	&& the suffix to add to the project filename for the meta data table

#define ccHEADER_TYPE					'H'
	&& the type for header records in the TreeView cursor

#IF VERSION(3) = [86]
	#define ccVFPX_PAGE						'https://github.com/vfp9/ProjectExplorer'
	&& Project Explorer page on VFPX
#ELSE
	#define ccVFPX_PAGE						'http://github.com/DougHennig/ProjectExplorer'
	&& Project Explorer page on VFPX
#ENDIF

#define ccSTACK_SEPARATOR				'@'
	&& the separator used between information of items added to the stack

* Version control status.

#define ccVC_STATUS_ADDED				'A'
#define ccVC_STATUS_CLEAN				'C'
#define ccVC_STATUS_UNTRACKED			'?'
#define ccVC_STATUS_MODIFIED			'M'
#define ccVC_STATUS_IGNORED				'I'
#define ccVC_STATUS_REMOVED				'R'
#define ccGIT_STATUS_REMOVED			'D'

* Project item types (most are in FOXPRO.H as FILETYPE_* constants).

#define FILETYPE_REMOTE_VIEW			'r'
#define FILETYPE_LOCAL_VIEW				'l'
#define FILETYPE_CONNECTION				'c'
#define FILETYPE_STORED_PROCEDURE		'p'
#define FILETYPE_CLASS					'Class'
#define FILETYPE_FIELD					'Field'
#define FILETYPE_INDEX					'Index'
#define FILETYPE_TABLE_IN_DBC			't'
#define FILETYPE_PROJECT				'H'


#IF version(3) = [86]
	* Titles of VFP designer windows.

	#define ccTITLE_VIEW_DESIGNER			'视图设计器 - '
	#define ccTITLE_CONNECTION_DESIGNER		'连接设计器 - '
	#define ccTITLE_STORED_PROCS			'存储过程 '
	#define ccTITLE_QUERY_DESIGNER			'查询设计器 - '
	#define ccTITLE_REPORT_DESIGNER			'报表设计器 - '
	#define ccTITLE_LABEL_DESIGNER			'标签设计器 - '
	#define ccTITLE_FORM_DESIGNER			'表单设计器 - '
	#define ccTITLE_MENU_DESIGNER			'菜单设计器 - '
	#define ccTITLE_CLASS_DESIGNER			'类设计器 - '
	#define ccTITLE_DATABASE_DESIGNER		'数据库设计器 - '
	#define ccTITLE_CLASS_BROWSER			' - 类浏览器'

	* The descriptive names for the types.

	#define DESC_DATABASE					'数据库'
	#define DESC_FREETABLE					'自由表'
	#define DESC_QUERY						'查询'
	#define DESC_FORM						'表单'
	#define DESC_REPORT						'报表'
	#define DESC_LABEL						'标签'
	#define DESC_CLASSLIB					'可视类库'
	#define DESC_PROGRAM					'程序'
	#define DESC_APILIB						'API 库'
	#define DESC_APPLICATION				'应用程序'
	#define DESC_MENU						'菜单'
	#define DESC_TEXT						'文本文件'
	#define DESC_OTHER						'其他文件'
	#define DESC_REMOTE_VIEW				'远程视图'
	#define DESC_LOCAL_VIEW					'本地视图'
	#define DESC_CONNECTION					'连接'
	#define DESC_STORED_PROCEDURE			'存储过程'
	#define DESC_CLASS						'类'
	#define DESC_FIELD						'字段'
	#define DESC_INDEX						'索引'
	#define DESC_TABLE_IN_DBC				'表'
#ELSE
	* Titles of VFP designer windows.

	#define ccTITLE_VIEW_DESIGNER			'View Designer - '
	#define ccTITLE_CONNECTION_DESIGNER		'Connection Designer - '
	#define ccTITLE_STORED_PROCS			'Stored Procedures for '
	#define ccTITLE_QUERY_DESIGNER			'Query Designer - '
	#define ccTITLE_REPORT_DESIGNER			'Report Designer - '
	#define ccTITLE_LABEL_DESIGNER			'Label Designer - '
	#define ccTITLE_FORM_DESIGNER			'Form Designer - '
	#define ccTITLE_MENU_DESIGNER			'Menu Designer - '
	#define ccTITLE_CLASS_DESIGNER			'Class Designer - '
	#define ccTITLE_DATABASE_DESIGNER		'Database Designer - '
	#define ccTITLE_CLASS_BROWSER			' - Class Browser'

	* The descriptive names for the types.

	#define DESC_DATABASE					'Database'
	#define DESC_FREETABLE					'Free Table'
	#define DESC_QUERY						'Query'
	#define DESC_FORM						'Form'
	#define DESC_REPORT						'Report'
	#define DESC_LABEL						'Label'
	#define DESC_CLASSLIB					'Visual Class Library'
	#define DESC_PROGRAM					'Program'
	#define DESC_APILIB						'API Library'
	#define DESC_APPLICATION				'Application'
	#define DESC_MENU						'Menu'
	#define DESC_TEXT						'Text File'
	#define DESC_OTHER						'Other File'
	#define DESC_REMOTE_VIEW				'Remote View'
	#define DESC_LOCAL_VIEW					'Local View'
	#define DESC_CONNECTION					'Connection'
	#define DESC_STORED_PROCEDURE			'Stored Procedure'
	#define DESC_CLASS						'Class'
	#define DESC_FIELD						'Field'
	#define DESC_INDEX						'Index'
	#define DESC_TABLE_IN_DBC				'Table'
#ENDIF

* Windows events.

#define WM_DESTROY						0x0002
#define GWL_WNDPROC						-4
