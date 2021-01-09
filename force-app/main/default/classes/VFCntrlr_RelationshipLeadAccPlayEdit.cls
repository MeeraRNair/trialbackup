/***********************************************************
* Name          : VFCntrlr_RelationshipLeadAccPlayEdit
* Description   : Controller for RelationshipLeadEditOverridePage and AccountPlayEditOverridePage
* ---------------------------------------------------------
* Revision  Name    Date        Description
* 1.0       MenMee  18.09.2009  Prompt User a message when User clicks 'Edit' in list view
                                
* 
*
*
************************************************************/

public class VFCntrlr_RelationshipLeadAccPlayEdit {
    private SObject relationshipLeadOrAccountPlayRecord;
    private string retURL;   
    
    // Constructor
    // To get the record id and retURL 
    public VFCntrlr_RelationshipLeadAccPlayEdit(ApexPages.StandardController controller) {
        relationshipLeadOrAccountPlayRecord= controller.getRecord();
        retURL = ApexPages.currentPage().getParameters().get('retURL'); 
        System.debug('retURL='+retURL); 
    }
    
    // Back to the List view    
    public PageReference navigateToList() {
    	if (retURL != null)
        	return new PageReference(retURL);
        else
        	return null;        
    }
    
    // Go to the Detail page
    public PageReference navigateToDetail() {
        if (relationshipLeadOrAccountPlayRecord.Id != null) {
	        PageReference detailPage = new PageReference('/' + relationshipLeadOrAccountPlayRecord.Id); 
	        detailPage.setRedirect(true);
        	return detailPage;
        }
        else
        	return null;              
    }   
}