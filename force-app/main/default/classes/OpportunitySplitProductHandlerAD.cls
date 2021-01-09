public class OpportunitySplitProductHandlerAD implements AfterDelete{

    public void handleAfterDelete(List<sObject> listNew){
        
        OpportunitySplitUtilities.prepareData(Trigger.Old, true);
        
    }
}