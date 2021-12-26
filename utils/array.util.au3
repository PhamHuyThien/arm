

Func _arrUt_reverse2DArray($aArray, $start = 0)
    $rows = Ubound($aArray)
    $columns = Ubound($aArray, 2)
    Local $aTemp = $aArray

    For $Y = $start to $rows-1
        For $X = 0 to $columns-1
            $aTemp[$Y][$X] = $aArray[$rows-1 - $Y + $start][$X]
        Next
    Next
    Return $aTemp
EndFunc