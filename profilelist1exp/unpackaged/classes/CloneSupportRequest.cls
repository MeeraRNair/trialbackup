public with sharing class CloneSupportRequest{    
    
    @AuraEnabled  
    public static List<Support_Request__c> getDetailsFromOpp(ID recordId){
        Map<String, Schema.SObjectField> fieldsmap = Schema.SObjectType.Support_Request__c.fields.getMap();
        List<String> fieldNames = new List<String>();
        for(String fieldName : fieldsmap.keySet()) {
            if(fieldsmap.get(fieldName).getDescribe().isCreateable()) {
                fieldNames.add(fieldName);
            }
        }
        String query =
            ' SELECT ' +
            String.join( fieldNames, ',' ) +
            ' FROM Support_Request__c' +
            ' WHERE ' +
            ' id = :recordId ' +
            ' LIMIT 1 '
            ;
        List<Support_Request__c> records = Database.query( query );
        
        return records;
    }
}