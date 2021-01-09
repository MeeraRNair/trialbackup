/*
 * Revision CR Number   Release No            Date            Modified By        Description
 * -------- ---------   ----------            -----------     ------------       -----------
 * 1.0       7216521    FY20\PI4\SP21-Nov06   18-Nov-2019     Sarbjeet Heera      Update – OEM BDM Email field from Opportunity Teams with role OEM Business Development Manager
       
*/


public class OEMOpptyTeamMembertoSR {

    
    /* Story-7216521- Sarbjeet Heera : Update – OEM BDM Email field from Opportunity Teams with role OEM Business Development Manager */
    public static void populateOEMBDMEmail(list<Support_Request__c> listSupportRequest,Map<Id, OpportunityTeamMember> mapOpportunityTeamMember)
    {
        set<Id> setOppIds = new set<Id>();
        
        for(Support_Request__c objSupportRequest : listSupportRequest){
            
            String strRecordTypeDeveloperName = Schema.SObjectType.Support_Request__c.getRecordTypeInfosById().get(objSupportRequest.RecordTypeId).getDeveloperName();
            
            if(strRecordTypeDeveloperName=='Request_OEM_Customized_Solution_Support'){
                setOppIds.add(objSupportRequest.Opportunity__c);
            }
            
        }
        
        Map<Id,String> mapOEMBDMEmail = new Map<Id,String>();
        
        for(OpportunityTeamMember objOppTeamMember : mapOpportunityTeamMember.values()){
            
            if(setOppIds.Contains(objOppTeamMember.opportunityId) && objOppTeamMember.TeamMemberRole == 'OEM Business Development Manager'){         
                if(!mapOEMBDMEmail.containsKey(objOppTeamMember.OpportunityId)){
                    mapOEMBDMEmail.put(objOppTeamMember.OpportunityId,objOppTeamMember.User.Email);
                }
            }   
        }       

        if(!mapOEMBDMEmail.isEmpty()){  
         
            for(Support_Request__c objSupportRequest : listSupportRequest){
                
                if(mapOEMBDMEmail.containsKey(objSupportRequest.Opportunity__c)){
                    objSupportRequest.OEM_BDM_Email__c=mapOEMBDMEmail.get(objSupportRequest.Opportunity__c);
                }
            }
            
        }   
    }

}