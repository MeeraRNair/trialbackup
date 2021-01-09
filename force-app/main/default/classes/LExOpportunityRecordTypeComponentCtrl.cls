/*
* Revision      Release     Name            Date            Description   
* 1.0           R1102       Jessie Tan      06-Sept-2016    Created for CR13461 (as Controller to get all the Record Types available/accessible for current profile of currently-login person for LEx/SF1)   
* 2.0           R1102       Jessie Tan      23 Sept 2016    Modified for CR13533 to add Record Type description for LEx/SF1
* 3.0           R1102       Jessie Tan      23 Sept-2016    Modified for Defect #2450417 (Remove Run Rate Marketing Record Type from available listing)
************************************************************/

public class LExOpportunityRecordTypeComponentCtrl{

    public List<RecordType> listAvailableRecordTypes = new List<RecordType>();
        
    public LExOpportunityRecordTypeComponentCtrl(){    
        
        //v3.0 - start
        //v2.0 - start
        //get all the opp record types 
        List<RecordType> listAllRecordTypes = [SELECT Id, developerName, Name, Description FROM RecordType WHERE sObjectType='Opportunity' AND IsActive = TRUE AND RecordType.developerName <> 'Run_Rate_Marketing' order by Name];
        //v2.0 - end 
        
        //this schema will list down all the opp record types according to the access (according to profile access) 
        Map<Id, Schema.RecordTypeInfo> mapAllRecordTypeFromSchema = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        
        //check whether the record type is available for the profile of currently login person 
        //(note: we cant use schema alone as 'master' record type is in the list of schema)
        for (RecordType currentRt: listAllRecordTypes) {
        
            if (mapAllRecordTypeFromSchema.get(currentRt.Id).isAvailable()){
            
                //always add standard opp as the first element in the sequence
                if (currentRt.developerName.equalsIgnoreCase('StandardOpportunity')){
                    system.debug('lst:'+currentRT+':'+listAvailableRecordTypes.size());
                    if (listAvailableRecordTypes.size() == 0)
                        listAvailableRecordTypes.add(currentRT);
                    else
                        listAvailableRecordTypes.add(0, currentRT);
                    continue;
                }
                
                listAvailableRecordTypes.add(currentRt);
                
            }
            
        }
    
        //3.0 - end 
    }
    
    public List<RecordType> getAvailableRecordTypes(){
        return listAvailableRecordTypes ;
    }     

}