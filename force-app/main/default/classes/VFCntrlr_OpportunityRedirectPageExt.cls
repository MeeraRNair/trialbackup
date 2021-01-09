public class VFCntrlr_OpportunityRedirectPageExt {
/************************************************************************
* Revision History
* Version   Date            ModifiedBy      Description
* -----------------------------------------------------------
* 1.0       09-Dec-2009     Raymond Yip     Created for CR2134,CR2136 (R11.1)
* 2.0       19-Jan-2010     Raymond Yip     Rename all Small Opportunity to Run Rate Marketing
* 3.0       09-Jul-2010     Raymond Yip     Add LOT reminder for Run Rate Standard oppty
* 4.0       14-Aug-2012     Deepthi D       Add default value for CR7406, CR7408(R13.10)
* 5.0       12-May-2014     Devika          Change default book date value from 15 to 43(CR 8299)
* 5.1       23-May-2014     Sree Prakash    CR#9361
* 5.2       30-Mar-2015     Jiji            CR#11149; TT# INC000017798867
* 5.3       01-Mar-2016    JVSANTOSH        AUTO POPULATE DISRTIBUTION
* 5.4       06-Nov-2017     Sneha           CR#4000940 - Updating the AUTO POPULATE DISRTIBUTION logic for GC
* 6.0       07-Jun-2018     Akshita         CR15930 - Removed Commented lines and, system.debug statements as part of Opportunity code reduce story
************************************************************************/

    private string STANDARD_RUN_RATE_OPPTY_NAME = 'Run Rate Opportunity';
    private string MARKETING_RUN_RATE_OPPTY_NAME = 'Run Rate Marketing';
    private String DEAL_REG_OPPTY='Deal Registration';
    private string CUSTOMER_DEAL_REG='Deal Registration for Existing End Customer';
    private string LOB_DEAL='Create New Deal From LOB';
    public Boolean hasError {get; set;}
    public Boolean MarketingRunRateError {get; set;}
    public String errorMessage {get; set;}
    public VFCntrlr_OpportunityRedirectPageExt() {}
    public Boolean confirmNew = false;
    public Boolean dealRecord= false;

    public VFCntrlr_OpportunityRedirectPageExt (ApexPages.StandardController controller) {
        hasError = false;
        MarketingRunRateError=false;
    }

    public PageReference redirectConfirmNew() {
        confirmNew = true;
        return redirect();
    }

    public PageReference redirect() {
        try {
            List<RecordType> recTypeList = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' AND Name IN (:STANDARD_RUN_RATE_OPPTY_NAME,:MARKETING_RUN_RATE_OPPTY_NAME, :DEAL_REG_OPPTY,:CUSTOMER_DEAL_REG,:LOB_DEAL) ];
               
            if(recTypeList.size() >= 0) {    
                
                Map<String, String> opptyRecTypeMap = new Map<String,String>();
                
                for(RecordType rt : recTypeList) {
                    opptyRecTypeMap.put(rt.Name, String.valueOf(rt.Id).subString(0,15));
                }
                                       
                PageReference pr = ApexPages.currentPage();
                Map<String, String> params = pr.getParameters();
                String stringToAppend = '';
                
                for(String keyStr : params.keySet()){
                    if(keyStr != 'sfdc.override' && keyStr != 'save_new'){
                        if(stringToAppend != '') {
                            stringToAppend += '&';
                        }   
                        stringToAppend += keyStr + '=' + pageUtils.encodeVariable(params.get(keyStr));
                    }
                }               
                String recId = params.get('RecordType');
                if(recId == null ) {
                    return new PageReference('/006/e?nooverride=1&'+stringToAppend);
                }            
                //default opp9 (BookDate) to end of quarter if Opportunity is Run Rate
                else if(recId.equals(opptyRecTypeMap.get(STANDARD_RUN_RATE_OPPTY_NAME))) {
                    if(confirmNew) {                    
                        return new PageReference('/006/e?nooverride=1&opp11=Commit%20-%2090%25&opp9='+OpportunityUtils.getNearestQuarterEndDateString()+'&'+stringToAppend);
                    } else {
                        return null;
                    }
                }
                else if(recId.equals(opptyRecTypeMap.get(MARKETING_RUN_RATE_OPPTY_NAME))) {
                    MarketingRunRateError = true;
                    return null;
                }
               else {
                    for(String rT :opptyRecTypeMap.values()){
                        if(rT==recId.subString(0,15))dealRecord= true;
                    }                    
                    if(dealRecord== true){
                       String appendDistiFullfillment = '';
                        //v5.0 Commented Code // Date pastDate= Date.today()+15;
                        Date pastDate= Date.today()+43;//v5.0
                        Id usId=Userinfo.getUserId();
                        if(Userinfo.getUserType().contains('Partner')){
                            List<User> curUser=[select contactId from user where id =:usId];
                            List<contact> curContact=[select phone, AccountId, Account.Partner_Type__c,Account.Partner_Tier__c, Account.Partner_Relationship__c from contact where id = :curUser[0].contactId];
                            /******************************************************** CR:12703 &&&&&&&&&&Distribution Autopopulation&&&&&&&&& STARTS **************************************/
                          //CR:12703
                            If( recId.equals(opptyRecTypeMap.get(DEAL_REG_OPPTY)) || recId.equals(opptyRecTypeMap.get(CUSTOMER_DEAL_REG)) || recId.equals(opptyRecTypeMap.get(LOB_DEAL)) ){
                                String partnerType = DistiVisibilityHelperClass.getPartnerType(usId);
                                If( partnerType == 'Distributor' || partnerType == 'Tier2' || partnerType =='Sub Distributor'){
                                    appendDistiFullfillment = '&00NA00000063WJM=Distribution';                                    
                                }else If( partnerType == 'Tier1' ){
                                    appendDistiFullfillment = '';
                                }
                            }
                            //START - CR 9361
                            Id profileId = userinfo.getProfileId();
                            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
                            
                            if(profileName.contains('APJ PRM Portal User') || profileName.contains('EMEA PRM Portal User') || profileName.contains('EMEA PRM Portugal Portal User') || profileName.contains('LA PRM Portal User') || profileName.contains('NA PRM Portal User') || profileName.contains('Strategic Partner User')){ 
                                if(recId.equals(opptyRecTypeMap.get(LOB_DEAL)) && curContact[0].AccountId == null) {
                                    return new PageReference('/apex/LOB_AvailableCustomers?'+appendDistiFullfillment);
                                }  
                                else if(recId.equals(opptyRecTypeMap.get(LOB_DEAL))) {
                                    return new PageReference('/apex/LOB_AvailableCustomers?id=' + curContact[0].AccountId + appendDistiFullfillment);
                                }
                            }
                            //END - CR 9361

                            if(curContact[0].phone!= null)
                                return new PageReference('/006/e?ent=Opportunity&nooverride=1&RecordType='+recId+'&opp9='+pastDate.format()+'&00NA00000063WX9='+curContact[0].phone+'&'+stringToAppend + appendDistiFullfillment);
                            else
                                return new PageReference('/006/e?ent=Opportunity&nooverride=1&RecordType='+recId+'&opp9='+pastDate.format()+'&'+stringToAppend + appendDistiFullfillment);
                        }                 
                        else
                            return new PageReference('/006/e?ent=Opportunity&nooverride=1&RecordType='+recId+'&opp9='+pastDate.format()+'&'+stringToAppend + appendDistiFullfillment);
                    }
                    return new PageReference('/006/e?nooverride=1&' + stringToAppend);
                }
            }
            
           //END CR:12703 
    // *************************************************"CR:'12703' &&&&&&&&&&Distribution Autopopulation&&&&&&&&&  ENDS   *********************************************************************************************
            else {
                //should not reach here if both Run Rate Marketing Opportunity and Run Rate Opportunity exists.
                throw new dellUtil.DellException('Run Rate Opportunity or Run Rate Marketing record type may be missing.');
            }
            return null;
        }
        catch(Exception e) {
            hasError = true;
            errorMessage = e.getMessage();
            return null;
        }
    }    
   
    static testMethod void testVFCntrlr_OpportunityRedirectPageExtForPRM() {
        
        test.startTest();
        List<RecordType> recTypeList = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Deal Registration'];
        PageReference pageRef = Page.OpportunityRedirectPage;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('recordtype', String.valueOf(recTypeList[0].Id).subString(0,15));
        VFCntrlr_OpportunityRedirectPageExt controller = new VFCntrlr_OpportunityRedirectPageExt();
            
        PageReference resultPR = controller.redirectConfirmNew();
        System.assert(resultPR.getParameters().containsKey('opp9'));
        System.assert(resultPR.getParameters().containsKey('RecordType'));
        test.stopTest();
    }
    

    static testMethod void testVFCntrlr_OpportunityRedirectPageExtForNormalRunRate() {
        
        test.startTest();
        List<RecordType> recTypeList = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Run Rate Opportunity'];
        System.assert(recTypeList.size() >= 1);  
        
        PageReference pageRef = Page.OpportunityRedirectPage;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('recordtype', String.valueOf(recTypeList[0].Id).subString(0,15));
                
        VFCntrlr_OpportunityRedirectPageExt controller = new VFCntrlr_OpportunityRedirectPageExt();
            
        PageReference resultPR = controller.redirectConfirmNew();
        system.debug('##DEBUG## testVFCntrlr_OpportunityRedirectPageExtForNormalRunRate: url= ' + resultPR.getURL());
        System.assert(resultPR.getURL().contains('/006/e?'));
        System.assert(resultPR.getParameters().containsKey('opp9'));
        System.assert(resultPR.getParameters().containsKey('RecordType'));
        
        test.stopTest();
    }

    static testMethod void testVFCntrlr_OpportunityRedirectPageExtForMarketingRunRate() {
       
        test.startTest();
        List<RecordType> recTypeList = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Run Rate Marketing'];
        System.assert(recTypeList.size() >= 1);  
        
        PageReference pageRef = Page.OpportunityRedirectPage;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('recordtype', String.valueOf(recTypeList[0].Id).subString(0,15));
        
        //to cover constructor
        VFCntrlr_OpportunityRedirectPageExt controller1 = new VFCntrlr_OpportunityRedirectPageExt(new ApexPages.StandardController(new Opportunity()));        
         
        VFCntrlr_OpportunityRedirectPageExt controller = new VFCntrlr_OpportunityRedirectPageExt();
            
        PageReference resultPR = controller.redirect();
        System.assert(resultPR == null);
        System.assert(controller.MarketingRunRateError);
        test.stopTest();
    }
    
    static testMethod void testVFCntrlr_OpportunityRedirectPageExtForNoSpecificRecordType() {
        
        test.startTest();
        
        PageReference pageRef = Page.OpportunityRedirectPage;
        Test.setCurrentPage(pageRef);
        
        List<RecordType> recTypeList = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Standard Opportunity'];
               
        VFCntrlr_OpportunityRedirectPageExt controller = new VFCntrlr_OpportunityRedirectPageExt();
            
        PageReference resultPR = controller.redirect();
        System.assert(resultPR.getURL().contains('/006/e?'));
        test.stopTest();
    }
    
     static testMethod void testVFCntrlr_OpportunityRedirectPageExtForOtherOppty() {
        
        test.startTest();
        List<RecordType> recTypeList = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Standard Opportunity'];
        System.assert(recTypeList.size() >= 1);  
        
        PageReference pageRef = Page.OpportunityRedirectPage;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('recordtype', String.valueOf(recTypeList[0].Id).subString(0,15));
         VFCntrlr_OpportunityRedirectPageExt controller = new VFCntrlr_OpportunityRedirectPageExt();
            
        PageReference resultPR = controller.redirect();
        System.assert(resultPR.getURL().contains('/006/e?'));
        System.assert(resultPR.getParameters().containsKey('RecordType'));
        
        test.stopTest();
    }
}