@isTest
private class VFCntrlr_SalesNominationFromContactTest{    
    
  public static testMethod void VFCntrlr_SalesNominationNominate(){
    
        List<campaign> campList=createCampaign();
        List< VFCntrlr_SalesNominationConFromContact.campaignsWithCheckBox> campWithCheckBoxList = new List< VFCntrlr_SalesNominationConFromContact.campaignsWithCheckBox>();
        insert campList;
        
        Contact con=[select id,name from contact where FirstName='Test'];
        ApexPages.StandardController SNfrmConController = new ApexPages.StandardController(Con);
        VFCntrlr_SalesNominationConFromContact salesNomFrmCon = new VFCntrlr_SalesNominationConFromContact(SNfrmConController);
        salesNomFrmCon.getcampListToBeDisplayed();
        for(integer i=0;i<10;i++){
            salesNomFrmCon.campListToBeDisplayed[i].isSelected=true;
        }
        campWithCheckBoxList=salesNomFrmCon.campListToBeDisplayed;
        salesNomFrmCon.Next();
        salesNomFrmCon.getcampListToBeDisplayed();
        //salesNomFrmCon.setcampListToBeDisplayed(salesNomFrmCon.campListToBeDisplayed);
        salesNomFrmCon.Previous();
        salesNomFrmCon.getcampListToBeDisplayed();
        salesNomFrmCon.saveNomination();
        
        List<CampaignMember> campMemList = [select id,contactId,Camp_Vehicle__c,campaignId,CM_Status__c from campaignMember 
                                    where campaignId=:campWithCheckBoxList[0].camp.id and contactId=:Con.id];
                                    
        System.assertequals(campMemList[0].CM_Status__c,'Nominated');
        //anamika - replaced Campaign_Vehicle__c with Camp_Vehicle__c [12/6/2013]
        System.assertequals(campMemList[0].Camp_Vehicle__c,'DM');
        System.assertequals(campMemList.size(),1);
    }
    
   public static testMethod void VFCntrlr_SalesNominationInvalidCase(){
         
        List<campaign> campList=createCampaign();
        insert campList;
        //Anamika [6/12/2013]
        Account testAccount  = new Account(Name='Test Account1');
        insert testAccount;
        
        /*Contact con=[select id,name from contact where FirstName='Test'];
        con.status__c='Invalid-Bad Phone';
        update con;*/
       Contact con= new Contact(AccountId=testAccount.Id,
                                    Email='testContact@dell.com',
                                    FirstName = 'Test1', 
                                    LastName = 'Contact1',
                                    Title='VP',
                                    MailingStreet='1234 Main',
                                    MailingCity='Peoria',
                                    MailingState='IL',
                                    MailingPostalCode='333333',
                                    Phone='32132313211',
                                    MobilePhone='32133213211',
                                    Status__c='Invalid-Bad Phone',
                                    Fax='32133123211',
                                    Partner_My_Account_GUID__c='3556');
        insert con;     //end Anamika                      
        ApexPages.StandardController SNfrmConController = new ApexPages.StandardController(Con);
        VFCntrlr_SalesNominationConFromContact salesNomFrmCon = new VFCntrlr_SalesNominationConFromContact(SNfrmConController);
        System.assertEquals(salesNomFrmCon.errorMsgForConStatus,'The contact cannot be nominated as its status is invalid');     
    }
    public static List<campaign> createCampaign(){
        List<campaign> campList = new List<campaign>();
        Account testAccount  = new Account(Name='Test Account');
        insert testAccount;
        Contact testContact = new Contact(AccountId=testAccount.Id,
                                    Email='testCon@dell.com',
                                    FirstName = 'Test', 
                                    LastName = 'Contact',
                                    Title='VP',
                                    MailingStreet='123 Main',
                                    MailingCity='Peoria',
                                    MailingState='IL',
                                    MailingPostalCode='33333',
                                    Phone='3213213211',
                                    MobilePhone='3213213211',
                                    Fax='3213123211',
                                    Partner_My_Account_GUID__c='3456');
        insert testContact;
                 
        for(integer i=0;i<15;i++){
            Campaign testCampaign = new Campaign(Name='Test Campaign'+i,
                                        Campaign_Objective__c = 'LOB Conversion',
                                        Type='DM',
                                        //Added for 14.10 Changes
                                        Campaign_Vehicle__c ='DM',
                                        Segment_Business_Unit__c='PUB',
                                        //Region__c='ABU',
                                        StartDate=System.Today() - 10,
                                        EndDate=System.Today(),
                                        Description='This is Test Campaign'+i,                                            
                                        Account_Play_Expiry_Date__c=System.today() + 60,
                                        Nomination_close_Date__c=System.today() + 60,
                                        allow_nomination__c=true,
                                        Is_this_Account_Play_Campaign__c=false,
                                        IsActive=true);

            campList.add(testCampaign);   
        }        
        return campList;       
     }
}