/*

 * Revision   Date            Modified By     Description
 * --------   -----------     ------------    -----------
 * 1.0        1-Dec-2019      Urvish          Created class for Opportunity Split
 
*/

public class OpportunitySplitHandlerBI implements BeforeInsert{

    
     public void handleBeforeInsert(List<sObject> listNew){
        OpportunitySplitValidator.validateOppSplitforInsert(Trigger.new);
        OpportunitySplitValidator.validateForecastGroup(Trigger.new);
        OpportunitySplitManualCalculation.splitManualCalculation(Trigger.new, false); 
        
    }
    
}