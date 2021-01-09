/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         #####       FY17-DCS-1002   06-Sep-2016     Afiq            @InvocableMethod to update Supportability Status in Account from Opportunity
2.0         15930       DCS-FY19-0703   07-Jun-2018     Akshita         Removed Commented lines and, system.debug statements as part of Opportunity code reduce story
*/    
public class PFUSupportabilityStatusCtrlAccount{
    @InvocableMethod(label='Update Supportability Status in Account' 
                    description='This method update Supportability Status in Account from Opportunity List')
    public static void UpdateSupportabilityStatus(List<Id> OpportunityIds)
    {
        set<Id> setAccId = new Set<Id>();
        List<Opportunity> AcctsId = [select accountid from Opportunity where id in :OpportunityIds ];

        for(Opportunity oppIterator : AcctsId)
        {
            setAccId.add(oppIterator.accountid);    
        }        
        if(!setAccId.isEmpty())
        {
            Map<String, Supportability_Status_Mapping__c> mapSupportabilityStatusToPrecedence = new Map<String, Supportability_Status_Mapping__c>();
            if(!Test.isrunningTest())
            {
                mapSupportabilityStatusToPrecedence = Supportability_Status_Mapping__c.getAll();
            }
            else
            {
                Map<String, Supportability_Status_Mapping__c> mapSupportabilityStatusToPrecedence_test = new Map<String, Supportability_Status_Mapping__c>{
                            //2.0 Starts here
                            'Not Supportable'=>new Supportability_Status_Mapping__c(Name='Not Supportable', Precedence__c=0.0),'Expired'=>new Supportability_Status_Mapping__c(Name='Expired', Precedence__c=1.0),
                            'Risk'=>new Supportability_Status_Mapping__c(Name='Risk', Precedence__c=2.0),'Under Review'=>new Supportability_Status_Mapping__c(Name='Under Review', Precedence__c=3.0),
                            'Supportable'=>new Supportability_Status_Mapping__c(Name='Supportable', Precedence__c=4.0)                                                                                                                            
                            //2.0 Ends Here
                        };
                            mapSupportabilityStatusToPrecedence = mapSupportabilityStatusToPrecedence_test;
            } 
            Map<Integer, String> mapPrecedenceToSupportabilityStatus = new Map<Integer, String>();
            
            for(Supportability_Status_Mapping__c objSSM : mapSupportabilityStatusToPrecedence.values())
            {
                mapPrecedenceToSupportabilityStatus.put(Integer.valueOf(objSSM.Precedence__c), objSSM.Name);
            }
            
            Map<Id, Account> mapAccIdToAcc = new Map<Id, Account>([SELECT Id, Supportability_Status__c, (SELECT Id, Supportability_Status__c FROM Opportunities WHERE Supportability_Status__c != null) FROM Account WHERE Id IN : setAccId]);
            Map<Id, Integer> mapAccIdToPrecedence = new Map<Id, Integer>();
            List<Account> lstAcc = new List<Account>();
            
            for(Account objAcc : mapAccIdToAcc.values())
            {    
                if(objAcc.Opportunities.size() > 0){     
                    for(Opportunity objOpp : objAcc.Opportunities)
                    {
                        if(!mapAccIdToPrecedence.containsKey(objAcc.Id))
                        {
                            mapAccIdToPrecedence.put(objAcc.Id, Integer.valueOf(mapSupportabilityStatusToPrecedence.get(objOpp.Supportability_Status__c).Precedence__c));
                        }
                        else if(mapAccIdToPrecedence.containsKey(objAcc.Id) && mapAccIdToPrecedence.get(objAcc.Id) > mapSupportabilityStatusToPrecedence.get(objOpp.Supportability_Status__c).Precedence__c)
                        {
                            mapAccIdToPrecedence.put(objAcc.Id, Integer.valueOf(mapSupportabilityStatusToPrecedence.get(objOpp.Supportability_Status__c).Precedence__c));
                        }
                    }
                }
                else
                {
                    lstAcc.add(new Account(Id = objAcc.Id, Supportability_Status__c = ''));
                }
            }
            if(!mapAccIdToPrecedence.isEmpty())
            {             
                for(Id AccId : mapAccIdToPrecedence.keySet())
                {
                    if(mapAccIdToAcc.get(AccId).Supportability_Status__c != mapPrecedenceToSupportabilityStatus.get(mapAccIdToPrecedence.get(AccId)))
                    {
                        lstAcc.add(new Account(Id = AccId, Supportability_Status__c = mapPrecedenceToSupportabilityStatus.get(mapAccIdToPrecedence.get(AccId))));
                    }                   
                }
            }
            if(!lstAcc.isEmpty())
            {
                TriggerExecutionController.setSkipAccountTriggers(true);
                Database.SaveResult[] results = Database.Update(lstAcc, false);
                //update lstAcc;
                TriggerExecutionController.setSkipAccountTriggers(false);
            }
        }
    }
}