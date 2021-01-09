/*
Description: Helper Class  for beforeInsertOrUpdateAccountTrigger for associating a Sales Channel Group to an account.
Version:2.0
Author: Meera Nair/Krishnaprasad P
* Revision  CR Number   Release No    Date            Modified By     Description
* --------- ----------  -----------   -------         --------------  ---------
  1.0                                 03-Nov-2008     Meera/Krishna   Creation
  2.0                                 15-Mar-2010     Krishna         Added a global boolean variable for avoiding nested future calls
  3.0       CR16118    FY19-DCS-0802  09-Jul-2018     Pallavi         Removed commented parts and debug statements as part of code reduce story 5240537
*/

public class updateSalesChannel {

    /*The Apex  method that will be used to update account records and create new Sales Channel Group records will be designed
    as an "At Future" method to allow the record creates and updates to occur during times when the Salesforce.com system
    has sufficient resources*/

    @future
    public static void associateAccount_SalesChannelGroup(Map<id,String> accountToSalesChannelMap){
        
        /* [Krishna 15-Mar-2010]:  Setting the Global variable to true for avoiding nested future calls */
        GlobalVariables.BYPASS_FUTURE_CALLS = true;

        try{
            // calls the implimentation method
            associateAccount_SalesChannelGroupImpl(accountToSalesChannelMap);
        }
        catch(Exception e) {
            
            emailUtils.sendSupportEmail(e.getMessage()+'[ Code:  UpdateSalesChannel.associateAccount_SalesChannelGroup() ]', dellConfig.errorEmail);
        }

        /*Setting the Global variable back to false */
        GlobalVariables.BYPASS_FUTURE_CALLS = false;
        
    }//end of method associateAccount_SalesChannelGroup


    private static void associateAccount_SalesChannelGroupImpl(Map<id,String> accountToSalesChannelMap){

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
                
                Account tempAccount=new Account(id=accountId,Sales_Channel__c=groupIdtoRecordIdMap.get(groupId));
                accountUpdateArray.add(tempAccount);
            }

            //Create new Sales Channel Group with given groupId
            else{
                
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
            
            try{
                // calls the implimentation method
                associateAccount_SalesChannelGroupImpl(accountSalesMapToBeProcessed);
            }
            catch(Exception e) {
                
                emailUtils.sendSupportEmail(e.getMessage()+'[ Code:  UpdateSalesChannel.associateAccount_SalesChannelGroupImpl() ]', dellConfig.errorEmail);
            }
        }

    }//end of method associateAccount_SalesChannelGroupImpl
}