/************************************************************************
* Revision History
* Version   Date            ModifiedBy      Description
* -----------------------------------------------------------
* 1.0       16-Dec-2009     Raymond Yip     Created for CR2136. Marketing Small Oppty
* 2.0       19-Jan-2010     Raymond Yip     Rename Small Opportunity to Run Rate Marketing
* 3.0       23-Aug-2010     Nooryati        62397: Prompted with 'Creating Run Rate Opp' warning if user attempt to create Opp via AP/RL acceptance process
* 4.0       27-Sep-2010     Raymond Yip     CR4440 - Remove the code to default Probability to 1% (to prevent it from being inconsistent with stage)
* 5.0 		15-Nov-2011		Jessie Tan		CR6449(R13.1) - Populate Solution Id from RL to RunRateMarketing opportunity
************************************************************************/

public class VFCntrlr_OpptyMarketingRunRateNewExt {
    
    boolean showOpptyDetail = false;
    
    public  VFCntrlr_OpptyMarketingRunRateNewExt() {}
        
    public  VFCntrlr_OpptyMarketingRunRateNewExt(ApexPages.StandardController controller) {     
        defaultMarketingRunRateOppty((Opportunity)controller.getRecord()); 
    }
    
    public boolean getshowOpptyDetail() {
        return showOpptyDetail;
    }
    
    public void defaultMarketingRunRateOppty(Opportunity oppty) {
        Map<String, String> param = ApexPages.currentPage().getParameters();
        String accountId = param.get('accountId');
        String campaignId = param.get('campaignId');
        String sourceId = param.get('sourceId');
        
        //Rev 5.0 - start
        String solutionId = param.get('solutionId');
        //Rev 5.0 - end
        
        List<RecordType> recTypeList = [SELECT Id FROM RecordType WHERE SObjectType='Opportunity' AND Name='Run Rate Marketing'];
        
        //Default fields for Run Rate Marketing
        if(recTypeList.size() == 1) {
                oppty.AccountId = accountId;
                oppty.CampaignId = campaignId;
                oppty.Type='Run Rate';
                oppty.CloseDate=System.today()+30;
                oppty.StageName = 'Plan - 1%';
                oppty.Marketing_Created_Opportunity__c = true;
                //oppty.Probability = 1;
                oppty.RecordTypeId = recTypeList[0].Id;     
                oppty.Source_Id__c = sourceId;
                //Rev 5.0 - start
                oppty.Solution_ID__c = solutionId;
                //Rev 5.0 - end
        }       
    }
    
    public PageReference confirmContinue() {
        showOpptyDetail = true;
        return null;
    }
    
    static TestMethod void testGetters() {
        
        PageReference pageRef = Page.OpportunityMarketingRunRateNew;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL                        
        VFCntrlr_OpptyMarketingRunRateNewExt controller = new VFCntrlr_OpptyMarketingRunRateNewExt();
        controller.confirmContinue();    
        controller.getShowOpptyDetail();
        
    }
    
    static TestMethod void testVFCntrlr_OpptyMarketingRunRateNewExt() {
        
        test.startTest();
        List<RecordType> recTypeList = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Run Rate Marketing'];
        System.assert(recTypeList.size() >= 1);  
        
        PageReference pageRef = Page.OpportunityMarketingRunRateNew;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL                        
        VFCntrlr_OpptyMarketingRunRateNewExt controller = new VFCntrlr_OpptyMarketingRunRateNewExt();
        controller.defaultMarketingRunRateOppty(new Opportunity());    
        
        test.stopTest();
        
    }

    static testMethod void testOppptyPickListsValues() {
        Schema.DescribeFieldResult opptyType = Opportunity.Type.getDescribe();
        List<Schema.PicklistEntry> opptyTypePickListValues = opptyType.getPicklistValues();

        Map<String, Schema.PicklistEntry> opptyPlayTypeEntryMap = new Map<String, Schema.PicklistEntry>();
        for(Schema.PicklistEntry entry : opptyTypePickListValues) {
            opptyPlayTypeEntryMap.put(entry.getLabel(), entry);          
        }
        
        System.assert(opptyPlayTypeEntryMap.ContainsKey('Run Rate'));
        
        Schema.DescribeFieldResult opptyStageName = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> opptyStageNamePickListValues = opptyStageName.getPicklistValues();

        Map<String, Schema.PicklistEntry> opptyStageNameTypeEntryMap = new Map<String, Schema.PicklistEntry>();
        for(Schema.PicklistEntry entry : opptyStageNamePickListValues) {
            opptyStageNameTypeEntryMap.put(entry.getLabel(), entry);          
        }

        System.assert(opptyStageNameTypeEntryMap.ContainsKey('Win - 100%'));
    }
}