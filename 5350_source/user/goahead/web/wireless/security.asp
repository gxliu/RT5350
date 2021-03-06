<html><head><!-- Copyright (c), Ralink Technology Corporation All Rights Reserved. -->

<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript" src="/lang/b28n.js"></script>
<link rel="stylesheet" href="/style/normal_ws.css" type="text/css"><title>Ralink Wireless Security Settings</title>

<script language="JavaScript" type="text/javascript">
Butterlate.setTextDomain("wireless");
var MBSSID_MAX 				= 8;
var ACCESSPOLICYLIST_MAX	= 64;

var changed = 0;
var old_MBSSID;

var defaultShownMBSSID = 0;
var SSID = new Array();
var PreAuth = new Array();
var AuthMode = new Array();
var EncrypType = new Array();
var DefaultKeyID = new Array();
var Key1Type = new Array();
var Key1Str = new Array();
var Key2Type = new Array();
var Key2Str = new Array();
var Key3Type = new Array();
var Key3Str = new Array();
var Key4Type = new Array();
var Key4Str = new Array();
var WPAPSK = new Array();
var RekeyMethod = new Array();
var RekeyInterval = new Array();
var PMKCachePeriod = new Array();
var IEEE8021X = new Array();
var RADIUS_Server = new Array();
var RADIUS_Port = new Array();
var RADIUS_Key = new Array();
var session_timeout_interval = new Array();
var AccessPolicy = new Array();
var AccessControlList = new Array();

function checkMac(str){
	var len = str.length;
	if(len!=17)
		return false;

	for (var i=0; i<str.length; i++) {
		if((i%3) == 2){
			if(str.charAt(i) == ':')
				continue;
		}else{
			if (    (str.charAt(i) >= '0' && str.charAt(i) <= '9') ||
					(str.charAt(i) >= 'a' && str.charAt(i) <= 'f') ||
					(str.charAt(i) >= 'A' && str.charAt(i) <= 'F') )
			continue;
		}
		return false;
	}
	return true;
}

function checkRange(str, num, min, max)
{
    d = atoi(str,num);
    if(d > max || d < min)
        return false;
    return true;
}

function checkIpAddr(field)
{
    if(field.value == "")
        return false;

    if ( checkAllNum(field.value) == 0)
        return false;

    if( (!checkRange(field.value,1,0,255)) ||
        (!checkRange(field.value,2,0,255)) ||
        (!checkRange(field.value,3,0,255)) ||
        (!checkRange(field.value,4,1,254)) ){
        return false;
    }
   return true;
}

function atoi(str, num)
{
    i=1;
    if(num != 1 ){
        while (i != num && str.length != 0){
            if(str.charAt(0) == '.'){
                i++;
            }
            str = str.substring(1);
        }
        if(i != num )
            return -1;
    }

    for(i=0; i<str.length; i++){
        if(str.charAt(i) == '.'){
            str = str.substring(0, i);
            break;
        }
    }
    if(str.length == 0)
        return -1;
    return parseInt(str, 10);
}

function checkHex(str){
	var len = str.length;

	for (var i=0; i<str.length; i++) {
		if ((str.charAt(i) >= '0' && str.charAt(i) <= '9') ||
			(str.charAt(i) >= 'a' && str.charAt(i) <= 'f') ||
			(str.charAt(i) >= 'A' && str.charAt(i) <= 'F') ){
				continue;
		}else
	        return false;
	}
    return true;
}

function checkInjection(str)
{
	var len = str.length;
	for (var i=0; i<str.length; i++) {
		if ( str.charAt(i) == '\r' || str.charAt(i) == '\n'){
				return false;
		}else
	        continue;
	}
    return true;
}

function checkStrictInjection(str)
{
	var len = str.length;
	for (var i=0; i<str.length; i++) {
		if ( str.charAt(i) == ';' || str.charAt(i) == ',' ||
			 str.charAt(i) == '\r' || str.charAt(i) == '\n'){
				return false;
		}else
	        continue;
	}
    return true;
}

function checkAllNum(str)
{
    for (var i=0; i<str.length; i++){
        if((str.charAt(i) >= '0' && str.charAt(i) <= '9') || (str.charAt(i) == '.' ))
            continue;
        return false;
    }
    return true;
}

function style_display_on()
{
	if (window.ActiveXObject) { // IE
		return "block";
	}
	else if (window.XMLHttpRequest) { // Mozilla, Safari,...
		return "table-row";
	}
}

var http_request = false;
function makeRequest(url, content, handler) {
	http_request = false;
	if (window.XMLHttpRequest) { // Mozilla, Safari,...
		http_request = new XMLHttpRequest();
		if (http_request.overrideMimeType) {
			http_request.overrideMimeType('text/xml');
		}
	} else if (window.ActiveXObject) { // IE
		try {
			http_request = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
			try {
			http_request = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (e) {}
		}
	}
	if (!http_request) {
		if(langtype=="zhcn")
    	  alert("失败");
    	  else
		alert('Giving up :( Cannot create an XMLHTTP instance');
		return false;
	}
	http_request.onreadystatechange = handler;
	http_request.open('POST', url, true);
	http_request.send(content);
}

function securityHandler() {
	if (http_request.readyState == 4) {
		if (http_request.status == 200) {
			parseAllData(http_request.responseText);
			UpdateMBSSIDList();
			LoadFields(defaultShownMBSSID);

			// load Access Policy for MBSSID[selected]
			LoadAP();
			ShowAP(defaultShownMBSSID);
		} else {
			if(langtype=="zhcn")
    	  alert("请示出错");
    	  else
			alert('There was a problem with the request.');
		}
	}
}

function deleteAccessPolicyListHandler()
{
	window.location.reload(false);
}


function parseAllData(str)
{
	var all_str = new Array();
	all_str = str.split("\n");

	defaultShownMBSSID = parseInt(all_str[0]);

	for (var i=0; i<all_str.length-2; i++) {
		var fields_str = new Array();
		fields_str = all_str[i+1].split("\r");

		SSID[i] = fields_str[0];
		PreAuth[i] = fields_str[1];
		AuthMode[i] = fields_str[2];
		EncrypType[i] = fields_str[3];
		DefaultKeyID[i] = fields_str[4];
		Key1Type[i] = fields_str[5];
		Key1Str[i] = fields_str[6];
		Key2Type[i] = fields_str[7];
		Key2Str[i] = fields_str[8];
		Key3Type[i] = fields_str[9];
		Key3Str[i] = fields_str[10];
		Key4Type[i] = fields_str[11];
		Key4Str[i] = fields_str[12];
		WPAPSK[i] = fields_str[13];
		RekeyMethod[i] = fields_str[14];
		RekeyInterval[i] = fields_str[15];
		PMKCachePeriod[i] = fields_str[16];
		IEEE8021X[i] = fields_str[17];
		RADIUS_Server[i] = fields_str[18];
		RADIUS_Port[i] = fields_str[19];
		RADIUS_Key[i] = fields_str[20];
		session_timeout_interval[i] = fields_str[21];
		AccessPolicy[i] = fields_str[22];
		AccessControlList[i] = fields_str[23];

		/* !!!! IMPORTANT !!!!*/
		if(IEEE8021X[i] == "1")
			AuthMode[i] = "IEEE8021X";

		if(AuthMode[i] == "OPEN" && EncrypType[i] == "NONE" && IEEE8021X[i] == "0")
			AuthMode[i] = "Disable";
	}
}

function checkData()
{
	var securitymode;
//	var ssid = document.security_form.Ssid.value;
	
	securitymode = document.security_form.security_mode.value;
	if (securitymode == "OPEN" || securitymode == "SHARED" ||securitymode == "WEPAUTO")
	{
		if(! check_Wep(securitymode) )
			return false;
	}else if (securitymode == "WPAPSK" || securitymode == "WPA2PSK" || securitymode == "WPAPSKWPA2PSK" /* || security_mode == 5 */){
		var keyvalue = document.security_form.passphrase.value;

		if (keyvalue.length == 0){
			if(langtype=="zhcn")
    	  alert("请输入WPAPSK密码");
    	  else
			alert('Please input wpapsk key!');
			return false;
		}

		if (keyvalue.length < 8){
			if(langtype=="zhcn")
    	  alert("请输入8位以上的WPAPSK密码");
    	  else
			alert('Please input at least 8 character of wpapsk key!');
			return false;
		}
		
		if(checkInjection(document.security_form.passphrase.value) == false){
			if(langtype=="zhcn")
    	  alert("无效密码");
    	  else
			alert('Invalid characters in Pass Phrase.');
			return false;
		}

		if(document.security_form.cipher[0].checked != true && 
		   document.security_form.cipher[1].checked != true &&
   		   document.security_form.cipher[2].checked != true){
   		   if(langtype=="zhcn")
    	  alert("请选择WPA加密算法");
    	  else
   		   alert('Please choose a WPA Algorithms.');
   		   return false;
		}

		if(checkAllNum(document.security_form.keyRenewalInterval.value) == false){
			if(langtype=="zhcn")
    	  alert("请输入一个有效的密码更新时间间隔");
    	  else
			alert('Please input a valid key renewal interval');
			return false;
		}
		if(document.security_form.keyRenewalInterval.value < 60){
			if(langtype=="zhcn")
    	  alert("警告：密码太短");
    	  else
			alert('Warning: A short key renewal interval.');
			// return false;
		}
		if(check_wpa() == false)
			return false;
	}
	//802.1x
	else if (securitymode == "IEEE8021X") // 802.1x
	{
		if( document.security_form.ieee8021x_wep[0].checked == false &&
			document.security_form.ieee8021x_wep[1].checked == false){
			if(langtype=="zhcn")
    	  alert("请选择802.1X的WEP方式");
    	  else
			alert('Please choose the 802.1x WEP option.');
			return false;
		}
		if(check_radius() == false)
			return false;
	}else if (securitymode == "WPA" || securitymode == "WPA1WPA2") //     WPA or WPA1WP2 mixed mode
	{
		if(check_wpa() == false)
			return false;
		if(check_radius() == false)
			return false;
	}else if (securitymode == "WPA2") //         WPA2
	{
		if(check_wpa() == false)
			return false;
		if( document.security_form.PreAuthentication[0].checked == false &&
			document.security_form.PreAuthentication[1].checked == false){
			if(langtype=="zhcn")
    	  alert("请选择认证方式");
    	  else
			alert('Please choose the Pre-Authentication options.');
			return false;
		}

		if(!document.security_form.PMKCachePeriod.value.length){
			if(langtype=="zhcn")
    	  alert("请输入PMK缓冲时间");
    	  else
			alert(' PMK Cache Period.');
			return false;
		}
		if(check_radius() == false)
			return false;
	}

	// check Access Policy
	/*
	for(i=0; i<MBSSID_MAX; i++){


		if( document.getElementById("newap_text_" + i).value != ""){
			if(!checkMac(document.getElementById("newap_text_" + i).value)){
				alert("The mac address in Access Policy form is invalid.\n");
				return false;
			}
		}
	}
	*/

	return true;
}

function check_wpa()
{
		if(document.security_form.cipher[0].checked != true && 
		   document.security_form.cipher[1].checked != true &&
   		   document.security_form.cipher[2].checked != true){
   		   if(langtype=="zhcn")
    	  alert("请选择WPA加密算法");
    	  else
   		   alert('Please choose a WPA Algorithms.');
   		   return false;
		}

		if(checkAllNum(document.security_form.keyRenewalInterval.value) == false){
			if(langtype=="zhcn")
    	  alert("请输入一个有效的密码更新时间间隔");
    	  else
			alert('Please input a valid key renewal interval');
			return false;
		}
		if(document.security_form.keyRenewalInterval.value < 60){
			if(langtype=="zhcn")
    	  alert("警告：密码太短");
    	  else
			alert('Warning: A short key renewal interval.');
			// return false;
		}
		return true;
}

function check_radius()
{
	if(!document.security_form.RadiusServerIP.value.length){
		if(langtype=="zhcn")
    	  alert("请输入认证服务器IP地址");
    	  else
		alert('Please input the radius server ip address.');
		return false;		
	}
	if(!document.security_form.RadiusServerPort.value.length){
		if(langtype=="zhcn")
    	  alert("请输入认证服务器端口号");
    	  else
		alert('Please input the radius server port number.');
		return false;		
	}
	if(!document.security_form.RadiusServerSecret.value.length){
		if(langtype=="zhcn")
    	  alert("请输入认证服务器共享密码");
    	  else
		alert('Please input the radius server shared secret.');
		return false;		
	}

	if(checkIpAddr(document.security_form.RadiusServerIP) == false){
		if(langtype=="zhcn")
    	  alert("请输入一个有效的认证服务器IP地址");
    	  else
		alert('Please input a valid radius server ip address.');
		return false;		
	}
	if( (checkRange(document.security_form.RadiusServerPort.value, 1, 1, 65535)==false) ||
		(checkAllNum(document.security_form.RadiusServerPort.value)==false)){
		if(langtype=="zhcn")
    	  alert("请输入一个有效的认证服务器端口号");
    	  else
		alert('Please input a valid radius server port number.');
		return false;		
	}
	if(checkStrictInjection(document.security_form.RadiusServerSecret.value)==false){
		if(langtype=="zhcn")
    	  alert("共享密码包含无效字符");
    	  else
		alert('The shared secret contains invalid characters.');
		return false;		
	}

	if(document.security_form.RadiusServerSessionTimeout.value.length){
		if(checkAllNum(document.security_form.RadiusServerSessionTimeout.value)==false){
			if(langtype=="zhcn")
    	  alert("请输入一个有效的任务超时时间值");
    	  else
			alert('Please input a valid session timeout number or u may left it empty.');
			return false;	
		}	
	}

	return true;
}

function securityMode(c_f)
{
	var security_mode;


	changed = c_f;

	hideWep();


	document.getElementById("div_security_shared_mode").style.visibility = "hidden";
	document.getElementById("div_security_shared_mode").style.display = "none";
	document.getElementById("div_wpa").style.visibility = "hidden";
	document.getElementById("div_wpa").style.display = "none";
	document.getElementById("div_wpa_algorithms").style.visibility = "hidden";
	document.getElementById("div_wpa_algorithms").style.display = "none";
	document.getElementById("wpa_passphrase").style.visibility = "hidden";
	document.getElementById("wpa_passphrase").style.display = "none";
	document.getElementById("wpa_key_renewal_interval").style.visibility = "hidden";
	document.getElementById("wpa_key_renewal_interval").style.display = "none";
	document.getElementById("wpa_PMK_Cache_Period").style.visibility = "hidden";
	document.getElementById("wpa_PMK_Cache_Period").style.display = "none";
	document.getElementById("wpa_preAuthentication").style.visibility = "hidden";
	document.getElementById("wpa_preAuthentication").style.display = "none";
	document.security_form.cipher[0].disabled = true;
	document.security_form.cipher[1].disabled = true;
	document.security_form.cipher[2].disabled = true;
	document.security_form.passphrase.disabled = true;
	document.security_form.keyRenewalInterval.disabled = true;
	document.security_form.PMKCachePeriod.disabled = true;
	document.security_form.PreAuthentication.disabled = true;

	// 802.1x
	document.getElementById("div_radius_server").style.visibility = "hidden";
	document.getElementById("div_radius_server").style.display = "none";
	document.getElementById("div_8021x_wep").style.visibility = "hidden";
	document.getElementById("div_8021x_wep").style.display = "none";
	document.security_form.ieee8021x_wep.disable = true;
	document.security_form.RadiusServerIP.disable = true;
	document.security_form.RadiusServerPort.disable = true;
	document.security_form.RadiusServerSecret.disable = true;	
	document.security_form.RadiusServerSessionTimeout.disable = true;
	document.security_form.RadiusServerIdleTimeout.disable = true;	

	security_mode = document.security_form.security_mode.value;

	if (security_mode == "OPEN" || security_mode == "SHARED" ||security_mode == "WEPAUTO"){
		showWep(security_mode);
	}else if (security_mode == "WPAPSK" || security_mode == "WPA2PSK" || security_mode == "WPAPSKWPA2PSK"){
		<!-- WPA -->
		document.getElementById("div_wpa").style.visibility = "visible";
		if (window.ActiveXObject) { // IE
			document.getElementById("div_wpa").style.display = "block";
		}
		else if (window.XMLHttpRequest) { // Mozilla, Safari,...
			document.getElementById("div_wpa").style.display = "table";
		}

		document.getElementById("div_wpa_algorithms").style.visibility = "visible";
		document.getElementById("div_wpa_algorithms").style.display = style_display_on();
		document.security_form.cipher[0].disabled = false;
		document.security_form.cipher[1].disabled = false;

		// deal with TKIP-AES mixed mode
		if(security_mode == "WPAPSK" || security_mode == "WPA2PSK" || security_mode == "WPAPSKWPA2PSK")
			document.security_form.cipher[2].disabled = false;

		document.getElementById("wpa_passphrase").style.visibility = "visible";
		document.getElementById("wpa_passphrase").style.display = style_display_on();
		document.security_form.passphrase.disabled = false;

		document.getElementById("wpa_key_renewal_interval").style.visibility = "visible";
		document.getElementById("wpa_key_renewal_interval").style.display = style_display_on();
		document.security_form.keyRenewalInterval.disabled = false;
	}else if (security_mode == "WPA" || security_mode == "WPA2" || security_mode == "WPA1WPA2") //wpa enterprise
	{
		document.getElementById("div_wpa").style.visibility = "visible";
		if (window.ActiveXObject) { // IE
			document.getElementById("div_wpa").style.display = "block";
		}else if (window.XMLHttpRequest) { // Mozilla, Safari,...
			document.getElementById("div_wpa").style.display = "table";
		}

		document.getElementById("div_wpa_algorithms").style.visibility = "visible";
		document.getElementById("div_wpa_algorithms").style.display = style_display_on();
		document.security_form.cipher[0].disabled = false;
		document.security_form.cipher[1].disabled = false;
		document.getElementById("wpa_key_renewal_interval").style.visibility = "visible";
		document.getElementById("wpa_key_renewal_interval").style.display = style_display_on();
		document.security_form.keyRenewalInterval.disabled = false;
	
		<!-- 802.1x -->
		document.getElementById("div_radius_server").style.visibility = "visible";
		document.getElementById("div_radius_server").style.display = style_display_on();
		document.security_form.RadiusServerIP.disable = false;
		document.security_form.RadiusServerPort.disable = false;
		document.security_form.RadiusServerSecret.disable = false;	
		document.security_form.RadiusServerSessionTimeout.disable = false;
		document.security_form.RadiusServerIdleTimeout.disable = false;	

		if(security_mode == "WPA")
			document.security_form.cipher[2].disabled = false;

		if(security_mode == "WPA2"){
			document.security_form.cipher[2].disabled = false;
			document.getElementById("wpa_preAuthentication").style.visibility = "visible";
			document.getElementById("wpa_preAuthentication").style.display = style_display_on();
			document.security_form.PreAuthentication.disabled = false;
			document.getElementById("wpa_PMK_Cache_Period").style.visibility = "visible";
			document.getElementById("wpa_PMK_Cache_Period").style.display = style_display_on();
			document.security_form.PMKCachePeriod.disabled = false;
		}

		if(security_mode == "WPA1WPA2"){
			document.security_form.cipher[2].disabled = false;
		}

	}else if (security_mode == "IEEE8021X"){ // 802.1X-WEP
		document.getElementById("div_8021x_wep").style.visibility = "visible";
		document.getElementById("div_8021x_wep").style.display = style_display_on();

		document.getElementById("div_radius_server").style.visibility = "visible";
		document.getElementById("div_radius_server").style.display = style_display_on();
		document.security_form.ieee8021x_wep.disable = false;
		document.security_form.RadiusServerIP.disable = false;
		document.security_form.RadiusServerPort.disable = false;
		document.security_form.RadiusServerSecret.disable = false;	
		document.security_form.RadiusServerSessionTimeout.disable = false;
		//document.security_form.RadiusServerIdleTimeout.disable = false;
	}
}


function hideWep()
{
	document.getElementById("div_wep").style.visibility = "hidden";
	document.getElementById("div_wep").style.display = "none";
}
function showWep(mode)
{
	<!-- WEP -->
	document.getElementById("div_wep").style.visibility = "visible";

	if (window.ActiveXObject) { // IE 
		document.getElementById("div_wep").style.display = "block";
	}
	else if (window.XMLHttpRequest) { // Mozilla, Safari...
		document.getElementById("div_wep").style.display = "table";
	}

	if(mode == "SHARED"){
		document.getElementById("div_security_shared_mode").style.visibility = "visible";
		document.getElementById("div_security_shared_mode").style.display = style_display_on();
	}
	//document.security_form.wep_auth_type.disabled = false;
}


function check_Wep(securitymode)
{
	var defaultid = document.security_form.wep_default_key.value;
	var key_input;

	if ( defaultid == 1 )
		var keyvalue = document.security_form.wep_key_1.value;
	else if (defaultid == 2)
		var keyvalue = document.security_form.wep_key_2.value;
	else if (defaultid == 3)
		var keyvalue = document.security_form.wep_key_3.value;
	else if (defaultid == 4)
		var keyvalue = document.security_form.wep_key_4.value;

	if (keyvalue.length == 0 &&  (securitymode == "SHARED" || securitymode == "OPEN" || securitymode == "WEPAUTO")){ // shared wep  || md5
		if(langtype=="zhcn")
    	  alert("请输入WEP密码");
    	  else
		alert('Please input wep key'+defaultid+' !');
		return false;
	}

	var keylength = document.security_form.wep_key_1.value.length;
	if (keylength != 0){
		if (document.security_form.WEP1Select.options.selectedIndex == 0){
			if(keylength != 5 && keylength != 13) {
				if(langtype=="zhcn")
    	  alert("请输入5/13位的WEP密码");
    	  else
				alert('Please input 5 or 13 characters of wep key1 !');
				return false;
			}
			if(checkInjection(document.security_form.wep_key_1.value)== false){
				if(langtype=="zhcn")
    	  alert("密码无效");
    	  else
				alert('Wep key1 contains invalid characters.');
				return false;
			}
		}
		if (document.security_form.WEP1Select.options.selectedIndex == 1){
			if(keylength != 10 && keylength != 26) {
				if(langtype=="zhcn")
    	  alert("请输入10/26位的WEP密码");
    	  else
				alert('Please input 10 or 26 characters of wep key1 !');
				return false;
			}
			if(checkHex(document.security_form.wep_key_1.value) == false){
				if(langtype=="zhcn")
    	  alert("格式出错");
    	  else
				alert('Invalid Wep key1 format!');
				return false;
			}
		}
	}

	keylength = document.security_form.wep_key_2.value.length;
	if (keylength != 0){
		if (document.security_form.WEP2Select.options.selectedIndex == 0){
			if(keylength != 5 && keylength != 13) {
				if(langtype=="zhcn")
    	  alert("请输入5/13位的WEP密码");
    	  else
				alert('Please input 5 or 13 characters of wep key2 !');
				return false;
			}
			if(checkInjection(document.security_form.wep_key_2.value)== false){
				if(langtype=="zhcn")
    	  alert("格式出错");
    	  else
				alert('Wep key2 contains invalid characters.');
				return false;
			}			
		}
		if (document.security_form.WEP2Select.options.selectedIndex == 1){
			if(keylength != 10 && keylength != 26) {
				if(langtype=="zhcn")
    	  alert("请输入10/26位的WEP密码");
    	  else
				alert('Please input 10 or 26 characters of wep key2 !');
				return false;
			}
			if(checkHex(document.security_form.wep_key_2.value) == false){
				if(langtype=="zhcn")
    	  alert("格式出错");
    	  else
				alert('Invalid Wep key2 format!');
				return false;
			}
		}
	}

	keylength = document.security_form.wep_key_3.value.length;
	if (keylength != 0){
		if (document.security_form.WEP3Select.options.selectedIndex == 0){
			if(keylength != 5 && keylength != 13) {
				if(langtype=="zhcn")
    	  alert("请输入5/13位的WEP密码");
    	  else
				alert('Please input 5 or 13 characters of wep key3 !');
				return false;
			}
			if(checkInjection(document.security_form.wep_key_3.value)== false){
				if(langtype=="zhcn")
    	  alert("格式出错");
    	  else
				alert('Wep key3 contains invalid characters.');
				return false;
			}
		}
		if (document.security_form.WEP3Select.options.selectedIndex == 1){
			if(keylength != 10 && keylength != 26) {
				if(langtype=="zhcn")
    	  alert("请输入10/26位的WEP密码");
    	  else
				alert('Please input 10 or 26 characters of wep key3 !');
				return false;
			}
			if(checkHex(document.security_form.wep_key_3.value) == false){
				if(langtype=="zhcn")
    	  alert("格式出错");
    	  else
				alert('Invalid Wep key3 format!');
				return false;
			}			
		}
	}

	keylength = document.security_form.wep_key_4.value.length;
	if (keylength != 0){
		if (document.security_form.WEP4Select.options.selectedIndex == 0){
			if(keylength != 5 && keylength != 13) {
				if(langtype=="zhcn")
    	  alert("请输入5/13位的WEP密码");
    	  else
				alert('Please input 5 or 13 characters of wep key4 !');
				return false;
			}
			if(checkInjection(document.security_form.wep_key_4.value)== false){
				if(langtype=="zhcn")
    	  alert("格式出错");
    	  else
				alert('Wep key4 contains invalid characters.');
				return false;
			}			
		}
		if (document.security_form.WEP4Select.options.selectedIndex == 1){
			if(keylength != 10 && keylength != 26) {
				if(langtype=="zhcn")
    	  alert("请输入10/26位的WEP密码");
    	  else
				alert('Please input 10 or 26 characters of wep key4 !');
				return false;
			}

			if(checkHex(document.security_form.wep_key_4.value) == false){
				if(langtype=="zhcn")
    	  alert("格式出错");
    	  else
				alert('Invalid Wep key4 format!');
				return false;
			}			
		}
	}
	return true;
}
	
function submit_apply()
{

	if (checkData() == true){
		changed = 0;

		document.security_form.submit();
//		opener.location.reload();
	}
}

function LoadFields(MBSSID)
{
	var result;
	// Security Policy
	sp_select = document.getElementById("security_mode");

	sp_select.options.length = 0;

    sp_select.options[sp_select.length] = new Option("Disable",	"Disable",	false, AuthMode[MBSSID] == "Disable");
    sp_select.options[sp_select.length] = new Option("OPEN",	"OPEN",		false, AuthMode[MBSSID] == "OPEN");
    sp_select.options[sp_select.length] = new Option("SHARED",	"SHARED", 	false, AuthMode[MBSSID] == "SHARED");
    sp_select.options[sp_select.length] = new Option("WEPAUTO", "WEPAUTO",	false, AuthMode[MBSSID] == "WEPAUTO");
    sp_select.options[sp_select.length] = new Option("WPA",		"WPA",		false, AuthMode[MBSSID] == "WPA");
    sp_select.options[sp_select.length] = new Option("WPA-PSK", "WPAPSK",	false, AuthMode[MBSSID] == "WPAPSK");
    sp_select.options[sp_select.length] = new Option("WPA2",	"WPA2",		false, AuthMode[MBSSID] == "WPA2");
    sp_select.options[sp_select.length] = new Option("WPA2-PSK","WPA2PSK",	false, AuthMode[MBSSID] == "WPA2PSK");
    sp_select.options[sp_select.length] = new Option("WPAPSKWPA2PSK","WPAPSKWPA2PSK",	false, AuthMode[MBSSID] == "WPAPSKWPA2PSK");
    sp_select.options[sp_select.length] = new Option("WPA1WPA2","WPA1WPA2",	false, AuthMode[MBSSID] == "WPA1WPA2");

	/* 
	 * until now we only support 8021X WEP for MBSSID[0]
	 */
	if(MBSSID == 0)
		sp_select.options[sp_select.length] = new Option("802.1X",	"IEEE8021X",false, AuthMode[MBSSID] == "IEEE8021X");

	// WEP
	document.getElementById("WEP1").value = Key1Str[MBSSID];
	document.getElementById("WEP2").value = Key2Str[MBSSID];
	document.getElementById("WEP3").value = Key3Str[MBSSID];
	document.getElementById("WEP4").value = Key4Str[MBSSID];

	document.getElementById("WEP1Select").selectedIndex = (Key1Type[MBSSID] == "0" ? 1 : 0);
	document.getElementById("WEP2Select").selectedIndex = (Key2Type[MBSSID] == "0" ? 1 : 0);
	document.getElementById("WEP3Select").selectedIndex = (Key3Type[MBSSID] == "0" ? 1 : 0);
	document.getElementById("WEP4Select").selectedIndex = (Key4Type[MBSSID] == "0" ? 1 : 0);

	document.getElementById("wep_default_key").selectedIndex = parseInt(DefaultKeyID[MBSSID]) - 1 ;

	// SHARED && NONE
	if(AuthMode[MBSSID] == "SHARED" && EncrypType[MBSSID] == "NONE")
		document.getElementById("security_shared_mode").selectedIndex = 1;
	else
		document.getElementById("security_shared_mode").selectedIndex = 0;

	// WPA
	if(EncrypType[MBSSID] == "TKIP")
		document.security_form.cipher[0].checked = true;
	else if(EncrypType[MBSSID] == "AES")
		document.security_form.cipher[1].checked = true;
	else if(EncrypType[MBSSID] == "TKIPAES")
		document.security_form.cipher[2].checked = true;

	document.getElementById("passphrase").value = WPAPSK[MBSSID];
	document.getElementById("keyRenewalInterval").value = RekeyInterval[MBSSID];
	document.getElementById("PMKCachePeriod").value = PMKCachePeriod[MBSSID];
	//document.getElementById("PreAuthentication").value = PreAuth[MBSSID];
	if(PreAuth[MBSSID] == "0")
		document.security_form.PreAuthentication[0].checked = true;
	else
		document.security_form.PreAuthentication[1].checked = true;

	//802.1x wep
	if(IEEE8021X[MBSSID] == "1"){
		if(EncrypType[MBSSID] == "WEP")
			document.security_form.ieee8021x_wep[1].checked = true;
		else
			document.security_form.ieee8021x_wep[0].checked = true;
	}
	
	document.getElementById("RadiusServerIP").value = RADIUS_Server[MBSSID];
	document.getElementById("RadiusServerPort").value = RADIUS_Port[MBSSID];
	document.getElementById("RadiusServerSecret").value = RADIUS_Key[MBSSID];			
	document.getElementById("RadiusServerSessionTimeout").value = session_timeout_interval[MBSSID];
	
	securityMode(0);

}


function ShowAP(MBSSID)
{
	/*
	var i;
	for(i=0; i<MBSSID_MAX; i++){
		document.getElementById("apselect_"+i).selectedIndex	= AccessPolicy[i];
		document.getElementById("AccessPolicy_"+i).style.visibility = "hidden";
		document.getElementById("AccessPolicy_"+i).style.display = "none";
	}

	document.getElementById("AccessPolicy_"+MBSSID).style.visibility = "visible";
	if (window.ActiveXObject) {			// IE
		document.getElementById("AccessPolicy_"+MBSSID).style.display = "block";
	}else if (window.XMLHttpRequest) {	// Mozilla, Safari,...
		document.getElementById("AccessPolicy_"+MBSSID).style.display = "table";
	}
	*/
}

function LoadAP()
{
	for(var i=0; i<SSID.length; i++){
		var j=0;
		var aplist = new Array;

		if(AccessControlList[i].length != 0){
			aplist = AccessControlList[i].split(";");
			for(j=0; j<aplist.length; j++){
				document.getElementById("newap_"+i+"_"+j).value = aplist[j];
			}

			// hide the lastest <td>
			if(j%2){
				document.getElementById("newap_td_"+i+"_"+j).style.visibility = "hidden";
				document.getElementById("newap_td_"+i+"_"+j).style.display = "none";
				j++;
			}
		}

		// hide <tr> left
		/*
		for(; j<ACCESSPOLICYLIST_MAX; j+=2){
			document.getElementById("id_"+i+"_"+j).style.visibility = "hidden";
			document.getElementById("id_"+i+"_"+j).style.display = "none";
		}
		*/
	}
}

function selectMBSSIDChanged()
{
	// check if any security settings changed
	if(changed){
		ret = confirm("Are you sure to ignore changed?");
		if(!ret){
			document.security_form.ssidIndex.options.selectedIndex = old_MBSSID;
			return false;
		}
		else
			changed = 0;
	}

	var selected = document.security_form.ssidIndex.options.selectedIndex;

	// backup for user cancel action
	old_MBSSID = selected;

	MBSSIDChange(selected);
}

/*
 * When user select the different SSID, this function would be called.
 */ 
function MBSSIDChange(selected)
{
	// load wep/wpa/802.1x table for MBSSID[selected]
	LoadFields(selected);

	// update Access Policy for MBSSID[selected]
	ShowAP(selected);

	// radio button special case
	WPAAlgorithms = EncrypType[selected];
	IEEE8021XWEP = IEEE8021X[selected];
	PreAuthentication = PreAuth[selected];

	changeSecurityPolicyTableTitle(SSID[selected]);

	// clear all new access policy list field
	/*
	for(i=0; i<MBSSID_MAX; i++)
		document.getElementById("newap_text_"+i).value = "";
	*/	

	return true;
}

function changeSecurityPolicyTableTitle(t)
{
	var title = document.getElementById("sp_title");
	title.innerHTML = "\"" + t + "\"";
}

function delap(mbssid, num)
{
	makeRequest("/goform/APDeleteAccessPolicyList", mbssid+ "," +num, deleteAccessPolicyListHandler);
}

function initTranslation()
{
	var e = document.getElementById("secureSelectSSID");
	e.innerHTML = _("secure select ssid");
	e = document.getElementById("secureSSIDChoice");
	e.innerHTML = _("secure ssid choice");

	e = document.getElementById("securityTitle");
	e.innerHTML = _("secure ssid title");
	e = document.getElementById("securityIntroduction");
	e.innerHTML = _("secure ssid introduction");
	e = document.getElementById("sp_title");
	e.innerHTML = _("secure security policy");
	e = document.getElementById("secureSecureMode");
	e.innerHTML = _("secure security mode");
	e = document.getElementById("secureEncrypType");
	e.innerHTML = _("secure encryp type");
	e = document.getElementById("secureEncrypTypeNone");
	e.innerHTML = _("wireless none");

	e = document.getElementById("secureWEP");
	e.innerHTML = _("secure wep");
	e = document.getElementById("secureWEPDefaultKey");
	e.innerHTML = _("secure wep default key");
	e = document.getElementById("secureWEPDefaultKey1");
	e.innerHTML = _("secure wep default key1");
	e = document.getElementById("secureWEPDefaultKey2");
	e.innerHTML = _("secure wep default key2");
	e = document.getElementById("secureWEPDefaultKey3");
	e.innerHTML = _("secure wep default key3");
	e = document.getElementById("secureWEPDefaultKey4");
	e.innerHTML = _("secure wep default key4");
	e = document.getElementById("secureWEPKey");
	e.innerHTML = _("secure wep key");
	e = document.getElementById("secureWEPKey1");
	e.innerHTML = _("secure wep key1");
	e = document.getElementById("secureWEPKey2");
	e.innerHTML = _("secure wep key2");
	e = document.getElementById("secureWEPKey3");
	e.innerHTML = _("secure wep key3");
	e = document.getElementById("secureWEPKey4");
	e.innerHTML = _("secure wep key4");
	
	e = document.getElementById("secreWPA");
	e.innerHTML = _("secure wpa");
	e = document.getElementById("secureWPAAlgorithm");
	e.innerHTML = _("secure wpa algorithm");
	e = document.getElementById("secureWPAPassPhrase");
	e.innerHTML = _("secure wpa pass phrase");
	e = document.getElementById("secureWPAKeyRenewInterval");
	e.innerHTML = _("secure wpa key renew interval");
	e = document.getElementById("secureWPAPMKCachePeriod");
	e.innerHTML = _("secure wpa pmk cache period");
	e = document.getElementById("secureWPAPreAuth");
	e.innerHTML = _("secure wpa preauth");
	e = document.getElementById("secureWPAPreAuthDisable");
	e.innerHTML = _("wireless disable");
	e = document.getElementById("secureWPAPreAuthEnable");
	e.innerHTML = _("wireless enable");
	
	e = document.getElementById("secure8021XWEP");
	e.innerHTML = _("secure 8021x wep");
	e = document.getElementById("secure1XWEP");
	e.innerHTML = _("secure 1x wep");
	e = document.getElementById("secure1XWEPDisable");
	e.innerHTML = _("wireless disable");
	e = document.getElementById("secure1XWEPEnable");
	e.innerHTML = _("wireless enable");
	
	e = document.getElementById("secureRadius");
	e.innerHTML = _("secure radius");
	e = document.getElementById("secureRadiusIPAddr");
	e.innerHTML = _("secure radius ipaddr");
	e = document.getElementById("secureRadiusPort");
	e.innerHTML = _("secure radius port");
	e = document.getElementById("secureRadiusSharedSecret");
	e.innerHTML = _("secure radius shared secret");
	e = document.getElementById("secureRadiusSessionTimeout");
	e.innerHTML = _("secure radius session timeout");
	e = document.getElementById("secureRadiusIdleTimeout");
	e.innerHTML = _("secure radius idle timeout");

	/*
	e = document.getElementById("secureAccessPolicy");
	e.innerHTML = _("secure access policy");
	e = document.getElementById("secureAccessPolicyCapable");
	e.innerHTML = _("secure access policy capable");
	e = document.getElementById("secureAccessPolicyCapableDisable");
	e.innerHTML = _("wireless disable");
	e = document.getElementById("secureAccessPolicyCapableAllow");
	e.innerHTML = _("wireless allow");
	e = document.getElementById("secureAccessPolicyCapableReject");
	e.innerHTML = _("wireless reject ");
	e = document.getElementById("secureAccessPolicyNew");
	e.innerHTML = _("secure access policy new");
	*/
	
	e = document.getElementById("secureApply");
	e.value = _("wireless apply");
	e = document.getElementById("secureCancel");
	e.value = _("wireless cancel");
}

function initAll()
{
	initTranslation();	
	makeRequest("/goform/wirelessGetSecurity", "n/a", securityHandler);
}

function UpdateMBSSIDList()
{
	document.security_form.ssidIndex.length = 0;

	for(var i=0; i<SSID.length; i++){
		var j = document.security_form.ssidIndex.options.length;
		document.security_form.ssidIndex.options[j] = new Option(SSID[i], i, false, false);
	}
	
	document.security_form.ssidIndex.options.selectedIndex = defaultShownMBSSID;
	old_MBSSID = defaultShownMBSSID;
	changeSecurityPolicyTableTitle(SSID[defaultShownMBSSID]);
}

function setChange(c){
	changed = c;
}

var WPAAlgorithms;
function onWPAAlgorithmsClick(type)
{
	if(type == 0 && WPAAlgorithms == "TKIP") return;
	if(type == 1 && WPAAlgorithms == "AES") return;
	if(type == 2 && WPAAlgorithms == "TKIPAES") return;
	setChange(1);
}

var IEEE8021XWEP;
function onIEEE8021XWEPClick(type)
{
	if(type == 0 && IEEE8021XWEP == false) return;
	if(type == 1 && IEEE8021XWEP == true) return;
	setChange(1);
}

var PreAuthentication;
function onPreAuthenticationClick(type)
{
	if(type == 0 && PreAuthentication == false) return;
	if(type == 1 && PreAuthentication == true) return;
	setChange(1);
}

</script>
</head>
<body onload="initAll()">
<table class="body"><tbody><tr><td>

<h1 id="securityTitle">Wireless Security/Encryption Settings </h1>
<p id="securityIntroduction">Setup the wireless security and encryption to prevent from unauthorized access and monitoring.</p>

<form method="post" name="security_form" action="/goform/APSecurity">

<!-- ---------------------  MBSSID Selection  --------------------- -->
<table border="0" cellpadding="2" cellspacing="1" width="540">
<tbody><tr>
  <td colspan="2" id="secureSelectSSID"  class="title">Select SSID</td>
</tr>
  <tr>
    <td id="secureSSIDChoice" class="head">SSID choice</td>
    <td  class="content">
      <select name="ssidIndex" size="1" onchange="selectMBSSIDChanged()">
			<!-- ....Javascript will update options.... -->
      </select>
    </td>
  </tr>
</tbody></table>

<table border="0" bordercolor="#9babbd" cellpadding="3" cellspacing="1" hspace="2" vspace="2" width="540">
  <tbody><tr>

    <td colspan="2"  class="title"> <span id="sp_title">Security Policy </span></td>
  </tr>
  <tr id="div_security_infra_mode" name="div_security_infra_mode"> 
    <td id="secureSecureMode" class="head">Security Mode</td>
    <td class="content">
      <select name="security_mode" id="security_mode" size="1" onchange="securityMode(1)">
			<!-- ....Javascript will update options.... -->
      </select>

    </td>
  </tr>
  <tr id="div_security_shared_mode" name="div_security_shared_mode" style="visibility: hidden;"> 
    <td id="secureEncrypType" class="head">Encrypt Type</td>
    <td class="content">
      <select name="security_shared_mode" id="security_shared_mode" size="1" onchange="securityMode(1)">
		<option value=WEP>WEP</option>
		<option value=None id="secureEncrypTypeNone">None</option>
      </select>

    </td>
  </tr>

</tbody></table>
<br>

<!-- WEP -->
<table id="div_wep" name="div_wep" border="0" bordercolor="#9babbd" cellpadding="3" cellspacing="1" hspace="2" vspace="2" width="540" style="visibility: hidden;">
  <tbody><tr> 
    <td colspan="4" id="secureWEP"  class="title">Wire Equivalence Protection (WEP)</td>
  </tr>

  <tr> 
    <td colspan="2" id="secureWEPDefaultKey" class="head">Default Key</td>
    <td colspan="2" class="content">
      <select name="wep_default_key" id="wep_default_key" size="1" onchange="setChange(1)">
	<option value="1" id="secureWEPDefaultKey1">Key 1</option>
	<option value="2" id="secureWEPDefaultKey2">Key 2</option>
	<option value="3" id="secureWEPDefaultKey3">Key 3</option>
	<option value="4" id="secureWEPDefaultKey4">Key 4</option>
      </select>
    </td>
  </tr>
  
  <tr> 
    <td rowspan="4" id="secureWEPKey" class="head">WEP Keys</td>
    <td id="secureWEPKey1" class="head">WEP Key 1 :</td>
    <td class="content"><input name="wep_key_1" id="WEP1" maxlength="26" value="" onKeyUp="setChange(1)"></td>
    <td class="content"><select id="WEP1Select" name="WEP1Select" onchange="setChange(1)"> 
		<option value="1">ASCII</option>
		<option value="0">Hex</option>
		</select></td>
  </tr>

  <tr> 
    <td id="secureWEPKey2" class="head">WEP Key 2 : </td>
    <td class="content"><input name="wep_key_2" id="WEP2" maxlength="26" value="" onKeyUp="setChange(1)"></td>
    <td class="content"><select id="WEP2Select" name="WEP2Select" onchange="setChange(1)">
		<option value="1">ASCII</option>
		<option value="0">Hex</option>
		</select></td>
  </tr>
  <tr> 
    <td id="secureWEPKey3" class="head">WEP Key 3 : </td>
    <td class="content"><input name="wep_key_3" id="WEP3" maxlength="26" value="" onKeyUp="setChange(1)"></td>
    <td class="content"><select id="WEP3Select" name="WEP3Select" onchange="setChange(1)">
		<option value="1">ASCII</option>
		<option value="0">Hex</option>
		</select></td>
  </tr>
  <tr> 
    <td id="secureWEPKey4" class="head">WEP Key 4 : </td>
    <td class="content"><input name="wep_key_4" id="WEP4" maxlength="26" value="" onKeyUp="setChange(1)"></td>
    <td class="content"><select id="WEP4Select" name="WEP4Select" onchange="setChange(1)">
		<option value="1">ASCII</option>
		<option value="0">Hex</option>
		</select></td>
  </tr>

</tbody></table>
<!-- <br /> -->

<!-- WPA -->
<table id="div_wpa" name="div_wpa" border="0" bordercolor="#9babbd" cellpadding="3" cellspacing="1" hspace="2" vspace="2" width="540" style="visibility: hidden;">

  <tbody><tr>
    <td colspan="2" id="secreWPA"  class="title">WPA</td>
  </tr>
  <tr id="div_wpa_algorithms" name="div_wpa_algorithms" style="visibility: hidden;"> 
    <td id="secureWPAAlgorithm" class="head">WPA Algorithms</td>
    <td class="content">
      <input name="cipher" id="cipher" value="0" type="radio" onClick="onWPAAlgorithmsClick(0)">TKIP &nbsp;
      <input name="cipher" id="cipher" value="1" type="radio" onClick="onWPAAlgorithmsClick(1)">AES &nbsp;
      <input name="cipher" id="cipher" value="2" type="radio" onClick="onWPAAlgorithmsClick(2)">TKIPAES &nbsp;
    </td>
  </tr>
  <tr id="wpa_passphrase" name="wpa_passphrase" style="visibility: hidden;">
    <td id="secureWPAPassPhrase" class="head">Pass Phrase</td>
    <td class="content">
      <input name="passphrase" id="passphrase" size="28" maxlength="64" value="" onKeyUp="setChange(1)">
    </td>
  </tr>

  <tr id="wpa_key_renewal_interval" name="wpa_key_renewal_interval" style="visibility: hidden;">
    <td id="secureWPAKeyRenewInterval" class="head">Key Renewal Interval</td>
    <td class="content">
      <input name="keyRenewalInterval" id="keyRenewalInterval" size="4" maxlength="4" value="3600" onKeyUp="setChange(1)"> seconds
    </td>
  </tr>

  <tr id="wpa_PMK_Cache_Period" name="wpa_PMK_Cache_Period" style="visibility: hidden;">
    <td id="secureWPAPMKCachePeriod" class="head">PMK Cache Period</td>
    <td class="content">
      <input name="PMKCachePeriod" id="PMKCachePeriod" size="4" maxlength="4" value="" onKeyUp="setChange(1)"> minute
    </td>
  </tr>

  <tr id="wpa_preAuthentication" name="wpa_preAuthentication" style="visibility: hidden;">
    <td id="secureWPAPreAuth" class="head">Pre-Authentication</td>
    <td class="content">
      <input name="PreAuthentication" id="PreAuthentication" value="0" type="radio" onClick="onPreAuthenticationClick(0)"><font id="secureWPAPreAuthDisable">Disable &nbsp;</font>
      <input name="PreAuthentication" id="PreAuthentication" value="1" type="radio" onClick="onPreAuthenticationClick(1)"><font id="secureWPAPreAuthEnable">Enable &nbsp;</font>
    </td>
  </tr>
</tbody></table>


<!-- 802.1x -->
<!-- WEP  -->
<table id="div_8021x_wep" name="div_8021x_wep" border="0" bordercolor="#9babbd" cellpadding="3" cellspacing="1" hspace="2" vspace="2" width="640" style="visibility: hidden;">
  <tbody>
  <tr>
    <td colspan="2" id="secure8021XWEP" class="title">802.1x WEP</td>
  </tr>
  <tr>
		<td id="secure1XWEP" class="head"> WEP </td>
		<td class="content">
	      <input name="ieee8021x_wep" id="ieee8021x_wep" value="0" type="radio" onClick="onIEEE8021XWEPClick(0)"><font id="secure1XWEPDisable">Disable &nbsp;</font>
    	  <input name="ieee8021x_wep" id="ieee8021x_wep" value="1" type="radio" onClick="onIEEE8021XWEPClick(1)"><font id="secure1XWEPEnable">Enable</font>
		</td>
  </tr>
</tbody></table>

<br>
<table id="div_radius_server" name="div_radius_server" border="0" bordercolor="#9babbd" cellpadding="3" cellspacing="1" hspace="2" vspace="2" width="540" style="visibility: hidden;">
<tbody>
   <tr>
    <td  class="title" colspan="2" id="secureRadius">Radius Server</td>
   </tr>
    <tr> 
		<td   id="secureRadiusIPAddr" class="head"> IP Address </td>
		<td class="content"> <input name="RadiusServerIP" id="RadiusServerIP" size="16" maxlength="32" value="" onKeyUp="setChange(1)"> </td>
	</tr>
    <tr> 
		<td  id="secureRadiusPort" class="head"> Port </td>
		<td class="content"> <input name="RadiusServerPort" id="RadiusServerPort" size="5" maxlength="5" value="" onKeyUp="setChange(1)"> </td>
	</tr>
    <tr> 
		<td id="secureRadiusSharedSecret" class="head"> Shared Secret </td>
		<td class="content"> <input name="RadiusServerSecret" id="RadiusServerSecret" size="16" maxlength="64" value="" onKeyUp="setChange(1)"> </td>
	</tr>
    <tr> 
		<td id="secureRadiusSessionTimeout" class="head"> Session Timeout </td>
		<td class="content"> <input name="RadiusServerSessionTimeout" id="RadiusServerSessionTimeout" size="3" maxlength="4" value="0" onKeyUp="setChange(1)"> </td>
	</tr>
    <tr> 
		<td id="secureRadiusIdleTimeout" class="head"> Idle Timeout </td>
		<td class="content"> <input name="RadiusServerIdleTimeout" id="RadiusServerIdleTimeout" size="3" maxlength="4" value="" onKeyUp="setChange(1)" readonly> </td>
	</tr>

</tbody></table>


<!--									-->
<!--	AccessPolicy for mbssid 		-->
<!--									-->

<!--
<script language="JavaScript" type="text/javascript">
var aptable;

for(aptable = 0; aptable < MBSSID_MAX; aptable++){
	document.write(" <table id=AccessPolicy_"+ aptable +" border=0 bordercolor=#9babbd cellpadding=3 cellspacing=1 hspace=2 vspace=2 width=540  class='borderStyle'>");
	document.write(" <tbody> <tr> <tdcolspan=2  class='borderStyle1'>"+_("secure access policy")+"</td></tr>");
	document.write(" <tr> <td>"+_("secure access policy capable")+"</td>");
	document.write(" <td> <select name=apselect_"+ aptable + " id=apselect_"+aptable+" size=1 onchange=\"setChange(1)\">");
	document.write(" 			<option value=0 >"+_("wireless disable")+"</option> <option value=1 >"+_("wireless allow")+"</option><option value=2 >"+_("wireless reject")+"</option></select> </td></tr>");

	for(i=0; i< ACCESSPOLICYLIST_MAX/2; i++){
		input_name = "newap_"+ aptable +"_" + (2*i);
		td_name = "newap_td_"+ aptable +"_" + (2*i);

		document.write(" <tr id=id_"+aptable+"_");
		document.write(i*2);
		document.write("> <td id=");
		document.write(td_name);
		document.write("> <input style=\"width: 30px;\" value=Del onclick=\"delap("+aptable+", ");
		document.write(2*i);
		document.write(")\" type=button > <input id=");
		document.write(input_name);
		document.write(" size=16 maxlength=20 readonly></td>");

		input_name = "newap_" + aptable + "_" + (2*i+1);
		td_name = "newap_td_" + aptable + "_" + (2*i+1);
		document.write("      <td id=");
		document.write(td_name);
		document.write("> <input style=\"width: 30px;\" value=Del onclick=\"delap("+aptable+", ");
		document.write(2*i+1);
		document.write(")\" type=button> <input id=");
		document.write(input_name);
		document.write(" size=16 maxlength=20 readonly></td> </tr>");
	}

	document.write("<tr><td>"+_("secure access policy new")+"</td>");
	document.write("	<td>	<input name=newap_text_"+aptable+" id=newap_text_"+aptable+" size=16 maxlength=20>	</td>	</tr> </tbody></table>");
}
</script>
-->

<!-- <br /> -->
<table border="0" cellpadding="2" cellspacing="1" width="540">
  <tbody><tr align="center">

    <td class="content">
      <input style="width: 120px;" value="Apply" id="secureApply" onclick="submit_apply()" type="button"> &nbsp; &nbsp;
      <input style="width: 120px;" value="Cancel" id="secureCancel" type="reset" onClick="window.location.reload()" >
    </td>
  </tr>
</tbody></table>
</form>

</td></tr></tbody></table>
</body></html>
 
