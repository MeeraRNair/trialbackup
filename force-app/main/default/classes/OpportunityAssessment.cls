/* 
History:
Version     Date            Modified By                     CR          Description     
--------------------------------------------------------------------------------------
1.0         22-Jul-2016     Shahiruni Wahida                13334       Story 1913809:Add a new opportunity survey button to Opportunity page
2.0         07-Jun-2018     Akshita                         15930       Removed Commented lines and, system.debug statements as part of Opportunity code reduce story
3.0         04-Aug-2018     SinLin                          16275       Story: 5415829 Lightning Critical Update Fix - Theme
*/

public class OpportunityAssessment {
    public Opportunity currentRecord;
    
    public OpportunityAssessment(ApexPages.StandardController controller) {
        currentRecord = [SELECT Deal_ID__c, Account.Regional_Parent_Name_lookup__c FROM Opportunity WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
    }

    
    public PageReference redirect() {
        countClick();
        try{
            return new PageReference(Label.Oppty_AssessmentLink);
        }catch(Exception e){System.debug(e.getMessage());}
        return null;
    }
    

    public void countClick(){
        try{
            //Save data for tracking purpose (clicks count)
            SF1_Adoption__c obj = new SF1_Adoption__c();
            obj.Object_Name__c = 'Opportunity';
            obj.Record_ID__c = currentRecord.Deal_ID__c;
            obj.Source__c =  'SurveyOppty';
            obj.User_Action__c = '';
            obj.User_Edited_Date__c = Datetime.now();
            obj.User_Name__c = UserInfo.getUserId(); 
            obj.Region__c = currentRecord.Account.Regional_Parent_Name_lookup__c;
            
            String sPlatform = userinfo.getUiTheme();
            
            String a = '';
            String b = '';
            String c = '';
            if (sPlatform == 'Theme1' || sPlatform == 'Theme2' || sPlatform == 'Theme3'){
                obj.Platform__c = 'Salesforce Classic';
            }else if (sPlatform == 'Theme4d' || sPlatform == 'Theme4u'){
                obj.Platform__c = 'Salesforce Lightning';
            }else if (sPlatform == 'Theme4t'){
                obj.Platform__c = 'Salesforce1 Mobile';
            }
            
            insert obj;
        }catch(DmlException e){System.debug(e.getMessage());}
    }
}