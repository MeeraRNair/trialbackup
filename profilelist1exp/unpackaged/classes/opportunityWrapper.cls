public class opportunityWrapper
{
    public static void calculatePushedDeals(List<Opportunity> opps, map<id,opportunity> triggerOldMap)
    {
         Map<Id,Opportunity> oppHistoryMap=new Map<Id,Opportunity>([select id, (SELECT oldValue,NewValue,CreatedDate FROM Histories where 
                                                       Field = 'closeDate' order by createdDate asc ) from Opportunity where id in:triggerOldMap.keySet()]);
               
               //Map<Id,RecordType> rtype=new Map<Id,RecordType>([select id,name from RecordType where sobjectType='Opportunity']);
               
               //Modified as a part of Query Limit exception
               Set<String> setRecordType = new Set<String>{'SMB Opportunity','Run Rate Marketing','Deal Registration-Submitted','Create New Deal From LOB','APOS','Deal Registration','Deal Registration for Existing End Customer','Protected Deal','Run Rate Opportunity','Standard Opportunity'};
               Set<ID> rtype = StaticDataUtils.getRecordTypeIdsByNames('Opportunity',setRecordType);
               
               Integer counter;
               for(Opportunity opp:opps)
               {
                   if(rtype.contains(opp.RecordTypeId)){
                        counter=0;
                        if(opp.closeDate!=NULL && triggerOldMap.get(opp.Id).closeDate!=NULL){
                            if(opp.closeDate>triggerOldMap.get(opp.Id).closeDate){
                                counter++;
                            }
                            if(oppHistoryMap.get(opp.Id).Histories!=null){
                               for(OpportunityFieldHistory his:oppHistoryMap.get(opp.Id).Histories){
                                  if(Date.valueOf(his.NewValue)>Date.valueOf(his.OldValue))
                                  counter++;
                               }
                            }
                            opp.PUSHED_DEALS__c=counter;
                         }
                    }
               }
    }
}