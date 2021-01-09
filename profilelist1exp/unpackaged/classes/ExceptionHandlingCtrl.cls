/*
* Controller logic to handle exceptions while insert data from batch class
* 
* Story     CR Number   Release No      Date            Created By     Description
* --------  ---------   ----------      -----------     -----------    -----------
* 			            FY20-0402       22-Mar-2019      Varsha        To insert exception record while any failures from batch class
*                                                                      
*/
public class ExceptionHandlingCtrl {
    public static void exceptionHandlingMethod(Database.SaveResult[] strsaveResult,string strObjectName,string strProcessName,string strErrorMessage,list<AccountShare> listAccShare){
        map<string,list<string>> mapexceptionMap=new map<string,list<string>>();
        
        system.debug('saveResult : '+strsaveResult);
        for (Database.SaveResult sr : strsaveResult) {
            Integer intI=0;
            for(Database.Error objErr : sr.getErrors()) {
                list<string> listerrMessageList=new list<string>();
                listerrMessageList.add(objErr.getMessage());
                list<String> liststatusCodeList=new list<String>();
                if(strObjectName =='AccountShare' && listAccShare.size()>0){
                    list<string> listAccShareIds=new list<string>();
                    listAccShareIds.add(listAccShare.get(intI).Id);
                    mapexceptionMap.put('Account Share Id '+intI,listAccShareIds);
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
        system.debug('Exception Map :'+mapexceptionMap);
        
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
    
    public static void exceptionHandlingMethodDel(Database.DeleteResult[] strDelResult,string strObjectName,string strProcessName,string strErrorMessage,list<AccountShare> listAccShare){
        map<string,list<string>> mapexceptionMap=new map<string,list<string>>();
        Integer intI=0;
        system.debug('saveResult : '+strDelResult);
        for (Database.DeleteResult sr : strDelResult) {
            for(Database.Error objErr : sr.getErrors()) {
                list<string> listerrMessageList=new list<string>();
                listerrMessageList.add(objErr.getMessage());
                list<String> liststatusCodeList=new list<String>();
                if(strObjectName =='AccountShare' && listAccShare.size()>0){
                    list<string> listAccShareIds=new list<string>();
                    listAccShareIds.add(listAccShare.get(intI).Id);
                    mapexceptionMap.put('Account Share Id '+intI,listAccShareIds);
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
        system.debug('Exception Map :'+mapexceptionMap);
        
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