/* 
History:
Version     Date            Modified By         CR          Description     
--------------------------------------------------------------------------------------
1.0         2-Feb-2016      Shahiruni Wahida    12627       Create batch to update Sales Channel field in Account
*/

global class BatchAccnt_SalesChannelUpdate implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String soql = 'SELECT Sales_Channel_ID__c FROM Account WHERE Sales_Channel_ID_Mismatch__c = true';
        return Database.getQueryLocator(soql);
    }

    
    global void execute(Database.BatchableContext BC, List<Account> accList){
        map<id,string> accSCMap = new Map<id,String>();
        
        for(Account account: accList){
            accSCMap.put(account.id, account.Sales_Channel_ID__c);
        }
        
        //this is a copy of updateSalesChannel.associateAccount_SalesChannelGroup(mapAccIdSalesChannelId);
        GlobalVariables.BYPASS_FUTURE_CALLS = true;
        try{
            // calls the implimentation smethod
            
            associateAccount_SalesChannelGroupImpl(accSCMap);
        }
        catch(Exception e) {
            system.debug('##MN: Catching APEX exception ' + e.getMessage());
            emailUtils.sendSupportEmail(e.getMessage()+'[ Code:  UpdateSalesChannel.associateAccount_SalesChannelGroup() ]', dellConfig.errorEmail);
        }
        GlobalVariables.BYPASS_FUTURE_CALLS = false;
    }
    
    private static void associateAccount_SalesChannelGroupImpl(Map<id,String> accountToSalesChannelMap){
        
        system.debug('#DMLRows#: ' + Limits.getDMLRows());
        system.debug('#DMLRows Limit#: ' + Limits.getLimitDMLRows());
        //Variable declaration/initialization
        List<Sales_Channel_Group__c> existSalesChannelArray=new Sales_Channel_Group__c[]{};
        List<Account> accountUpdateArray = new Account[]{};
        List<Sales_Channel_Group__c> insertSalesChannelArray = new Sales_Channel_Group__c[]{};
        Map<id, String> accountSalesMapToBeProcessed = new Map<id, String>();
        Map<String, Id> groupIdtoRecordIdMap = new Map<String, Id>();
        Map<String,String> uniqueSalesChannelsMap = new Map<String,String>();
        Database.SaveResult[] results;

        //Query the Sales Channel Group object to get the record Id
        existSalesChannelArray=[Select Id, Group_ID__c From Sales_Channel_Group__c where Group_ID__c in :accountToSalesChannelMap.values() AND Group_ID__c!=null];
        system.debug('##KP: Number of Sales channel group recs SELECTED :'+existSalesChannelArray.size());

        //Create a Map of existing SalesChannel Group id to it's Record id
        for(Sales_Channel_Group__c salesChannelGroup :existSalesChannelArray ){
            groupIdtoRecordIdMap.put(salesChannelGroup.Group_ID__c,salesChannelGroup.Id);
        }

            //Iterate through each account id to assign Sales Channel Grup id
        for(id accountId:accountToSalesChannelMap.keySet()){
            String groupId=accountToSalesChannelMap.get(accountId);

            //Checks if sales channel GroupId is removed
            if(groupId==null){
                Account tempAccount=new Account(id=accountId,Sales_Channel__c=null);
                accountUpdateArray.add(tempAccount);
            }

            //if Sales Channel Group already exist update account's Sales_Channel__c
            else if(groupIdtoRecordIdMap.get(groupId)!=null){
                system.debug('##KP: SCG exists:(AccId,groupId,SCGRecId):('+ accountId +', '+ groupId +', '+  groupIdtoRecordIdMap.get(groupId)+')');
                Account tempAccount=new Account(id=accountId,Sales_Channel__c=groupIdtoRecordIdMap.get(groupId));
                accountUpdateArray.add(tempAccount);
            }

            //Create new Sales Channel Group with given groupId
            else{
                system.debug('##KP: SCG does not exist:(AccId,groupId):('+ accountId +', '+ groupId +'). So creating new SCG');
                accountSalesMapToBeProcessed.put(accountId,groupId);

                if(uniqueSalesChannelsMap.get(groupId)==null){
                    Sales_Channel_Group__c salesgroup=new Sales_Channel_Group__c(name='-',Group_ID__c=groupId);
                    insertSalesChannelArray.add(salesgroup);
                    uniqueSalesChannelsMap.put(groupId,'exists');
                }

            }
        }

        //update the Account information
        if(accountUpdateArray.size()>0){

            results = Database.update(accountUpdateArray,false);
        }


        //Create new Sales Channal Group
        if(insertSalesChannelArray.size()>0){

            results = Database.insert(insertSalesChannelArray,false);

            system.debug('##KP: To esatablish the relations. the method is called again');
            try{
                // calls the implimentation method
                associateAccount_SalesChannelGroupImpl(accountSalesMapToBeProcessed);
            }
            catch(Exception e) {
                system.debug('##MN: Catching APEX exception ' + e.getMessage());
                emailUtils.sendSupportEmail(e.getMessage()+'[ Code:  UpdateSalesChannel.associateAccount_SalesChannelGroupImpl() ]', dellConfig.errorEmail);
            }
        }
    }//end of method associateAccount_SalesChannelGroupImpl
    global void finish(Database.BatchableContext BC){
    }
}