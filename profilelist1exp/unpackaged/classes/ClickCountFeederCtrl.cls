/*****************************************************************************************************************
* Name          : ClickCountFeederCtrl
* Description   : Feed Tracker to insert record into SF1Adoption object  and route to the specified destination
* ---------------------------------------------------------
* Revision  Name                Date                Description
* 1.0       Jessie              8th March 2017      CR14055: Story 3089187:SFDC Resource Centre Link Updates & Tracking 
* 2.0       Akshita             07-Jun-2018         CR15930 -Removed Commented lines and, system.debug statements as part of Opportunity code reduce story(FY19-0703)
* 3.0       SinLin              04-Aug-2018         CR16275 Story 5415829: Lightning Critical Update Fix -  Theme ( FY19-DCS-0902)

******************************************************************************************************************/

public class ClickCountFeederCtrl{
    
    @TestVisible private ClickCountSetup__c objClickCountSetup {get; set;}
    @TestVisible private String strRecordId {get; set;}
            
    public ClickCountFeederCtrl(){
        initializeSetupData();
    }
    
    private void initializeSetupData(){
    
        objClickCountSetup = ClickCountSetup__c.getValues(ApexPages.currentPage().getParameters().get('name'));
        strRecordId  = ApexPages.currentPage().getParameters().get('recordId');
    }
    
    public PageReference routeToLink(){
        
        try{
            feedDataToSF1Adoption();        
            PageReference myVFPage = new PageReference(objClickCountSetup.Route_To_URL__c);
            myVFPage.setRedirect(true);
            return myVFPage;
        }catch(Exception e){
            System.debug('### Error Message: ' + e.getMessage());
        }
        return null;
    }
    
    //save data for tracking purpose to SF1Adoption (clicks count)        
    private void feedDataToSF1Adoption(){
        try{
            SF1_Adoption__c obj = new SF1_Adoption__c();
            obj.Object_Name__c = objClickCountSetup.Object_Name__c;
            obj.Region__c =  objClickCountSetup.Region__c;
            obj.Record_ID__c = strRecordId;
            obj.Source__c = objClickCountSetup.Source__c;
            obj.User_Action__c = objClickCountSetup.User_Action__c;
            obj.User_Edited_Date__c = Datetime.now();
            obj.User_Name__c = UserInfo.getUserId(); 
                        
            String sPlatform = userinfo.getUiTheme();
                    
            if (sPlatform == 'Theme1' || sPlatform == 'Theme2' || sPlatform == 'Theme3'){
                obj.Platform__c = 'Salesforce Classic';
            }else if (sPlatform == 'Theme4d' || sPlatform == 'Theme4u'){
                obj.Platform__c = 'Salesforce Lightning';
            }else if (sPlatform == 'Theme4t'){
                obj.Platform__c = 'Salesforce1 Mobile';
            }
            insert obj;
        }catch(DmlException e){
            System.debug('### Error Message: ' + e.getMessage());
        }
    }  
}