/**********************************************************************************************
 * Name         : linkAccountToPartnerRequest
 * Description  : linkAccountToPartnerRequest - Link lead and partner request to account
 * Created      : 22-July-2009
 * Created By   : Raymond Yip
 ***********************************************************************************************
 * Revision History:
 * 22-July-2009     Raymond     Created for CR1466.
 *-------------------------------------------------
 * 10-Feb-2011      JP          Updated for CR5801.
 **********************************************************************************************/
 
 
global class AccountIntegration {
    
    //CR5801 - Response Result class
    global class Result {
        webService String AccountId;
        webService String LeadId;
        webService String PartnerReqId;
        webService boolean isLeadUpdSuccess;
        webService String LeadUpdError;
        webService boolean isPartnerReqUpdSuccess;
        webService String PartnerReqUpdError;
    }
    
    Map<String, Result> leadIdToResultMap;
    Map<String,String> PRIdtoLeadIdMap;
    
    //CR5801 - Changed List<String> to List<Result>
    webservice static List<Result> linkAccountToPRwithResponse(List<AccountLeadLinkInfo> linkInfoList) {

    System.debug('###DEBUG### Records are ' + linkInfoList);
    
    Map<String, String> linkInfoMap = new Map<String, String>();
    String sfdcLeadId;
    Set<String> leadIdSet = new Set<String>();
    
    Map<String, Result> leadIdToResultMap = new Map<String, Result>();
    Map<String, Result> PRIdToResultMap = new Map<String, Result>();
    
    List<Partner_Request__c> PRupdateList = new List<Partner_Request__c>();
    List <Lead> leadUpdateList = new List<Lead>();  
    Database.Saveresult[] saveResults;
    
    try
    {
        for(AccountLeadLinkInfo tempInfo : linkInfoList) {
            system.debug('###DEBUG### In linkInfoList FOR Loop');
            
            sfdcLeadId = tempInfo.leadId.replace('SFDC_','');
            System.debug('###DEBUG### sfdcLeadId'+ sfdcLeadId);
            linkInfoMap.put(sfdcLeadId, tempInfo.accountId);            
            
            //creating new Result on iteration.
            Result resultItem = new Result();
            resultItem.LeadId = tempInfo.LeadId;
            resultItem.AccountId = tempInfo.accountId;
            leadIdToResultMap.put(sfdcLeadId, resultItem);
            leadIdSet.add(sfdcLeadId);
             
        }
        System.debug('###DEBUG### leadIdToResultMap ' + leadIdToResultMap);
        System.debug('###DEBUG### leadIdSet ' + leadIdSet);
            
        //Query-for-loop
        for(Lead tempLead : [SELECT Id, Name, Account__c, Partner_Request__c , Status, Partner_Request__r.status__c
                            FROM Lead
                            WHERE Id IN :leadIdToResultMap.keySet()]) {
            
            system.debug('###DEBUG### In Lead Query-for-loop');
            //removes the processed lead Id from the set
            leadIdSet.remove(tempLead.Id);
            
            System.debug('###DEBUG### LeadStatus ' +tempLead.Status);
            
            if(tempLead.Status == 'Account Suggestion Submitted') {             
                tempLead.Account__c = linkInfoMap.get(tempLead.Id);
                tempLead.Status = 'Account Suggestion Completed';               
                leadUpdateList.add(tempLead);       
                 
            }else{
                system.debug('###DEBUG### Lead Status != Account Suggestion Submitted');
                addError('Lead',tempLead.Id, leadIdToResultMap,'INVALID_STATUS: Lead status(' + tempLead.Status + ')is not valid to update' );
            }
            
            if(tempLead.Partner_Request__c != null){
                system.debug('###DEBUG### Lead Partner_Request__c != null');
                system.debug('###DEBUG### Partner_Request Status ' +tempLead.Partner_Request__r.status__c);
                
                if(tempLead.Partner_Request__r.status__c  == 'Account Suggestion Submitted') {
                    PRupdateList.add(new Partner_Request__c(id = tempLead.Partner_Request__c,
                                                        Account__c = linkInfoMap.get(tempLead.Id),
                                                        Status__c ='Account Suggestion Completed',
                                                        Link_to_Account_Record_Is_Complete_Flag__c = true));
                    
                    Result currentResult = leadIdToResultMap.get(tempLead.Id);
                    currentResult.PartnerReqId = tempLead.Partner_Request__c;
                    PRIdToResultMap.put(tempLead.Partner_Request__c, currentResult);
                    
                }
                else{
                    system.debug('###DEBUG### PR Status != Account Suggestion Submitted');
                    //CR5801 - getting Response Result for Partner Request Record's Status != Account Suggestion Submitted'             
                    addError('PR', tempLead.id, leadIdToResultMap, 'INVALID_STATUS: PR status(' + tempLead.Partner_Request__r.status__c + ')is not valid to update' );
                }           
            }           
            else{//PR lookup is null
                system.debug('###DEBUG### PR lookup is null');              
                addError('PR',tempLead.id, leadIdToResultMap,'INVALID_PR: No relationship to PR from Lead' );
            }  

        }//end of for loop
        System.debug('###DEBUG### leadUpdateList ' +leadUpdateList);
        System.debug('###DEBUG### PRupdateList ' +PRupdateList);
        
        if(leadUpdateList.size() > 0){
            saveResults = Database.update(leadUpdateList,false);
            addDMLresult(leadUpdateList,saveResults, 'Lead', leadIdToResultMap);
        }       
        if(PRupdateList.size() > 0){
            saveResults = Database.update(PRupdateList,false);
            addDMLresult(PRupdateList,saveResults, 'PR', PRIdToResultMap);
        }
        //processing the remaining Lead Ids for which the query didnt return records
        for(String leadId: leadIdSet){      
            addError('Lead',leadId, leadIdToResultMap,'RECORD_NOT_FOUND: Lead record could not be found' );
            addError('PR',leadId, leadIdToResultMap,'RECORD_NOT_FOUND: Record could not be found' );        
        }       
    }catch(Exception e){
        System.debug('## Exception!  ' +  e.getMessage());
    }
    System.debug('###DEBUG### leadIdToResultMap ' +leadIdToResultMap);
    return leadIdToResultMap.values();
    }

    public static void addError(String objectType, String keyId, Map<String,Result> resultMap, String errorDetails){
        Result resultItem = resultMap.get(keyId);
        System.debug('###DEBUG### resultItem ' +resultItem);    
        
        if(resultItem!=null){   
            if (objectType == 'Lead'){
                resultItem.isLeadUpdSuccess = false;
                resultItem.LeadUpdError  = errorDetails;
            }
            else if (objectType == 'PR'){
                resultItem.isPartnerReqUpdSuccess = false;
                resultItem.PartnerReqUpdError = errorDetails;
            }
        }
    }


    public static void addDMLresult(List<sObject> updatedList, Database.SaveResult[] listOfResult, String objectType, Map<String,Result> resultMap){
    
        for(integer i = 0; i< listOfResult.size();i++){
    
            if(listOfResult[i].isSuccess()!=true){
        
                List<String> errorDetailsList = new List<String>();         
                Database.Error [] errors = listOfResult[i].getErrors();

                // Cycle through the errors
                for (Database.Error error :errors){             
                    errorDetailsList.add(''+error.getStatusCode()+': ' +error.getMessage());                
                }   
                addError(objectType,updatedList[i].Id, resultMap,StringUtils.joinStrings(errorDetailsList, ','));           
            }
            else{  //isSuccess = true
                Result resultItem = resultMap.get(updatedList[i].Id);           
                if(resultItem!=null){
                    if (objectType == 'Lead'){
                        resultItem.isLeadUpdSuccess = true;             
                    }
                    else if (objectType == 'PR'){           
                        resultItem.isPartnerReqUpdSuccess = true;
                    }
                }   
            } //end of isSuccess = true
        
        }//end of for loop

    }//end of method

//=================================================================================

    webservice static List<String> linkAccountToPartnerRequest(List<AccountLeadLinkInfo> linkInfoList) {
        System.debug('###DEBUG### Records are ' + linkInfoList);
        Map<String, String> linkInfoMap = new Map<String, String>();
        String sfdcLeadId;
        try
        {
            for(AccountLeadLinkInfo tempInfo : linkInfoList) {
                sfdcLeadId = tempInfo.leadId.replace('SFDC_','');
                System.debug('###sfdcLeadId'+sfdcLeadId);
                linkInfoMap.put(sfdcLeadId, tempInfo.accountId);
            }
            
            List<Lead> leadObjList = [SELECT Id, Name, Account__c, Partner_Request__c , Status
                                        FROM Lead
                                        WHERE Id IN :linkInfoMap.keySet()];

            List<Partner_Request__c> reqObjList = new List<Partner_Request__c>();

            for(Lead tempLead : leadObjList) {

                tempLead.Account__c = linkInfoMap.get(tempLead.Id);
                tempLead.Status = 'Account Suggestion Completed';
                if(tempLead.Partner_Request__c != null) { 
                     reqObjList.add(new Partner_Request__c(id = tempLead.Partner_Request__c,
                                                            Account__c = linkInfoMap.get(tempLead.Id),
                                                            Status__c ='Account Suggestion Completed',
                                                            Link_to_Account_Record_Is_Complete_Flag__c = true));
                }
            }

            update leadObjList;

            if(reqObjList.size() > 0) {
                update reqObjList;
            }
        }
        catch(Exception e) {
            String errorMsg = 'Exception caught in AccountIntegration.linkAccountToPartnerRequest. Records for integration are ' + linkInfoList + '. ';
            //System.debug(errorMsg + e.getMessage());

            dellUtil.sendSupportEmail(errorMsg + e.getMessage()+'[ Code:  AccountIntegration.AccountIntegration() ]',
                                        dellConfig.errorEmail);

            return linkInfoMap.values();
        }

        return linkInfoMap.values();
    }    
    
}