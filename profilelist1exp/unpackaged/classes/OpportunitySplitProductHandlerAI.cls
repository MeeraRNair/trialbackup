public class OpportunitySplitProductHandlerAI implements AfterInsert{

     public void handleAfterInsert(List<sObject> listNew){
        
        OpportunitySplitUtilities.prepareData(Trigger.new, false);
        
    }
    
}