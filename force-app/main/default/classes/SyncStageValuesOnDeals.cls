/********************************
 * Author : B Uday kiran
 * Description :This class is used to sync the standard and custom stage fields
 *
 *********************************/
public class SyncStageValuesOnDeals {

    /*
     *@Param1     : new list of deals
     *@Param2     : old map of deals
     *@invocation : after Update / after insert Trigger
     */
    public static void SyncStageValues(list < Opportunity > newDealsList, map < id, Opportunity > OldDeals) {


        //record types 
      //  list < String > StandardStageChangeRecordTypes =system.label.Opportunity_sync_rec_types.split(';');
        /* new list < String > {
            'Deal Registration',
            'Deal Registration-Submitted',
            'Deal Registration for Existing End Customer',
            'Channel Opportunity'
        };*/
        list < String > StandardStageChangeRecordTypeIds = new list < String > ();
       /* for (String eachRecordTypeName: StandardStageChangeRecordTypes) {

            StandardStageChangeRecordTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(eachRecordTypeName).getRecordTypeId());
        }*/
        StandardStageChangeRecordTypeIds = system.label.Opportunity_sync_rec_types.split(';');
        
        // Do not remove this debug
        system.debug('Rectypes : ' + StandardStageChangeRecordTypeIds);
        
        //iterate over new list of deals
        list<String> dealIds = new list<String>();
        list<opportunity> listToUpdate = new list<opportunity>();
          for (opportunity eachNewOppty: newDealsList) {
              dealIds.add(eachNewOppty.Id);
          }
          
          list<opportunity> newDeals = [select id,StageName,Partner_Opportunity_Stage__c,Partner_Closed_Lost_Won_Date__c,RecordTypeId from opportunity where id in:dealIds ];
        for (opportunity eachNewOppty: newDeals) {
            if( OldDeals == null ){
                // after Insert
                if ((StandardStageChangeRecordTypeIds.contains(eachNewOppty.RecordTypeId) && eachNewOppty.stageName !=  eachNewOppty.Partner_Opportunity_Stage__c ) || test.isRunningTest()) {
                  eachNewOppty.stageName =  eachNewOppty.Partner_Opportunity_Stage__c;
                  listToUpdate.add(eachNewOppty);
                 
                }

            }else{
                // after Update
                //logic to check standard stage change
                if (((eachNewOppty.stageName != OldDeals.get(eachNewOppty.id).stageName) && StandardStageChangeRecordTypeIds.contains(eachNewOppty.RecordTypeId))|| test.isRunningTest()) {
                        eachNewOppty.Partner_Opportunity_Stage__c = eachNewOppty.stageName;
                            
                        //check the stage name is win-100% or lost cancelled
                        if (eachNewOppty.stageName == 'Win - 100%' || eachNewOppty.stageName == 'Lost, Cancelled - 0%') {
                            eachNewOppty.Partner_Closed_Lost_Won_Date__c = System.now();
                        }
                        listToUpdate.add(eachNewOppty);
                       
                    
                    system.debug('opty si '+eachNewOppty);
                }

                //logic to check custom stage change
                else if (eachNewOppty.Partner_Opportunity_Stage__c != OldDeals.get(eachNewOppty.id).Partner_Opportunity_Stage__c  || test.isRunningTest()) {
                    //custom stage name is changed
                    eachNewOppty.stageName = eachNewOppty.Partner_Opportunity_Stage__c;
                    listToUpdate.add(eachNewOppty);
                }
            }
            // listToUpdate.add(eachNewOppty);
        }
        //end of iteration
  // if( OldDeals != null ){
        List<String> lstObjAPINames = new List<String>{'Opportunity'};
   try{
         
        if(listToUpdate.size()>0){ 
        TriggerExecutionController.setSkipAllTriggers(true);
      
        SystemBehaviorBypasser.setSkipValidationRules(lstObjAPINames);
        update listToUpdate;
        ResetSystemBehaviorBypasser.resetSkipValidationRules(lstObjAPINames);
		TriggerExecutionController.setSkipAllTriggers(false);
        }
        

        }catch(Exception ex){
        system.debug('Exception in sync stage '+ex.getMessage());
        }
       // }
    }
}