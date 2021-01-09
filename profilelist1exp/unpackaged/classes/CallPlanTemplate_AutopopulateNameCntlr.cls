/*-----------------------------------------------------------------------------------------------
Version     By          CR      Description
1.0         Meghana     8577    When Call Plan Template is cloned, template name should be auto-populated as 'Clone of <actual template name>'

-------------------------------------------------------------------------------------------------*/

public with sharing class CallPlanTemplate_AutopopulateNameCntlr {

    public string CPT_name {get; set;} // string to store actual tempalte name
    
    public CallPlanTemplate_AutopopulateNameCntlr(ApexPages.StandardController stdController) {
        // get Template id that is getting cloned
        Id CPTid = ApexPages.currentPage().getParameters().get('id');
        // get actual template name
        if (CPTid != null){
            list<Call_Plan_Template__c> c = [select name from Call_Plan_Template__c where id = :CPTid ];
            if (! c.isEmpty())
                CPT_name = c.get(0).name;                
        }
    }
}