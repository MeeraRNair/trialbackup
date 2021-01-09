public class OpportunitySplitValidator {

    static Map<String,Split_OverlayGroup__c> mapGrpToRole = Split_OverlayGroup__c.getAll();
    
    public static void validateOppSplit(list<OpportunitySplit> lstNewOppSplits) {
        
        Set<String> setOppIds = new Set<String>();
        List<String> lstIds = new List<String>();
        Map<String,List<OpportunitySplit>> mapgrptoSplit = new map<String,List<OpportunitySplit>>();
        Map<String,Double> mapgrptototal = new Map<String,Double>();
        
        for(OpportunitySplit objOppSplit : lstNewOppSplits)
        {
            setOppIds.add(objOppSplit.OpportunityId);
            lstIds.add(objOppSplit.Id);
        }
        List<OpportunitySplit> lstSplit = [SELECT Id,Forecast_Group__c,Percentage__c,SplitTypeId from OpportunitySplit where OpportunityId IN :setOppIds AND Id NOT IN :lstIds];
        
        List<OpportunitySplitType> lstSplitType = [Select Id from OpportunitySplitType where DeveloperName = 'Overlay'];
        lstSplit.addAll(lstNewOppSplits); 
        
        for(OpportunitySplit objOppSplits : lstSplit)
        {
            if(objOppSplits.SplitTypeId == lstSplitType[0].Id)
            {
                if(mapgrptoSplit.containsKey(objOppSplits.Forecast_Group__c))
                    {
                        List<OpportunitySplit> lstOppli = mapgrptoSplit.get(objOppSplits.Forecast_Group__c);
                        lstOppli.add(objOppSplits);
                        mapgrptoSplit.put(objOppSplits.Forecast_Group__c, lstOppli);
                    }
                    else
                    {
                        mapgrptoSplit.put(objOppSplits.Forecast_Group__c, new List<OpportunitySplit>{objOppSplits});
                    }
            }
                    
            
        }
        for(String forecastGroup : mapgrptoSplit.keySet())
        {
            Double percent = 0;
            for(OpportunitySplit objSplits : mapgrptoSplit.get(forecastGroup))
            {
                if(objSplits.SplitTypeId == lstSplitType[0].Id && objSplits.Percentage__c != null)
                {
                    percent = percent + objSplits.Percentage__c;
                    mapgrptototal.put(forecastGroup,percent);
                }
            }
            
        }
        
        for(OpportunitySplit objSplit : lstNewOppSplits)
        {
            if(objSplit.SplitTypeId == lstSplitType[0].Id)
            {
                Double totalper = mapgrptototal.get(objSplit.Forecast_Group__c);
                system.debug('totalper :' + totalper);
                if(totalper != 100)
                {
                    objSplit.addError('A forecast group must total 100%.');
                }
            }
        }
    }
    
    public static void validateOppSplitforInsert(list<OpportunitySplit> lstNewOppSplits) {
        
        Set<String> setOppIds = new Set<String>();
        List<String> lstIds = new List<String>();
        Map<String,List<OpportunitySplit>> mapgrptoSplit = new map<String,List<OpportunitySplit>>();
        Map<String,Double> mapgrptototal = new Map<String,Double>();
        
        for(OpportunitySplit objOppSplit : lstNewOppSplits)
        {
            setOppIds.add(objOppSplit.OpportunityId);
            lstIds.add(objOppSplit.Id);
        }
        List<OpportunitySplit> lstSplit = [SELECT Id,Forecast_Group__c,Percentage__c,SplitTypeId from OpportunitySplit where OpportunityId IN :setOppIds];
        
        List<OpportunitySplitType> lstSplitType = [Select Id from OpportunitySplitType where DeveloperName = 'Overlay'];
        lstSplit.addAll(lstNewOppSplits); 
        
        for(OpportunitySplit objOppSplits : lstSplit)
        {
            if(objOppSplits.SplitTypeId == lstSplitType[0].Id)
            {
                if(mapgrptoSplit.containsKey(objOppSplits.Forecast_Group__c))
                    {
                        List<OpportunitySplit> lstOppli = mapgrptoSplit.get(objOppSplits.Forecast_Group__c);
                        lstOppli.add(objOppSplits);
                        mapgrptoSplit.put(objOppSplits.Forecast_Group__c, lstOppli);
                    }
                    else
                    {
                        mapgrptoSplit.put(objOppSplits.Forecast_Group__c, new List<OpportunitySplit>{objOppSplits});
                    }
            }
                    
            
        }
        for(String forecastGroup : mapgrptoSplit.keySet())
        {
            System.debug('*****forecastgroup*****'+forecastGroup);
            List<OpportunitySplit> objSplitList = mapgrptoSplit.get(forecastGroup);
            System.debug('*****objSplits.size()*****'+objSplitList.size()+'*******'+objSplitList);
            Double percent = 0;
            for(OpportunitySplit objSplits : mapgrptoSplit.get(forecastGroup))
            {
                if(objSplits.SplitTypeId == lstSplitType[0].Id && objSplits.Percentage__c != null)
                {
                    System.debug('****percent Before****'+percent);
                    percent = percent + objSplits.Percentage__c;
                    System.debug('****percent After****'+percent);
                    mapgrptototal.put(forecastGroup,percent);
                }
            }
            
        }
        
        for(OpportunitySplit objSplit : lstNewOppSplits)
        {
            if(objSplit.SplitTypeId == lstSplitType[0].Id)
            {
                Double totalper = mapgrptototal.get(objSplit.Forecast_Group__c);
                
                if(totalper != 100)
                {
                    objSplit.addError('A forecast group must total 100%.');
                }
            }
        }
    }
    
    public static void validateForecastGroup(list<OpportunitySplit> lstNewOppSplits)
    {
        Set<String> setOppId = new Set<String>();
        Set<String> setAccId = new Set<String>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<String> lstOwnerId = new List<String>();
        Map<Id,String> mapUserToRole = new Map<Id,String>();
        Map<String,String> mapRoleToGrpName = New Map<String,String>();
        List<OpportunityTeamMember> lstOppTeamMem = new List<OpportunityTeamMember>();
        for(Split_OverlayGroup__c objGrp : mapGrpToRole.values())
        {
                mapRoleToGrpName.put(objGrp.Team_Member_Role__c, objGrp.Group_Name__c);
        }
        
        for(OpportunitySplit objOppSplit : lstNewOppSplits)
        {
            setOppId.add(objOppSplit.OpportunityId);
            lstOwnerId.add(objOppSplit.SplitOwnerId);
        }
        lstOpp = [SELECT Id,AccountId from Opportunity where Id IN :setOppId];
        
        lstOppTeamMem = [SELECT Id,TeamMemberRole,userId from OpportunityTeamMember where userId IN :lstOwnerId AND OpportunityId IN :setOppId];
        List<OpportunitySplitType> lstSplitType = [Select Id from OpportunitySplitType where DeveloperName = 'Overlay'];
        for(OpportunityTeamMember objOtm : lstOppTeamMem)
        {
            mapUserToRole.put(objOtm.UserId, objOtm.TeamMemberRole);
        }
        
        for(OpportunitySplit objSplit : lstNewOppSplits)
        {
            if(objSplit.SplitTypeId == lstSplitType[0].Id)
            {
            
            if(objSplit.Forecast_Group__c != mapRoleToGrpName.get(mapUserToRole.get(objSplit.SplitOwnerId)))
            {
                 objSplit.addError('Please select valid forecast group for the team member.');
            }
            }
        }
    }
    
    public static void validateSplitPercent(list<OpportunitySplit> lstNewOppSplits,Map<Id, OpportunitySplit> oldMap)
    {
        Set<String> setOppId = new Set<String>();
        Map<String,String> mapOppIdtoStage = new Map<String,String>();
        String splitName = System.label.Split_Type_Revenue;
        List<OpportunitySplitType> lstSplitType = [Select Id from OpportunitySplitType where DeveloperName = :splitName];
        for(OpportunitySplit objSplit : lstNewOppSplits)
        {
            setOppId.add(objSplit.OpportunityId);
            if(oldMap.get(objSplit.Id).SplitPercentage != objSplit.SplitPercentage)
            {      
                   objSplit.addError('The Standard Percent field should not be edited. To enter a split please use the Split Percent');
            }
             /* Commented code - Split issue 12/17 */
            /*if((objSplit.Percentage__c != 100 ||  oldMap.get(objSplit.Id).Forecast_Group__c != objSplit.Forecast_Group__c)
               && objSplit.SplitTypeId == lstSplitType[0].Id)
            {
                  objSplit.addError('Revenue cannot be edited and must total 100%');
            }*/
            /*Commented code - Split issue 12/17 */
            /* Added code - Split issue 12/17 */
            if((( oldMap.get(objSplit.Id).Percentage__c != objSplit.Percentage__c && objSplit.Percentage__c != 100 ) 
                		||  oldMap.get(objSplit.Id).Forecast_Group__c != objSplit.Forecast_Group__c )
               && objSplit.SplitTypeId == lstSplitType[0].Id && objSplit.LastModifiedDate != objSplit.CreatedDate)
            {
                  objSplit.addError('Revenue cannot be edited and must total 100%');
            }
            /* End Added code - Split issue 12/17 */
            
        }
        for(Opportunity objOpp : [SELECT Id,StageName from Opportunity where Id IN :setOppId])
        {
            mapOppIdtoStage.put(objOpp.Id,objOpp.StageName);
        }
         for(OpportunitySplit objSplit : lstNewOppSplits)
        {
            if((mapOppIdtoStage.get(objSplit.OpportunityId) == 'Win - 100%' || mapOppIdtoStage.get(objSplit.OpportunityId) == 'Lost, Cancelled - 0%') && oldMap.get(objSplit.Id) != objSplit)
            {
                objSplit.addError('You can not update Split If Opportunity Stage is 0% Or 100%.');
            }
        }
        
    }
    
}