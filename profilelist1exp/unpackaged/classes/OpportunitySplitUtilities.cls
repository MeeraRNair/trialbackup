/*

 * Revision   Date            Modified By     Description
 * --------   -----------     ------------    -----------
 * 1.0        1-Dec-2019      Urvish          Created class for Opportunity Split
 
*/

public class OpportunitySplitUtilities {

    static List<OpportunityTeamMember> lstOppTeamMem = new List<OpportunityTeamMember>();
    static List<AccountTeamMember> lstAccTeamMem = new List<AccountTeamMember>();
    static List<Opportunity> lstOpp = new List<Opportunity>();
    static Map<String,Split_OverlayGroup__c> mapGrpToRole = Split_OverlayGroup__c.getAll();
    static Map<String,String> mapRoleToGrpName = New Map<String,String>();
    static Map<String,GroupName__c> mapGrpName = GroupName__c.getAll();
    static Map<String,String> mapApinametoName = new Map<String,String>();
    static Map<String,List<OpportunityLineItem>> mapGrptoOli = new Map<String,List<OpportunityLineItem>>();
    static List<String> lstString = new List<String>();
    static Set<Id> setOppId = new Set<Id>();
    static Set<Id> setAccId = new Set<Id>();
    static Integer listSize = 0;
    
    static Decimal total = 0;
    
    public static void prepareData (List<OpportunityLineItem> lstOppoli, Boolean isDelete)
    {
        
        for(Split_OverlayGroup__c objGrp : mapGrpToRole.values())
        {
                mapRoleToGrpName.put(objGrp.Team_Member_Role__c, objGrp.Group_Name__c);
        }
        
        for(GroupName__c objGrpName : mapGrpName.values())
        {
            lstString.add(objGrpName.API_Name__c);
            mapApinametoName.put(objGrpName.API_Name__c,objGrpName.Group_Name__c);
        }
        Integer listSize = lstString.size();
        
        for(OpportunitylineItem objOppli : lstOppoli)
        {
            setOppId.add(objOppli.OpportunityId);
        }
        
        lstOpp = [SELECT Id,AccountId,Customer_consent_to_engage_partner__c from Opportunity where Id IN :setOppId];
        for(Opportunity objOpp : lstOpp)
        {
            if(!objOpp.Customer_consent_to_engage_partner__c){
                setAccId.add(objOpp.AccountId);
            }
        }
        
        String strQuery;
        //strQuery = 'select Id,TotalPrice,'+lstString[0]+','+lstString[1]+','+lstString[2]+','+lstString[3]+' from OpportunityLineItem where OpportunityId In :setOppId';
        strQuery = 'select Id,TotalPrice,';
        
        for(String str : lstString){
            strQuery += str + ',';
        }
        strQuery = strQuery.removeEnd(',');
        strQuery += ' from OpportunityLineItem where OpportunityId In :setOppId';
        List<OpportunityLineItem> lstOli = database.query(strQuery);
        for(OpportunityLineItem oli: lstOli)
        {
            total = total + oli.TotalPrice;
            for(String apiName : lstString)
            {
                if(oli.get(apiName) == true)
                {
                    if(mapGrptoOli.containsKey(mapApinametoName.get(apiName)))
                    {
                        List<OpportunityLineItem> lstOppli = mapGrptoOli.get(mapApinametoName.get(apiName));
                        lstOppli.add(oli);
                        mapGrptoOli.put(mapApinametoName.get(apiName), lstOppli);
                    }
                    else
                    {
                        mapGrptoOli.put(mapApinametoName.get(apiName), new List<OpportunityLineItem>{oli});
                    }
                }
            }
        }
        
        lstAccTeamMem = [SELECT id,TeamMemberRole,UserId,CreatedDate,User.LastModifiedDate from AccountTeamMember where AccountId IN :setAccId ORDER BY CreatedDate];
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        lstOpp = [Select id,Amount from Opportunity where Id in : setOppId];
        Map<String,List<AccountTeamMember>> mapGrpToMem = new Map<String,List<AccountTeamMember>>();
        for(AccountTeamMember objOtm : lstAccTeamMem)
        {
            if(mapRoleToGrpName.containsKey(objOtm.TeamMemberRole))
            {
                    if(mapGrpToMem.containsKey(mapRoleToGrpName.get(objOtm.TeamMemberRole)))
                    {
                        List<AccountTeamMember> lstOtm = mapGrpToMem.get(mapRoleToGrpName.get(objOtm.TeamMemberRole));
                        lstOtm.add(objOtm);
                        mapGrpToMem.put(mapRoleToGrpName.get(objOtm.TeamMemberRole), lstOtm);
                    }
                    else
                    {
                        mapGrpToMem.put(mapRoleToGrpName.get(objOtm.TeamMemberRole), new List<AccountTeamMember>{objOtm});
                    }
            }
        }
        List<OpportunitySplit> lstOppSplit = new List<OpportunitySplit>();
        lstOppSplit = [Select id,SplitAmount,Amount__c,Forecast_Group__c,Percentage__c,SplitType.DeveloperName,Updated_Automaticaly__c from OpportunitySplit where OpportunityId In :setOppId];
        
        
        OpportunitySplitCalculation.splitCalculation(mapGrptoOli, mapGrpToMem, lstOppSplit, lstOpp, total, isDelete);
        
    }
    
}