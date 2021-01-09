public class CSMBUtilClass {

    //CR11722 Created for implementing "Centralized by Org" trigger architecture - Best practices
    private static map<String,String> duplicateFields; 
    public static map<string, string> mapOfApproverFields {
        get {
            if (duplicateFields == null) {
                duplicateFields = new Map<String,String>();
            
                duplicateFields.put('Accounting__c','Dupe_Accounting__c');
                duplicateFields.put('Credit__c','Dupe_Credit__c');
                duplicateFields.put('Finance1__c','Dupe_Finance__c');
                duplicateFields.put('Legal1__c','Dupe_Legal__c');
                duplicateFields.put('Sales_GM_VP__c','Dupe_Sales_GM_VP__c');
                duplicateFields.put('Add_Approver_1__c','Dupe_Add_Approver_1__c');
                duplicateFields.put('Add_Approver_2__c','Dupe_Add_Approver_2__c');
            }
            return duplicateFields;
        }       
    }
    //CR11722-end
        
    //CR11722
    //public static boolean isValueChanged(Contract oldValue, Contract newValue, Set<String> fieldList) {
    public static boolean isValueChanged(Contract oldValue, Contract newValue) {    
        if(oldValue == null || newValue == null){ return false;}    
        for (String fieldAPIName: mapOfApproverFields.keySet()) {      
            System.debug('###################### compare value: '+oldValue.get(fieldAPIName)+'->'+ newValue.get(fieldAPIName));
                    
            if (oldValue.get(fieldAPIName) <> newValue.get(fieldAPIName)) {             
                return true;
            }
        }        
        //implies no change 
        return false;
    }
    
    //CR11722
    //public static id getDummyId(Contract contractObj,Set<String> fieldList){
    public static id getDummyId(Contract contractObj){
        id dummyID;
        for(String fieldAPIName:mapOfApproverFields.keySet()){         
            if(contractObj.get(fieldAPIName)!=null){
                dummyID = (ID)contractObj.get(fieldAPIName);
                return dummyID;
            }           
        }
        return dummyID;
    }
    
    //populate dummy approver fields
    /*public static Contract populateDummyApproverFields(Contract contractObj,Map<String,String> mapOfApproverFields){
        id dummyID;
        for(String fieldAPIName:mapOfApproverFields.keySet()){          
            if(contractObj.get(fieldAPIName)!=null){
                dummyID = (ID)contractObj.get(fieldAPIName);
                //return dummyID;
            }           
        }
        for(String fieldAPIName:mapOfApproverFields.keySet()){
            if(contractObj.get(fieldAPIName)==null){
                contractObj.put(mapOfApproverFields.get(fieldAPIName),dummyID);
            }else{
                contractObj.put(mapOfApproverFields.get(fieldAPIName),contractObj.get(fieldAPIName));
            }
        }
        return contractObj;
        
    }*/

}