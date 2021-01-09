public class OpportunitySplitManualCalculation {

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
    
    public static void splitManualCalculation (List<OpportunitySplit> lstOppsplt, Boolean isDelete)
    {
        system.debug('afiq ' + lstOppsplt);
    
        for(OpportunitySplit oSplit : lstOppsplt){
            if(oSplit.SplitType.DeveloperName == System.label.Split_Type_Revenue ){
                oSplit.Percentage__c = 100;
                oSplit.Amount__c = 0;
            }
        }
    
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
        
        for(OpportunitySplit objOppli : lstOppsplt)
        {
            setOppId.add(objOppli.OpportunityId);
        }
        lstOpp = [SELECT Id,AccountId from Opportunity where Id IN :setOppId];
        for(Opportunity objOpp : lstOpp)
        {
            setAccId.add(objOpp.AccountId);
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
        
        OpportunitySplitCalculation.splitCalculationManual(mapGrptoOli, mapGrpToMem, lstOppsplt, lstOpp, total);
        
    }
}