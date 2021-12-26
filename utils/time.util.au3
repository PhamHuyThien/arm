#include-once
#include <Date.au3>

Func _timeUt_getCurrentTime()
	$time1970 = "1970/01/01 00:00:00" ;
	$timeCurrent = _timeUt_getCurrentStrTime() ;
	Return (_DateDiff("s", $time1970, $timeCurrent) * 1000) + @MSEC ;
EndFunc   ;==>_timeUt_getCurrentTime


Func _timeUt_getCurrentStrTime()
	Return @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC ;
EndFunc   ;==>_timeUt_getCurrentStrTime
