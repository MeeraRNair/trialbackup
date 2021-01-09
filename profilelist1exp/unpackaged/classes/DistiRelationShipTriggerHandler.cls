public class DistiRelationShipTriggerHandler extends TriggerHandler{
    /*
    public override void onBeforeInsert() {

        // Validate Duplicate Disti Accounts
        DistiRelationshipValidator.validateDistiAccount(Trigger.new, null);

       //Story 3271954:Deal Reg: Distribution Strategy: Auto Populate Storage Preferred Distributor from Partner Request
       // Auto populate Storage Preferred Distributor when reseller account is selected 
        DistiRelationshipValidator.AutoPopulateDistiAccount(Trigger.new);
        // Validate Duplicate Reseller Accounts
        //DistiRelationshipValidator.validateResellerAccount(Trigger.new, null);
               
    }

    public override void onBeforeUpdate() {

        // Validate Duplicate Disti Accounts
        DistiRelationshipValidator.validateDistiAccount(Trigger.new, (map<Id, Disti_Relationship__c>)Trigger.oldMap);
        
        // Validate Duplicate Reseller Accounts
        //DistiRelationshipValidator.validateResellerAccount(Trigger.new, (map<Id, Disti_Relationship__c>)Trigger.oldMap);
    }

    //public override void onBeforeDelete() {}

    public override void onAfterInsert() {
  
    }

    //public override void onAfterUpdate() {}

    //public override void onAfterDelete() {}*/ 
}