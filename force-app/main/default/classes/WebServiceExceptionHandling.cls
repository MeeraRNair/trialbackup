public class WebServiceExceptionHandling {
    
    public static void insertException(string strrequestBody,string strresponseBody, Integer intresponsecode,string strprocessName,string strobjectName){  
        Exception__c exceptionRecord = new Exception__c();
        exceptionRecord.Process_Name__c = strprocessName;
        exceptionRecord.Object_type__c = strobjectName;
        exceptionRecord.Object_ID__c = userinfo.getUserId();
        exceptionRecord.Error_Messages__c = String.valueOf(intresponsecode);
        Database.SaveResult resultStatus = database.insert(exceptionRecord);
        
        if(resultStatus.isSuccess() && strrequestBody!= '' && strresponseBody != '' && strrequestBody!= null && strresponseBody != null){
            list<attachment> listattachlist = new list<attachment>();
            attachment reqattachment = new attachment();
            reqattachment.Body = Blob.valueOf(strrequestBody);
            reqattachment.Name = 'Request.txt';
            reqattachment.ParentId=  exceptionRecord.Id;
            listattachlist.add(reqattachment);
            
            attachment responseattachment = new attachment();
            responseattachment.Body = Blob.valueOf(strresponseBody);
            responseattachment.Name = 'Response.txt';
            responseattachment.ParentId=  exceptionRecord.Id;
            listattachlist.add(responseattachment);
            
            database.insert(listattachlist);
        }
    }
    public static void exceptionHandlingMethod(Database.SaveResult[] strsaveResult,string strObjectName,string strProcessName,string strErrorMessage,list<Partner_Track__c> mapptMap,list<Account> mapaccMap){
        map<string,list<string>> mapexceptionMap=new map<string,list<string>>();
        Integer intI=0;
        Boolean bolFailure=false;
        system.debug('saveResult : '+strsaveResult);
        for (Database.SaveResult sr : strsaveResult) {
            if(! sr.isSuccess()){
                bolFailure=true;
                system.debug('Acc Exceptions in if');
                for(Database.Error objErr : sr.getErrors()) {
                    list<string> listerrMessageList=new list<string>();
                    listerrMessageList.add(objErr.getMessage());
                     list<String> liststatusCodeList=new list<String>();
                    if(strObjectName=='Account' && mapaccMap.size()>0){
                        list<string> listaccListids=new list<string>();
                        listaccListids.add(mapaccMap.get(intI).Id);
                        mapexceptionMap.put('Account Id '+intI,listaccListids);
                    }
                    if(strObjectName=='Partner Track' && mapptMap.size()>0){
                        list<string> listptListids=new list<string>();
                        listptListids.add(mapptMap.get(intI).Id);
                        mapexceptionMap.put('Partner Track Id '+intI,listptListids);
                    }
                 system.debug('Status Code :'+objErr.StatusCode);
                    list<string> listStatusCode = new list<string>();
                    listStatusCode.add(string.valueOf(objErr.StatusCode));
                    mapexceptionMap.put('Errors '+intI,listStatusCode);
                    mapexceptionMap.put('message '+intI,listerrMessageList);
                    mapexceptionMap.put('fields '+intI,objErr.getFields()); 
                    intI++;
                }
            }
        }
        system.debug('Exception Map :'+mapexceptionMap);
        system.debug('Exception Map Flag :'+bolFailure);
        if(bolFailure){
            Exception__c exceptionRecord = new Exception__c();
            exceptionRecord.Process_Name__c = strProcessName;
            exceptionRecord.Object_type__c = strObjectName;
            exceptionRecord.Object_ID__c = userinfo.getUserId();
            exceptionRecord.Error_Messages__c = strErrorMessage;
            Database.SaveResult resultStatus = database.insert(exceptionRecord);
            if(resultStatus.isSuccess() && ! mapexceptionMap.isEmpty()){
                list<attachment> listattachlist = new list<attachment>();
                attachment reqattachment = new attachment();
                reqattachment.Body = Blob.valueOf(JSON.serialize(mapexceptionMap));
                reqattachment.Name = 'FailRecords.txt';
                reqattachment.ParentId=  exceptionRecord.Id;
                database.insert(reqattachment);
            }
        }
    }
}