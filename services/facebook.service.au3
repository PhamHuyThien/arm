#include-once
#include <..\lib\_HttpRequest.au3>
#include <..\utils\time.util.au3>

$lgURL = "https://mbasic.facebook.com" ;
$lgURLWeb = "https://www.facebook.com" ;

$lgUrlProfile = $lgURL & "/profile.php" ;
$lgUrlGraphbatch = $lgURLWeb & "/api/graphqlbatch/" ;
$lgUrlGraphQL = $lgURLWeb & "/api/graphql/" ;

;output array[uid, fb_dtsg, name, cookie], fail setError = 1
Func _fb_login($cookie)
	$html = _HttpRequest(2, $lgUrlProfile, "", $cookie) ;
	$regexUID = StringRegExp($html, 'name="target" value="([0-9]+?)" />', 3) ;
	If @error Then
		Return SetError(1, 0, "Get UID profile failure.") ;
	EndIf
	$regexFbDtsg = StringRegExp($html, 'name="fb_dtsg" value="(.+?)" ', 3) ;
	If @error Then
		Return SetError(1, 0, "Get fb_dtsg profile failure.") ;
	EndIf
	$regexName = StringRegExp($html, '<title>(.+?)</title>', 3) ;
	If @error Then
		Return SetError(1, 0, "Get name profile failure.") ;
	EndIf
	Dim $values = [$regexUID[0], _URIEncode($regexFbDtsg[0]), $regexName[0], $cookie] ;
	Return $values ;
EndFunc   ;==>_fb_login

;output [[messageId, content],...], fail setError = 1
Func _fb_getMessageList($fbLoginData, $uid, $timeBefore = -1, $limit = 5000)
	$uidMe = $fbLoginData[0] ;
	$fbDtsg = $fbLoginData[1] ;
	$cookie = $fbLoginData[3] ;

	$timeBefore = $timeBefore == -1 ? _timeUt_getCurrentTime() : $timeBefore ;

	$queries = _URIEncode('{"o0":{"doc_id":"2841224182646081","query_params":{"id":"' & $uid & '","message_limit":' & $limit & ',"load_messages":true,"load_read_receipts":true,"load_delivery_receipts":true,"before":' & $timeBefore & ',"is_work_teamwork_not_putting_muted_in_unreads":false}}}') ;
	$paramPost = _
			"batch_name=MessengerGraphQLThreadFetcher" & _
			"&__user=" & $uidMe & _
			"&__a=1" & _
			"&__beoa=0" & _
			"&__pc=EXP1%3Acomet_pkg" & _
			"&dpr=1" & _
			"&__ccg=EXCELLENT" & _
			"&__comet_req=0" & _
			"&fb_dtsg=" & $fbDtsg & _
			"&__spin_b=trunk" & _
			"&queries=" & $queries ;

	$strJson = _HttpRequest(2, $lgUrlGraphbatch, $paramPost, $cookie) ;
	$strJson = StringReplace($strJson, '{"successful_results":1,"error_results":0,"skipped_results":0}', "") ;
	$json = _HttpRequest_ParseJSON($strJson) ;
	$nodes = $json.o0.data.message_thread.messages.nodes ;
	If VarGetType($nodes) <> "Object" Then
		Return SetError(1, 0, "Messages is empty.") ;
	EndIf
	$length = $nodes.length() ;
	Dim $results[1][2] ;
	For $i = 0 To $length - 1
		$message = $nodes.index($i) ;
		$messageType = $message.__typename ;
		$uidSender = $message.message_sender.id ;
		$legaryAttachmentId = $message.extensible_attachment.legacy_attachment_id ;
		If $messageType == "UserMessage" And _
				$uidSender == $uidMe And _
				VarGetType($legaryAttachmentId) == "Keyword" _
				Then
			$messageId = $message.message_id ;
			$content = $message.message.text ;
			$content = $content == "" ? "<Nhãn dán>" : $content ;
			Dim $add = $messageId & "|" & $content ;
			_ArrayAdd($results, $add) ;
		EndIf
	Next
	$lastTimestamp = UBound($results) > 1 ? $nodes.index(0).timestamp_precise : -1 ;
	$results[0][0] = $lastTimestamp ;
	$results[0][1] = "Thiên Đẹp Trai <3" ;
	Return $results ;
EndFunc   ;==>_fb_getMessageList

Func _fb_removeMessage($fbLoginData, $messageId)
	$uidMe = $fbLoginData[0] ;
	$fbDtsg = $fbLoginData[1] ;
	$cookie = $fbLoginData[3] ;

	$queries = _URIEncode('{"input":{"message_id":"' & $messageId & '","actor_id":"' & $uidMe & '","client_mutation_id":"' & Random(0, 100000, 1) & '"}}') ;
	$paramPost = _
			"av=" & $uidMe & _
			"&__user=" & $uidMe & _
			"&__a=1" & _
			"&__csr=" & _
			"&__beoa=1" & _
			"&__pc=EXP1%3Acomet_pkg" & _
			"&dpr=1" & _
			"&__ccg=GOOD" & _
			"&__comet_req=1" & _
			"&fb_dtsg=" & $fbDtsg & _
			"&__spin_b=trunk" & _
			"&fb_api_caller_class=RelayModern" & _
			"&fb_api_req_friendly_name=useMessengerGlobalRemoveMessageMutation" & _
			"&variables=" & $queries & _
			"&server_timestamps=true" & _
			"&doc_id=2664779376886490" ;

	$strJson = _HttpRequest(2, $lgUrlGraphQL, $paramPost, $cookie) ;
	$json = _HttpRequest_ParseJSON($strJson) ;
	$clientMutationId = $json.data.messenger_message_global_remove.client_mutation_id ;
	Return VarGetType($clientMutationId) <> "Keyword" ;
EndFunc   ;==>_fb_removeMessage


