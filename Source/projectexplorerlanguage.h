#IF VERSION(3) = [86]
	* apiapprun.prg
	#Define icErrorMessage_LOC			[icCommandLine 必须为一字符型]
	#Define icErrorMessage2_LOC			[无法启动 icCommandLine 指定的进程]
	#Define icErrorMessage3_LOC			[进程已启动, 但用户未等待终止]
	#Define icErrorMessage4_LOC			[检查不在活动进程表中的进程]
	#Define icErrorMessage5_LOC			[NULL 进程句柄被传递到 CheckProcessExitCode()]
	#Define icErrorMessage6_LOC			[CloseHandle() 无法关闭句柄 ]
	#Define icErrorMessage7_LOC			[传递给 ReleaseHandle () 调用的句柄无效]
	#Define icErrorMessage8_LOC			[TerminateProcess() 不能杀掉进程句柄 ]
	#Define icErrorMessage9_LOC			[NULL 进程句柄被传递到 KillProc()]
	#Define icErrorMessage10_LOC		[传递的无效 DWORD 字符串用于转换]
	#Define icErrorMessage11_LOC		[传递给 Init 方法的启动目录无效]
	#Define icErrorMessage12_LOC		[传递给 Init 方法的 WindowMode 无效]

	#Define Message1_LOC				[仍在运行]
	#Define Message2_LOC				[终止于 ]

	* projectexplorerabout.scx
	#Define lblDescription_LOC			[VFP 项目管理器的替代品]
	#Define lblLink_LOC					[访问 Project Explorer 的 VFPX 主页]
#ELSE
	* apiapprun.prg
	#Define icErrorMessage_LOC			[icCommandLine must be set, and a string value]
	#Define icErrorMessage2_LOC			[Process Specified by icCommandLine could not be started]
	#Define icErrorMessage3_LOC			[Process started but user did not wait on termination]
	#Define icErrorMessage4_LOC			[Process to check not in active Process Table]
	#Define icErrorMessage5_LOC			[NULL process handle passed to CheckProcessExitCode()]
	#Define icErrorMessage6_LOC			[CloseHandle() failed to close handle ]
	#Define icErrorMessage7_LOC			[Invalid handle passed to ReleaseHandle() invocation]
	#Define icErrorMessage8_LOC			[TerminateProcess() could not kill process handle ]
	#Define icErrorMessage9_LOC			[NULL handle passed to KillProc()]
	#Define icErrorMessage10_LOC		[Invalid DWORD string passed for conversion]
	#Define icErrorMessage11_LOC		[Invalid directory for startup passed to Init method]
	#Define icErrorMessage12_LOC		[Invalid WindowMode passed to Init Method]

	#Define Message1_LOC				[Still running]
	#Define Message2_LOC				[Terminated with a ]

	* projectexplorerabout.scx
	#Define lblDescription_LOC			[A replacement for the VFP Project Manager]
	#Define lblLink_LOC					[Visit the Project Explorer VFPX page]
#ENDIF

