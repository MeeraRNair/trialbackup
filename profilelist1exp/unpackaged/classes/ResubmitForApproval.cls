global class ResubmitForApproval {    
    webservice static boolean callApproval(Id oppId){  
        boolean bisError ;       
        Opportunity objOpp = [Select Id,Tier_1_Approved_Rejected__c From Opportunity Where Id=:oppId];
        if(objOpp.Tier_1_Approved_Rejected__c != null){
            objOpp.Tier_1_Approved_Rejected__c = objOpp.Tier_1_Approved_Rejected__c + 14;
        }       
        if(System.TODAY() > objOpp.Tier_1_Approved_Rejected__c){        
        bisError = True;
        }
        else{            
            bisError = False;
        }
        return bisError;         
    }
}