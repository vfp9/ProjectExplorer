#include ProjectExplorerCtrls.H

* Constants for converting twips to pixels.

#define cnLOG_PIXELS_X		  88
	* From WINGDI.H
#define cnLOG_PIXELS_Y		  90
	* From WINGDI.H
#define cnTWIPS_PER_INCH	1440
	* 1440 twips per inch

* Other constants.

#IF VERSION(3) = [86]
	#define ccLOADING			'��������...'
	* text for "dummy" node when child nodes aren't loaded at the start
#ELSE
	#define ccLOADING			'Loading...'
	* text for "dummy" node when child nodes aren't loaded at the start
#ENDIF

#define ccKEY_SEPARATOR		'~'
	* the character used to separate parts of the key
