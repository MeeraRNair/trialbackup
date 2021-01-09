/*
 * Author   : Gan
 * Purpose  : Helper class for associating lead2.0 to existing Opportunity
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR 13282    FY17-DCS-0801   22-Jun-2016     Gan
 * 1.1      CR 13282    FY17-DCS-0801   04-Jul-2016     Gan             Set primary only when there is no primary
 * 1.2      CR 13309    FY17-DCS-0801   05-Jul-2016     Gan             Logic for Small Deal Oppty  
 * 1.3      CR 13309    FY17-DCS-0801   15-Jul-2016     Gan             methods to handle opportunity action after created as we skip the trigger                           
 * 2.0      CR 15626    FY19-DCS-0502   12-Apr-2018     Krishna         Lead 2.0- To fix INC5404659 Dell Main Exception error when trying to convert lead
 * 3.0      CR 16404    FY19-DCS-1002   27-Aug-2018     Kishore,Yamini  Update Primary Campaign Id field in Opportunity for New/Existing
*/
public class Lead2OpptyAssnUtils {
   
    public static void insertOpportunityContactRole(Map<Id, List<Id>> mapOppIdToConId) {        
        List<OpportunityContactRole> listNewOCR = new List<OpportunityContactRole>();
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
        Map<Id, Set<Id>> mapOppIdToExistingOCR = new Map<Id, Set<Id>> ();
        Set<Id> setContactId = new Set<Id>();
        for (String oppId : mapOppIdToConId.keySet()) {
            for (String conId : mapOppIdToConId.get(oppId)) {
                setContactId.add(conId);
            }
        }
        
        //Get Primary Opportunity Contact Role
        for (OpportunityContactRole ocr: [SELECT id, OpportunityId, isPrimary, ContactId FROM OpportunityContactRole 
                                          WHERE OpportunityId in :mapOppIdToConId.keySet() 
                                          ORDER BY OpportunityId, isPrimary]) {
            if (mapOppIdToExistingOCR.isEmpty())
                mapOppIdToExistingOCR.put(ocr.OpportunityId, new Set<Id> {ocr.ContactId});
            else
                mapOppIdToExistingOCR.get(ocr.OpportunityId).add(ocr.ContactId);
        }
        
        for(Opportunity opp : [SELECT Id,CampaignID,Primary_Campaign_ID__c  FROM Opportunity 
                               WHERE Id in :mapOppIdToConId.keySet()]) { 
                                         
            for (String conId : mapOppIdToConId.get(opp.Id)) {                      
                //Only create Opportunity Contact Role if the contact not yet exists in this Opportunity
                if (mapOppIdToExistingOCR.get(opp.Id) == null || (mapOppIdToExistingOCR.get(opp.Id) != null && !mapOppIdToExistingOCR.get(opp.Id).contains(conId))) {
                    OpportunityContactRole newOCR = new OpportunityContactRole(OpportunityId=opp.Id, contactid=conId, isPrimary=false);  
                    listNewOCR.add(newOCR);
                }
            }
            //3.0 start
            if(opp.CampaignID!=NULL){
                opp.Primary_Campaign_ID__c = opp.CampaignID; //Campaign Issue fix 27/08/2018 
                listOppToUpdate.add(opp);
            }//3.0 End
        }
        
        System.debug('##### Opportunity Contact Role: '+listNewOCR);
        if (listNewOCR!=NULL && listNewOCR.size() > 0) {
            insert listNewOCR;
        }
        //3.0 start
        if (listOppToUpdate!=NULL && listOppToUpdate.size() > 0) {
            update listOppToUpdate;
        }//3.0 End
    }
    
    public static void setPrimaryCampaignInfluence(Map<String, String> mapOpptyToCampaign){
       
        //Rev4.0 - end
        System.debug('#### come in insertCampaignInfluence');
    
        List<Opportunity> listOppToUpdate = new List<Opportunity>();     
       
        for(Opportunity opp : [SELECT Id, Name, campaignid
                             FROM Opportunity
                             WHERE Id IN :mapOpptyToCampaign.keySet()]){
                         
            System.debug('#### mapOpptyToCampaign.get(opp.id): '+mapOpptyToCampaign.get(opp.id));
            //1.1
            if(opp.CampaignId == null) {
                system.debug('ZY => Set as primary as it was not set opp.CampaignId:' + opp.CampaignId);
                opp.CampaignId = mapOpptyToCampaign.get(opp.id);
                opp.Primary_Campaign_ID__c = mapOpptyToCampaign.get(opp.id); //3.0
                listOppToUpdate.add(opp);
            }
        }
    
        update listOppToUpdate;
    }
    
    //2.0 start - Added return type Save Result.
    public static Database.SaveResult[] linkedOpptyWithLead(Map<String, String> mapLeadToOpportunity){
        System.debug('#### come in linkedOpptyWithLead');
        System.debug('##### Lead to update: '+mapLeadToOpportunity);
        
        List<Lead> listLdToUpdate = new List<Lead>();     
        
        for(Lead ld : [SELECT Id, Linked_Opportunity__c
                       FROM Lead
                       WHERE Id IN :mapLeadToOpportunity.keySet()]){
            
            ld.Linked_Opportunity__c = mapLeadToOpportunity.get(ld.id);
            listLdToUpdate.add(ld);
        }
        
        System.debug('##### Lead to update: '+listLdToUpdate);
        Database.SaveResult[] result = Database.Update(listLdToUpdate,false);   
        return result;
    }
    
    //1.3 + 1.2
    public static void setupOpptyAfterConversion(Map<string, List<Id>> mapOpptyTypeOpptyId) { 
        
        List<Opportunity> listOpptyToUpdate = new List<Opportunity>();  
        Set<id> setSmallDealOpptyId = new set<Id>();
        Set<id> setAllOpptyId = new set<Id>();
        
        for(String strOpptyType : mapOpptyTypeOpptyId.keySet()) {
            setAllOpptyId.addAll(mapOpptyTypeOpptyId.get(strOpptyType));
            if(strOpptyType == 'SmallDeal') {
                setSmallDealOpptyId.addAll(mapOpptyTypeOpptyId.get(strOpptyType));
            }
        }
       
        set<Id> setRTIdsToPopulateDescDetails = StaticFactory.getRecordTypeIdsByNames('Opportunity', new set<string>{'Standard Opportunity'});        
        String strSmb_RecordType = IdLookupUtils.getRecordTypeId('Small Deal Marketing','Opportunity',true);
        
        String CuUs = UserInfo.getProfileId();                  
        Oppty_Sales_Bypass_Profile__c skipProf = Oppty_Sales_Bypass_Profile__c.getInstance(CuUs);
        for(Opportunity opp : [SELECT Id, Description_Last_Modified_By__c, Description_Last_Modified_Date__c,
                               Sales_Last_Modified_By__c, Sales_Last_Modified_Date__c, Dell_Defined_LOB__c, CloseDate,
                               Fiscal_Year__c, Fiscal_Quarter__c, Fiscal_Week__c, RecordTypeId, AccountId, IsClosed, Highest_Stage__c, StageName,
                               Account_OpenOppurtunity__c,Account_ClosedOppurtunity__c, Direct_Team_Sync__c,CampaignId,Primary_Campaign_ID__c
                             FROM Opportunity
                             WHERE Id IN :setAllOpptyId]) {
            
             if(opp.StageName != '' && opp.StageName != 'Lost, Cancelled - 0%') {
                    opp.Stage_Changed_On__c = Date.today();
             }
                                 
             if(setRTIdsToPopulateDescDetails.contains(opp.RecordTypeId)) {
                opp.Description_Last_Modified_By__c = UserInfo.getUserId();
                opp.Description_Last_Modified_Date__c = System.now();
             }
                    
            if(skipProf==null){
                opp.Sales_Last_Modified_By__c = UserInfo.getUserId();
                opp.Sales_Last_Modified_Date__c = System.now();  
            }
                    
            opp.Dell_Defined_LOB__c = null;
            
                                 
            if (setSmallDealOpptyId.contains(opp.id)) {
                opp.recordtypeid = strSmb_RecordType;                         
            }
            
            if(opp.IsClosed) {
                opp.Account_OpenOppurtunity__c  = null;
                opp.Account_ClosedOppurtunity__c = opp.AccountID;
            }
            else {
                opp.Account_OpenOppurtunity__c = opp.AccountID;
                opp.Account_ClosedOppurtunity__c = null;
            }
           
           // workflowFieldUpdate
           system.debug('opp.Highest_Stage__c: ' + opp.Highest_Stage__c);
           if (opp.Highest_Stage__c == null || opp.Highest_Stage__c.trim() ==''){
               opp.Highest_Stage__c = opp.StageName;
               system.debug('ZY => Highest Stage setup.');
           }
           
           opp.Primary_Campaign_ID__c = opp.CampaignID; //3.0               
           listOpptyToUpdate.add(opp);
           System.debug('ZY1 => Update the Opportunity => listOpptyToUpdate: ' + listOpptyToUpdate);                      
        }
        
        OpportunityUtils.setFYCloseDate(listOpptyToUpdate);
        SalesTeamUtil.setDefaultSalesTeam(listOpptyToUpdate);
       
       Update listOpptyToUpdate;

    }
}