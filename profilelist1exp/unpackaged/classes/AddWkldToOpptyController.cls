/*
 ***Author: Ranjith Mergu
 ***Name: AddWkldToOpptyController
 ***Purpose: This class handles Adding Account Workloads to an Opportunities
 ***Revision:
-------		---				---				-----------
Version		CR#				Dev				Description
1.0			TFS7602934		Ranjith 		Adding BU Product field to custom Lightning Page, so added in SOQL in Controller
-------		---				---			-----------
*/
public class AddWkldToOpptyController {
    class DisplayWkldRecords {
        @AuraEnabled public boolean bIsSelected;
        @AuraEnabled public String strwkldName;
        @AuraEnabled public String strwkldId;
        
        public DisplayWkldRecords(){
            bIsSelected = false;
            strwkldName = '';
        }
    }
    public class WkldRecords {
        @AuraEnabled public list<Workloads__c> listAccWklds;
        @AuraEnabled public list<Opportunity_Workload__c> listOpptyWklds;
        
        public WkldRecords(){
            listAccWklds = new list<Workloads__c>();
            listOpptyWklds = new list<Opportunity_Workload__c>();
        }
    }
    @AuraEnabled
    public static String getAccRec(String strParentId ) {
        String strAccountId = [Select AccountId FROM Opportunity WHERE id=:StrParentId][0].AccountId;	
        return strAccountId;
    }
    @AuraEnabled
    public static WkldRecords getWorkloads(String strParentId, String strAccId ) {
        List<Workloads__c> listTotalList = new List<Workloads__c>();
        set<Id> setOpptyWkldIdSet = new set<Id>();
        Map<Id, Workloads__c> mapAccWklds = new Map<Id, Workloads__c>();
        Map<Id, Opportunity_Workload__c> mapOpptyWklds = new Map<Id, Opportunity_Workload__c>([SELECT Id, Workload__c, Name, Workload__r.Workload_Name__c, BU_Product__c from Opportunity_Workload__c WHERE Opportunity__c=:StrParentId]);
        if(strAccId==null){
            strAccId = [Select AccountId FROM Opportunity WHERE id=:strParentId][0].AccountId;
        }
        mapAccWklds = new Map<Id, Workloads__c>([SELECT Id,Workload_Name__c,BU_Product__c, Name from Workloads__c WHERE Account__c=:strAccId]);
        //Iterate and remove already added workloads
        for(Id opptyWkld :mapOpptyWklds.keyset()){
            Opportunity_Workload__c opptyWkldRec = mapOpptyWklds.get(opptyWkld);
            if(opptyWkldRec!=null){
                setOpptyWkldIdSet.add(opptyWkldRec.Workload__c);
            }
        }
        for(Id accwkld: mapAccWklds.keySet()){
            if(!setOpptyWkldIdSet.contains(accwkld)){
                listTotalList.add(mapAccWklds.get(accwkld));
            }
        }
        WkldRecords wkldMap = new WkldRecords();
        wkldMap.listAccWklds = listTotalList;
        wkldMap.listOpptyWklds = mapOpptyWklds.values();
        return wkldMap;
    }
    
    @AuraEnabled
    public static void addWorkload(String strParentId, List<String> listOfWkldIds){
        list<Opportunity_Workload__c> listOpptyWkld = new list<Opportunity_Workload__c>();
        //@Get values form workload to build the name
        Map<Id, Workloads__c> mapWkldRecordDetailMap = new Map<Id, Workloads__c>([Select Id, Workload_Name__c,BU_Product__c FROM Workloads__c WHERE id IN: listOfWkldIds]);
        for(string strWkldId : listOfWkldIds){
            Opportunity_Workload__c newOpptyWkld = new Opportunity_Workload__c(Opportunity__c=strParentId, Workload__c=strWkldId);
            listOpptyWkld.add(newOpptyWkld);
        }
        try{
            Database.insert(listOpptyWkld);
        }
        Catch(DMLEXception dmlEx){
            System.debug('###DML Exception###'+dmlEx);
        }
        Catch(Exception Ex){
            System.debug('####Exception while inserting Oppty Workloads####'+Ex);
        }
    }
    
    @AuraEnabled
    public static Map<String, String> createOpptyWorkloadRecord(String strNewWkldRec, String strOpptyId) {
        // Response
        Map<String,String> mapResultMap = new Map<String,String>();
        try {
            System.debug('Id of the new record'+strNewWkldRec);
            Opportunity_Workload__c newOpptyWkldRec = new Opportunity_Workload__c (Opportunity__c=strOpptyId, Workload__c=strNewWkldRec);
            insert newOpptyWkldRec;
            mapResultMap.put('status', 'success');
            mapResultMap.put('message', 'Inserted Successfully');        
        }
        catch(Exception e) {
            mapResultMap.put('status', 'error');
            mapResultMap.put('message',e.getMessage());
        }
        return mapResultMap;        
    }
    
    @AuraEnabled
    public static Account getEndCustomer(String strRecordId){
        for(Account acc : [select id,name from account where Id =: strRecordId]) {
            return acc;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<account> getAccountList(String strSearchKeyWord) { 
        String strSearchKey = strSearchKeyWord + '%';
        List<Account> listReturnList = new List < Account > ();
        List< Account> listOfAccount = [select id, Name from account 
                                          where Name LIKE: strSearchKey];
        
        for (Account acc: listOfAccount) {
            listReturnList.add(acc);
        }
        return listReturnList;
    }
    
    @AuraEnabled
    public static List<Workload_Definition__c> getWorkloadDefinitionList(String strSearchKeyWord) { 
        String strSearchKey = '%'+strSearchKeyWord + '%';
        List<Workload_Definition__c> listReturnList = new List < Workload_Definition__c > ();
        List<Workload_Definition__c> listOfAccount = [select Id, Name from Workload_Definition__c 
                                                         where Name LIKE: strSearchKey];
        
        for (Workload_Definition__c acc: listOfAccount) {
            listReturnList.add(acc);
        }
        return listReturnList;
    }
    
    @AuraEnabled
    public static Workloads__c createWorkloads(Account objAccount, Workload_Definition__c objWorkloadDefinition) {
        Workloads__c newWkld = new Workloads__c();
        newWkld.Account__c = objAccount.Id;
        newWkld.Workload_Definition__c = objWorkloadDefinition.Id;
        try{
            Database.insert(newWkld);
        } catch(Exception ex) {
            system.debug('ErrorOccured:'+ex.getMessage());
        }
        return newWkld;
    }
}