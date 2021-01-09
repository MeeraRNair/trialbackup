public class OpportunitySplitProductHandlerAU implements AfterUpdate{

    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        
        List<OpportunityLineItem> lst = new List<OpportunitylineItem>();
        for(sObject obj : Trigger.new)
        {
          OpportunityLineItem newOli =  (OpportunityLineItem)obj;
            sObject obj2 = Trigger.OldMap.get(obj.Id);
            OpportunityLineItem oldOli =  (OpportunityLineItem)obj2;
            if(newOli.Quantity != oldOli.Quantity || newOli.UnitPrice != oldOli.UnitPrice)
            {
                lst.add(newOli);
            }
        }
        if(lst.size() >0)
        {
            OpportunitySplitUtilities.prepareData(lst, false);
        }
        
    }
    
}