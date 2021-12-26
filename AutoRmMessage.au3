#include-once
#include <.\views\main.views.au3>

HotKeySet("{ESC}", "_Main_exit");

_mv_init();
_mv_setState();
_mv_waitEvent();


Func _Main_exit()
	Exit;
EndFunc