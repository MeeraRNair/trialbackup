/*
* Author   : Subramani Ramamurhty
* Purpose  : Update Lead Status to Close-Work
*        
* Revision Ref Number  Release No      Date           Modified By            Description
* -------- ----------  ----------      -----------    ------------           -----------
* 1.0      CR 15625    FY19-DCE-0502  09-APr-2018     Subramani Ramamurthy   Channel Lead Status Field.
* 1.1      CR 15625    FY19-DCE-0502  04-May-2018     Shue                   DEFECT 5039288: Wunderkind :SDET: For Channel Lead partner status is not sync to lead status when lead status is Closed- worked.
*/


public class CloseChannelUpdateLeadExtension {
    public String LeadID;
    Public Lead FinalLead=new Lead();
    public List<Lead> LeadUpdate;
    public CloseChannelUpdateLeadExtension(apexpages.StandardController Std){
        LeadID=ApexPages.currentPage().getParameters().get('id');
        
    }
    public pagereference LeadChannelUpdate(){
        LeadUpdate=new List<Lead>();
        Lead ThisLead=new Lead();
        FinalLead=[Select id ,Status from Lead where ID=:LeadID];
        
        if(FinalLead!=Null && FinalLead.Status!='Closed - Worked'){
            system.debug('inside If condition');
            ThisLead.id=FinalLead.Id;
            ThisLead.Status='Closed - Worked';
            ThisLead.Partner_Lead_Status__c = 'Closed';
            LeadUpdate.add(ThisLead);
            if(!LeadUpdate.isEmpty()){
                Database.SaveResult[] srList=Database.update(LeadUpdate,False);
                
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                
            }
        }
        else if(FinalLead.Status =='Closed - Worked'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Lead is Already Closed'));
            return null;
        }

        PageReference nextPage = new PageReference('/' + FinalLead.Id);
        return nextPage;
        
    }    
    
}