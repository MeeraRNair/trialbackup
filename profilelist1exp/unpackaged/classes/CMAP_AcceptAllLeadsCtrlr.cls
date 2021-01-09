/*
REVISION HISTORY
======================================================================================================================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0        Afiq        01/10/2015        16.10       12014   Creating a controller for mass accepting all the leads based on criteria

*/

public with sharing class CMAP_AcceptAllLeadsCtrlr {
    
    Public CMAP_AcceptAllLeadsCtrlr(ApexPages.StandardController stdController){
    }
    
    Public CMAP_AcceptAllLeadsCtrlr(ApexPages.StandardSetController stdController){
    }

    public PageReference AcceptAllLead(){
    
        PageReference retUrl = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/00Q/o'); // set the URL to Lead Home Tab
        Id UserId=UserInfo.getUserId(); //Query for current user id 
        List<Lead> leadLookUp = [SELECT Id, Status from Lead WHERE status = 'Assigned to Channel partner' and ownerID = :UserId ]; // Query for the leads based on criteria 
        for(Lead l : leadLookUp){
            l.status = 'Accepted by Channel Partner'; //set the value for Status to 'Accepted by Channel Partner'
            l.Accept_Reject_Reassign_Status__c='Accepted by Channel'; // set the value for Accept_Reject_Reassign_Status__c to 'Accepted by Channel'
            l.Partner_Lead_Status__c = 'Accepted'; // set the value for Partner_Lead_Status__c to 'Accepted'
            
        }
        update leadLookUp ;
        return retUrl;
    }
}