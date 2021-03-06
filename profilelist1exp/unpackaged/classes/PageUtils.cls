/* ============================================================
 * This code is part of the "apex-lang" open source project avaiable at:
 * 
 *      http://code.google.com/p/apex-lang/
 *
 * This code is licensed under the Apache License, Version 2.0.  You may obtain a 
 * copy of the License at:
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================
 */
global class PageUtils {

	global static PageReference redirect(String url){
        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
        return pageRef;
    }
	
	global static String param(String param){
		return get(param);
	}
	
	global static String param(String param, String value){
		return put(param,value);
	}
	
	global static String get(String param){
		return ApexPages.currentPage().getParameters().get(param);
	}
	
	global static String put(String param, String value){
		ApexPages.currentPage().getParameters().put(param,value);
		return value;
	}
	
	global static void addConfirm(String message){
    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,message));
	}
	
	global static void addInfo(String message){
    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,message));
	}
	
	global static void addWarning(String message){
    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,message));
	}
	
	global static void addError(String message){
    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,message));
	}
	
	global static void addFatal(String message){
    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,message));
	}
	
	global static ApexPages.Message[] getMessagesAtLevel(ApexPages.Severity level,
		Boolean includeParents){
		final ApexPages.Message[] all = ApexPages.getMessages();
		System.debug('getMessagesAtLevel(): all.size() = ' + ApexPages.getMessages().size());
		final List<ApexPages.Message> filtered = new List<ApexPages.Message>();
		if(all != null && all.size() > 0){
			for(ApexPages.Message message : all){
				System.debug('getMessagesAtLevel(): message.getSeverity() = ' + message.getSeverity());
				if(message.getSeverity() == level 
					|| (includeParents && isMessageAtLevelOrHigher(message,level))){
					filtered.add(message);
				}
			}
		}
		return filtered;
	}
	
	global static ApexPages.Message[] getErrorMessages(){
		return PageUtils.getMessagesAtLevel(ApexPages.Severity.ERROR, true);
	}

	global static ApexPages.Message[] getErrorMessagesOnly(){
		return PageUtils.getMessagesAtLevel(ApexPages.Severity.ERROR, false);
	}
	
	global static String messagesToString(){
		return messagesToString(ApexPages.getMessages());
	}
	
	global static String messagesToString(ApexPages.Message[] messages){
		if(messages == null){
			return 'null';
		}
		if( messages.size() <= 0){
			return '{empty}';
		}
		String returnString = '';
		for(Integer i = 0; i < messages.size(); i++){
			if(i != 0){ returnString += '; '; }
			returnString += 'ApexPages.Message[';
			returnString += i;
			returnString += ']: (summary=';
			returnString += messages[i].getSummary(); 
			returnString += ',componentLabel=';
			returnString += messages[i].getComponentLabel(); 
			returnString += ',severity=';
			returnString += messages[i].getSeverity(); 
			returnString += ',detail=';
			returnString += messages[i].getDetail(); 
			returnString += ')';
		}
		return '{' + returnString + '}';
	}
	
	global static Boolean isMessageAtLevelOrHigher(ApexPages.Message message, ApexPages.Severity level){
		if(level == null || message == null){
			return false;
		}
		ApexPages.Severity msgLevel = message.getSeverity();
		while(true){
			if(level == msgLevel){
				return true;	
			}
			if(msgLevel == ApexPages.Severity.CONFIRM){msgLevel = ApexPages.Severity.WARNING;}
			else if(msgLevel == ApexPages.Severity.INFO){msgLevel = ApexPages.Severity.WARNING;}
			else if(msgLevel == ApexPages.Severity.WARNING){msgLevel = ApexPages.Severity.ERROR;}
			else if(msgLevel == ApexPages.Severity.ERROR){msgLevel = ApexPages.Severity.FATAL;}
			else { break; }
		}
		return false;
	}
	
	global static String encodeVariable(String variable){
        
        if(variable!=null){
        	return (EncodingUtil.urlEncode(variable,'UTF-8'));
        }           
        else {
        	return '';
        }                        
    }
    
    
    private static Map<String, Schema.SObjectType> sObjectTypeList = null;
    
    global static String getSObjectPath(String paramSobject){
    	if(sObjectTypeList==null){
    		sObjectTypeList = Schema.getGlobalDescribe();
    	}    	 
    	Schema.Describesobjectresult result = sObjectTypeList.get(paramSobject).getDescribe();
    	return result.getKeyPrefix(); 		
	}
	
	global static String getRecordTypeId(String paramSobject, String rtName, Boolean isShortId){
    	if(sObjectTypeList==null){
    		sObjectTypeList = Schema.getGlobalDescribe();
    	}    	 
    	Schema.Describesobjectresult selectedSObject = sObjectTypeList.get(paramSobject).getDescribe();
    	Map<String,Schema.RecordTypeInfo> rtMapByName = selectedSObject.getRecordTypeInfosByName();    	
		Schema.RecordTypeInfo rtByName =  rtMapByName.get(rtName);    	
    	return isShortId ? IdLookupUtils.getShortGUID(rtByName.getRecordTypeId()) : rtByName.getRecordTypeId() ; 		
	}
	
	global static Map<String,String> getRecordTypeMap(String paramSobject, Boolean isShortId){
    	Map<String,String> retRTMap =  new Map<String,String>();
    	if(sObjectTypeList==null){
    		sObjectTypeList = Schema.getGlobalDescribe();
    	}    	    	 
    	Schema.Describesobjectresult selectedSObject = sObjectTypeList.get(paramSobject).getDescribe();
    	Map<String,Schema.RecordTypeInfo> rtMapByName = selectedSObject.getRecordTypeInfosByName();    	
		 
		for(String key : rtMapByName.keyset()){
			system.debug('key='+key +', id='+rtMapByName.get(key).getRecordTypeId());
			retRTMap.put(key, isShortId ? IdLookupUtils.getShortGUID(rtMapByName.get(key).getRecordTypeId()): rtMapByName.get(key).getRecordTypeId());
		}
		 	
    	return retRTMap; 		
	} 
    
}