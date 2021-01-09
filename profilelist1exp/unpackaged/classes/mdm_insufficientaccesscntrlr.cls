/***********************************************************
* Name          : mdm_insufficientaccesscntrlr
* Description   : To fetch the account details
* ---------------------------------------------------------
* Revision      Release     Name        Date            Description
* 1.0           16.03       Nisha       9-12-2014       To fetch the account details value and to display it on page
                                                        
************************************************************/
public class mdm_insufficientaccesscntrlr{

    public string aid{get;set;}
    public string affiid{get;set;}
    public string accname{get;set;}
    public string accowner{get;set;}
    public string owneremail{get;set;}
    
    public mdm_insufficientaccesscntrlr(){
        aid = apexpages.currentpage().getparameters().get('id');
        system.debug('aid' + aid);
        affiid = apexpages.currentpage().getparameters().get('affinityid');
        accname = apexpages.currentpage().getparameters().get('name');
        accowner = apexpages.currentpage().getparameters().get('owner');
        owneremail = apexpages.currentpage().getparameters().get('owneremail');
        system.debug('owner email:' + owneremail);
    }
}