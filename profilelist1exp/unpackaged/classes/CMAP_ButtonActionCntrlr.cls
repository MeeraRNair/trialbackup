/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Sandhya     19-Nov-2012     14.2         --     Controller for Accpet/Reject button - Lead management.
2.0         Meera       16-Dec-2014     16.03               DSG Lead Accept changes
*/


public class CMAP_ButtonActionCntrlr {
    public Lead leadObj;
    public String action;
    public String pageURL;
    //Version 2.0
    Id DSGLeadRTId = IdLookupUtils.getRecordTypeId('DSG Partner', 'Lead', true);
    public CMAP_ButtonActionCntrlr (ApexPages.StandardController controller) {      
        this.leadObj = (Lead)controller.getRecord();
        action = '';
        pageURL = '/'+leadObj.Id+'/e?';
        action = ApexPages.currentPage().getParameters().get('action');
        if(action != null){
            if(action == 'Accept'){
                leadObj.Status = 'Accepted by Channel Partner';
                leadObj.Partner_Lead_Status__c = 'Accepted';
                leadObj.Accept_Reject_Reassign_Status__c = 'Accepted by Channel';
                //Version 2.0
                 //commented on 15-march-2017 for Story 2742299
               /* if(leadObj.RecordTypeId == DSGLeadRTId ){
                    leadObj.Called_Customer__c = 'Yes';
                    leadObj.Sales_Qualified__c = 'Qualified';
                }*/
                pageURL ='/'+leadObj.Id;                
            }
            if(action == 'Reject'){
                string leadStatus = 'Rejected by Channel Partner';
                string rejectPicklist = 'Rejected by Channel';
                string partnerLeadStatus = 'Rejected';                
                
                pageURL = pageURL+'&lea13='+leadStatus +'&00NA00000063bHG='+partnerLeadStatus+'&00NA00000063bHL='+rejectPicklist+'&00NA0000009ZFtM=TRUE&retURL=/00Q/o&nooverride=1';
            }
            if(action == 'Nurturing'){
                leadObj.Status = 'Qualified - Channel Ready';
                leadObj.Ready_for_Scoring__c = true;
                leadObj.RecordTypeId = IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
                pageURL = '/00Q/o';
            }
            if((action != 'Accept')&&
               (action != 'Reject')&&
               (action != 'Nurturing')){
                PageUtils.addError(System.Label.CMAP_Default_Error_Message);
            }
        }
        else{
            PageUtils.addError(System.Label.CMAP_Default_Error_Message);
        }
    }
    
    public PageReference redirect(){
        if(action == 'Accept' ||  action == 'Nurturing'){
             update leadObj;
        }    
          return(PageUtils.redirect(pageURL));  
    }

}