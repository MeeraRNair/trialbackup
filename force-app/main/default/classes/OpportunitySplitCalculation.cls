public class OpportunitySplitCalculation {

    public static void splitCalculation (Map<String,List<OpportunityLineItem>> mapGrptoOli, Map<String,List<AccountTeamMember>> mapGrpToMem, List<OpportunitySplit> lstOppSplit,List<Opportunity> lstOpp, Decimal amount, Boolean isDelete)
    {
        //TriggerExecutionController.setSkipOpportunitySplitTriggers(true);      
    
        List<OpportunitySplit> updatedOS = new List<OpportunitySplit>();
        List<OpportunitySplit> lstupdatedOS = new List<OpportunitySplit>();
        Set<OpportunitySplit> SetUpdatedOs = new Set<OpportunitySplit>();
        List<AccountTeamMember> lstATM = new List<AccountTeamMember>();
        /* Added code - Split issue 12/17 */
        Map<id, list<id>> opptyTeamMemberToOppMap = new Map<id, list<id>>();
        /* End Added code - Split issue 12/17 */
        OpportunitySplitType oppSplit=[select Id from OpportunitySplitType where developername = 'Overlay'];
        Map<String,List<OpportunitySplit>> mapGrptoSplt = new Map<String,List<OpportunitySplit>>();
        /* Added code - Split issue 12/17 */
        Boolean isMissingOTMSplitAssignment = false;
        List<OpportunityTeamMember> otmList = new list<OpportunityTeamMember>();
        otmList = [select id, OpportunityId, UserId from OpportunityTeamMember WHERE OpportunityId IN: lstOpp];
        
        if(otmList.size()>0){
            for (OpportunityTeamMember otmRec : otmList){
            	list<id> otmIdList = opptyTeamMemberToOppMap.get(otmRec.OpportunityId );
                if(otmIdList == null){
                    otmIdList = new list<id>();
				}
                otmIdList.add(otmRec.UserId);
                opptyTeamMemberToOppMap.put(otmRec.OpportunityId , otmIdList);
        	}
            system.debug('OTMLIST EXTRACT' +opptyTeamMemberToOppMap.keyset());
        }
        /* End Added code - Split issue 12/17 */
        
        for(OpportunitySplit objSplit : lstOppSplit)
        {
            if(objSplit.Forecast_Group__c != null)
            {
                if(mapGrptoSplt.containsKey(objSplit.Forecast_Group__c))
                {
                    List<OpportunitySplit> lstsplt = mapGrptoSplt.get(objSplit.Forecast_Group__c);
                    lstsplt.add(objSplit);
                    mapGrptoSplt.put(objSplit.Forecast_Group__c, lstsplt);
                }
                else
                {
                    mapGrptoSplt.put(objSplit.Forecast_Group__c, new List<OpportunitySplit>{objSplit});
                }
            }
            if(objSplit.SplitType.DeveloperName == System.label.Split_Type_Revenue)
            {
                objSplit.Amount__c = amount;
                objSplit.Percentage__c = 100;
                objSplit.Updated_Automaticaly__c = true;
                updatedOS.add(objSplit);
                
            }
        }
        if(!isDelete)
        {
            system.debug('mapGrptoOli :' + mapGrptoOli);
            system.debug('mapGrpToMem :' + mapGrpToMem);
            for(String grp : mapGrptoOli.keySet())
            {
                if(!mapGrptoSplt.containsKey(grp))
                {
                    Decimal splitAmt = 0;
                    for(OpportunityLineItem objOpli : mapGrptoOli.get(grp))
                    {
                        splitAmt = splitAmt + objOpli.TotalPrice;
                    }
                    if(mapGrpToMem.ContainsKey(grp))
                    {
                        lstATM = mapGrpToMem.get(grp);
                        for(integer i=0; i<lstATM.size()-1; i++)
                        {
                            if(lstATM[0].CreatedDate > lstATM[i+1].CreatedDate)
                            {
                                AccountTeamMember objATM = new AccountTeamMember();
                                objATM = lstATM[0];
                                lstATM[0] = lstATM[i+1];
                                lstATM[i+1] = objATM;
                            }
                        }
                        system.debug('lstATM :' + lstATM);
                         /* Added code - Split issue 12/17 */
                        list<id> otmListFrmMap = opptyTeamMemberToOppMap.get(lstOpp[0].Id);
                        if(otmListFrmMap.contains(lstATM[0].UserId)){
                         /* End Added code - Split issue 12/17 */ 
                                OpportunitySplit objOS = new OpportunitySplit();
                                objOS.Forecast_Group__c = grp;
                                objOS.Percentage__c = 100;
                                objOS.Amount__c = splitAmt;
                                objOS.SplitTypeId = oppSplit.Id;
                                objOS.OpportunityId = lstOpp[0].Id;
                                objOS.SplitPercentage = 100;
                                //objOS.Updated_Automaticaly__c = true;
                                objOS.SplitOwnerId = lstATM[0].UserId;
                                updatedOS.add(objOS);
                          /* Added code - Split issue 12/17 */
                        }
                        else{
                            isMissingOTMSplitAssignment = true;
                        }
                         /* End Added code - Split issue 12/17 */ 
                        for(integer i=1; i<lstATM.size(); i++)
                        {
                            /* Added code - Split issue 12/17 */
                            if(otmListFrmMap.contains(lstATM[i].UserId)){
                            /* End Added code - Split issue 12/17 */     
                                OpportunitySplit objOS = new OpportunitySplit();
                                objOS.Forecast_Group__c = grp;
                                if(isMissingOTMSplitAssignment){
                                    System.debug('*************Missed Assignment*********');
                                   objOS.Percentage__c = 100; 
                                    isMissingOTMSplitAssignment = false;
                                }
                                else{
                                	objOS.Percentage__c = 0;
                                }
                                objOS.Amount__c = 0;
                                objOS.SplitTypeId = oppSplit.Id;
                                objOS.OpportunityId = lstOpp[0].Id;
                                objOS.SplitPercentage = 100;
                                //objOS.Updated_Automaticaly__c = true;
                                objOS.SplitOwnerId = lstATM[i].UserId;
                                updatedOS.add(objOS);
                            /* Added code - Split issue 12/17 */
                            }
                            /* End Added code - Split issue 12/17 */ 
                        }
                       /* AccountTeamMember objOpptm = mapGrpToMem.get(grp)[0];
                    for(AccountTeamMember objOtm : mapGrpToMem.get(grp))
                    {
                        if(objOtm.CreatedDate <= objOpptm.CreatedDate)
                        {
                            objOpptm = objOtm;
                        }
                    }*/
                    }
                }
                else
                {
                    Decimal splitAmt = 0;
                    for(OpportunityLineItem objOpli : mapGrptoOli.get(grp))
                    {
                        splitAmt = splitAmt + objOpli.TotalPrice;
                    }
                    for(OpportunitySplit objoppsp : mapGrptoSplt.get(grp))
                    {
                        if(objOppSp.Percentage__c != 0 && objoppsp.Percentage__c != null && splitAmt != 0)
                        {
                            objoppsp.Amount__c = (splitAmt * objoppsp.Percentage__c)/100;
                        }
                        //objoppsp.Updated_Automaticaly__c = true;
                        updatedOS.add(objoppsp);
                    }
                }
            }
            system.debug('updatedOS : ' + updatedOS);
            
            TriggerExecutionController.setSkipOpportunitySplitTriggers(true);  
            try{
                Upsert updatedOS Id;
            }
            catch (exception e)
            {
                for(sObject obj : Trigger.new)
                {
                     OpportunityLineItem newOli =  (OpportunityLineItem)obj;
                    /* Added code - Split issue 12/17 */
                    newOli.addError(e.getMessage());//'A forecast group must total 100%.');
                    /* End Added code - Split issue 12/17 */
                }
                
            }
            TriggerExecutionController.setSkipOpportunitySplitTriggers(false);  
           }
        else
        {
            for(String grp : mapGrptoSplt.keySet())
            {
                if(!mapGrptoOli.containsKey(grp))
                {
                    for(OpportunitySplit objOppSp : mapGrptoSplt.get(grp))
                    {
                        objOppSp.Amount__c = 0;
                        updatedOS.add(objOppSp);
                    }
                }
                else
                {
                    Decimal splitAmt = 0;
                    for(OpportunityLineItem objOpli : mapGrptoOli.get(grp))
                    {
                        splitAmt = splitAmt + objOpli.TotalPrice;
                    }
                    for(OpportunitySplit objOppSp : mapGrptoSplt.get(grp))
                    {
                        if(objOppSp.Percentage__c != 0 && objoppsp.Percentage__c != null && splitAmt != 0)
                        {
                            objOppSp.Amount__c = (splitAmt * objOppSp.Percentage__c)/100;
                        }
                        else
                        {
                            objOppSp.Amount__c = 0;
                        }
                        
                        updatedOS.add(objOppSp);
                    }
                }
            }
            system.debug('updatedOS : ' + updatedOS);
            
            TriggerExecutionController.setSkipOpportunitySplitTriggers(true);  
            try{
                Upsert updatedOS Id;
            }
            catch (exception e)
            {
                for(sObject obj : Trigger.old)
                {
                     OpportunityLineItem newOli =  (OpportunityLineItem)obj;
                    /* Added code - Split issue 12/17 */
                    newOli.addError(e.getMessage());//'A forecast group must total 100%.');
                    /* End Added code - Split issue 12/17 */
                }
            }
            TriggerExecutionController.setSkipOpportunitySplitTriggers(false); 
        }
        
        
        
    }
    public static void splitCalculationManual (Map<String,List<OpportunityLineItem>> mapGrptoOli, Map<String,List<AccountTeamMember>> mapGrpToMem, List<OpportunitySplit> lstOppSplit,List<Opportunity> lstOpp, Decimal amount)
    {
        List<OpportunitySplit> updatedOS = new List<OpportunitySplit>();
        List<AccountTeamMember> lstATM = new List<AccountTeamMember>();
        OpportunitySplitType oppSplit=[select Id from OpportunitySplitType where developername = 'Overlay'];
        Map<String,List<OpportunitySplit>> mapGrptoSplt = new Map<String,List<OpportunitySplit>>();
        for(OpportunitySplit objSplit : lstOppSplit)
        {
            if(objSplit.Forecast_Group__c != null)
            {
                if(mapGrptoSplt.containsKey(objSplit.Forecast_Group__c))
                {
                    List<OpportunitySplit> lstsplt = mapGrptoSplt.get(objSplit.Forecast_Group__c);
                    lstsplt.add(objSplit);
                    mapGrptoSplt.put(objSplit.Forecast_Group__c, lstsplt);
                }
                else
                {
                    mapGrptoSplt.put(objSplit.Forecast_Group__c, new List<OpportunitySplit>{objSplit});
                }
            }
             if(objSplit.SplitType.DeveloperName == System.label.Split_Type_Revenue)
            {
                objSplit.Amount__c = amount;
                objSplit.Percentage__c = 100;
                //objSplit.Updated_Automaticaly__c = true;
                updatedOS.add(objSplit);
                
            }
        }
            for(String grp : mapGrptoOli.keySet())
            {
                if(!mapGrptoSplt.containsKey(grp))
                {
                    Decimal splitAmt = 0;
                    for(OpportunityLineItem objOpli : mapGrptoOli.get(grp))
                    {
                        splitAmt = splitAmt + objOpli.TotalPrice;
                    }
                    if(mapGrpToMem.ContainsKey(grp))
                    {
                        lstATM = mapGrpToMem.get(grp);
                        for(integer i=0; i<lstATM.size()-1; i++)
                        {
                            if(lstATM[0].CreatedDate > lstATM[i+1].CreatedDate)
                            {
                                AccountTeamMember objATM = new AccountTeamMember();
                                objATM = lstATM[0];
                                lstATM[0] = lstATM[i+1];
                                lstATM[i+1] = objATM;
                            }
                        }
                        for(integer i=1; i<lstATM.size(); i++)
                        {
                             OpportunitySplit objOS = new OpportunitySplit();
                            objOS.Forecast_Group__c = grp;
                            objOS.Percentage__c = 0;
                            objOS.Amount__c = 0;
                            objOS.SplitTypeId = oppSplit.Id;
                            objOS.OpportunityId = lstOpp[0].Id;
                            objOS.SplitPercentage = 100;
                            //objOS.Updated_Automaticaly__c = true;
                            objOS.SplitOwnerId = lstATM[i].UserId;
                            updatedOS.add(objOS);
                        }
                       /* AccountTeamMember objOpptm = mapGrpToMem.get(grp)[0];
                    for(AccountTeamMember objOtm : mapGrpToMem.get(grp))
                    {
                        
                        if(objOtm.CreatedDate <= objOpptm.CreatedDate)
                        {
                            objOpptm = objOtm;
                        }
                        
                        
                    }*/
                    OpportunitySplit objOS = new OpportunitySplit();
                        objOS.Forecast_Group__c = grp;
                        objOS.Percentage__c = 100;
                        objOS.Amount__c = splitAmt;
                        objOS.SplitTypeId = oppSplit.Id;
                        objOS.OpportunityId = lstOpp[0].Id;
                        objOS.SplitPercentage = 100;
                        //objOS.Updated_Automaticaly__c = true;
                        objOS.SplitOwnerId = lstATM[0].UserId;
                        updatedOS.add(objOS);
                    }
                    
                }
                else
                {
                    Decimal splitAmt = 0;
                    for(OpportunityLineItem objOpli : mapGrptoOli.get(grp))
                    {
                        splitAmt = splitAmt + objOpli.TotalPrice;
                    }
                    for(OpportunitySplit objoppsp : mapGrptoSplt.get(grp))
                    {
                        if(objoppsp.Percentage__c != null)
                        {
                            objoppsp.Amount__c = (splitAmt * objoppsp.Percentage__c)/100;
                        }   
                            updatedOS.add(objoppsp);
                        
                    }
                }
            } 
                 //TriggerExecutionController.setSkipOpportunitySplitTriggers(false);
    }
}