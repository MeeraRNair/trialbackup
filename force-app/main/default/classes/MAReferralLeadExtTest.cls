public class MAReferralLeadExtTest {

    private static testmethod void doCreateAccount(){
        String accountName  = '';
        String accountId    = '';String accountId_temp    = '';
        String recordTypeID = '';
        
        Map<String, String> sParams;

        //Create Account
        sParams = new Map<String, String>();
        sParams.put('str_name', 'Test Account');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();    
        
        accountId = testAcc.id;
        
        //Create contact
         List<Contact> contactList=new List<Contact>();
         
            for(integer count=0;count<5;count++){
                Contact newContact=new Contact(Status__c='Active', AccountId=testAcc.Id, 
                                    EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                    firstname='Test'+count,MobilePhone='111-1000', Decision_Making_Role__c='Influencer', LastName='TestContact0367', MailingPostalCode='12345');
                contactList.add(newContact);
            }
         
         insert contactList;

        ApexPages.currentPage().getParameters().put('accountid', accountId_temp);
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testAcc);
        MAReferralLeadExt MAExt = new MAReferralLeadExt(controller);
        
        TestUtils.assertErrorMessagesExist();
        controller = null;MAExt=null;
        
        
        accountId = testAcc.id;
        //ApexPages.currentPage().getParameters().put('accountid', accountId);
        //accountId = ApexPages.currentPage().getParameters().get('accountId');
        
        ApexPages.currentPage().getParameters().put('accountid', accountId);
        
        //ApexPages.currentPage().getParameters().put('RecordType', PageUtils.getRecordTypeId('Referral_Lead__c', 'Secureworks Lead', true));
        ApexPages.currentPage().getParameters().put('RecordType', PageUtils.getRecordTypeId('Referral_Lead__c', 'Boomi Lead', true));   
                   
        controller = new ApexPages.StandardController(testAcc);     
        MAExt = new MAReferralLeadExt(controller);
        //MAExt.accountId = accountId;
        
        PageReference pgSearch = MAExt.doPageLoad();
        System.debug('accountName from ext1=='+MaExt.accountName);
        System.debug('accountId from ext1=='+MaExt.accountId);
        System.assertEquals(false,MAExt.getShowErrorMsg());
        System.assertEquals(true,MAExt.getShowCreateButton());
        
        //test Pagination       
         BoomiContactPaginationCtrlExt PaginatorCtrl = new BoomiContactPaginationCtrlExt();
         List<Contact> contactPaginationList         = new List<Contact>(); 
         SObjectPaginator contactPaginator = new SObjectPaginator();
         
       // MaExt.accountId = '';
        // MAExt.recordTypeId = '';
         
         System.debug('###doQueryContactSearch().size() :  ' + MAExt.doQueryContactSearch().size());
         
         System.assertNotEquals(MAExt.doQueryContactSearch().size(),0);
         
         MAExt.accountId = accountId;
         //MAExt.recordTypeId = PageUtils.getRecordTypeId('Referral_Lead__c', 'Secureworks Lead', true);
         MAExt.recordTypeId = PageUtils.getRecordTypeId('Referral_Lead__c', 'Boomi Lead', true);
         
         system.debug('MAExt.accountId=='+MAExt.accountId);
         List<Contact> pageContactList = MAExt.doQueryContactSearch();
         system.debug('pageContactList size=='+pageContactList.size());
                    
         if(pageContactList.size()>0){          
            accountName = pageContactList[0].Account.name;
            contactPaginator                            = PaginatorCtrl.getContactPaginator(pageContactList);           
            contactPaginationList                       = PaginatorCtrl.contacts;
            System.debug('Account id='+ pageContactList[0].Account.id + ' with size='+ pageContactList.size());
        }
            
        System.debug('accountName=='+accountName);
        System.debug('accountName from ext2=='+MaExt.accountName);
        
        system.assertEquals(contactPaginationList.size(),5);
        
        //recordTypeId = PageUtils.getRecordTypeId('Referral_Lead__c', 'Secureworks Lead', true);
        recordTypeId = PageUtils.getRecordTypeId('Referral_Lead__c', 'Boomi Lead', true);
        
        
        //test create contact
        PageReference newContactView = new PageReference('/003/e?con4_lkid=' + accountId + '&CF00NA00000064sQh=' + PageUtils.encodeVariable(UserInfo.getName()) +  ('&saveURL=/apex/MAContactSearch?accountName='+PageUtils.encodeVariable(accountName+ '&accountId='+ accountId + '&RecordType='+ recordTypeID +'&created=true')) + ('&retURL=/apex/MAContactSearch?accountName='+PageUtils.encodeVariable(accountName + '&accountId='+ accountId  + '&RecordType=' + recordTypeID)  ));
    
        system.debug('newContactView URL='+newContactView.getUrl());
        system.debug('doCreateContact URL='+MAExt.doCreateContact().getUrl());
        
        system.assertEquals(newContactView.getUrl(), MAExt.doCreateContact().getUrl());
        
        PageReference pgCancel = new PageReference('/'+testAcc.id); 
        system.assertEquals(pgCancel.getUrl(), MAExt.doCancel().getUrl());
        
        List<Contact> listReturnContact = MAExt.contactList;
        Account objReturnAccount = MAExt.account;
        
    }


    private static testmethod void doSelectContact(){
        
        String accountName  = '';
        String accountId    = '';
        String recordTypeID = '';
        String created      = 'true';
        String sObjectPrefix                = Referral_lead__c.sObjectType.getDescribe().getKeyPrefix();
        
        Map<String, String> sParams;

        //Create Account
        sParams = new Map<String, String>();
        sParams.put('str_name', 'Test Account');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();    
        
        accountId = testAcc.id;
        
        //Create contact
         List<Contact> contactList=new List<Contact>();
         
            for(integer count=0;count<5;count++){
                Contact newContact=new Contact(Status__c='Active', AccountId=testAcc.Id, 
                                    EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                    firstname='Test'+count,MobilePhone='111-1000', Decision_Making_Role__c='Influencer', LastName='TestContact0367', MailingPostalCode='12345');
                contactList.add(newContact);
            }
         
         insert contactList;

        
        String contactID = contactList[0].id;
        String contactFirstName = contactList[0].firstname;
        String contactLastName = contactList[0].lastname;
        String contactMailingPostalCode=contactList[0].MailingPostalCode;
        List<Contact> contactNameList = [SELECT name from Contact WHERE id=:contactID AND firstname=:contactFirstName AND lastname=:contactLastName AND MailingPostalCode =:contactMailingPostalCode limit 1];
        String contactName = contactNameList[0].name;
        
        
        
        ApexPages.currentPage().getParameters().put('accountid', accountId);
        ApexPages.currentPage().getParameters().put('linkcontactID', contactID);    
        ApexPages.currentPage().getParameters().put('linkcontactName',contactName );
        ApexPages.currentPage().getParameters().put('linkcontactMailingPostalCode',contactMailingPostalCode);
        
        
        //recordTypeID = PageUtils.getRecordTypeId('Referral_Lead__c', 'Secureworks Lead', true);
        recordTypeID = PageUtils.getRecordTypeId('Referral_Lead__c', 'Boomi Lead', true);
        ApexPages.StandardController controller = new ApexPages.StandardController(testAcc);
        MAReferralLeadExt MAExt = new MAReferralLeadExt(controller);
        
        System.assertNotEquals(ApexPages.currentPage().getParameters().get('linkcontactID'),null);
        System.assertNotEquals(ApexPages.currentPage().getParameters().get('linkcontactName'),null);
        System.assertNotEquals(ApexPages.currentPage().getParameters().get('linkcontactMailingPostalCode'),null);
         
                
        //String urlStr = '/'+ sObjectPrefix +'/e' + '?CF00NA00000063PC4_lkid=' + PageUtils.encodeVariable(contactID) +'&CF00NA00000063PC4=' + PageUtils.encodeVariable(contactName) +'&CF00NA00000063PBw=' + PageUtils.encodeVariable(accountName) + '&CF00NA00000063PBw_lkid='+ PageUtils.encodeVariable(accountId) +'&RecordType='+ PageUtils.encodeVariable(recordTypeID)+ '&nooverride=1' +'&retURL=/apex/MAContactSearch?accountName='+PageUtils.encodeVariable(accountName+ '&accountId='+ accountId + '&RecordType='+ recordTypeID +(StringUtils.isNotBlank(created) && StringUtils.containsIgnoreCase('true', created)? '&created=true':''));
        String urlStr = '/'+ sObjectPrefix +'/e' + '?CF00NA00000063PC4_lkid=' + PageUtils.encodeVariable(contactID) +'&CF00NA00000063PC4=' + PageUtils.encodeVariable(contactName) + '&00NA00000063Ubn='+ PageUtils.encodeVariable(contactMailingPostalCode) +'&CF00NA00000063PBw=' + PageUtils.encodeVariable(accountName) + '&CF00NA00000063PBw_lkid='+ PageUtils.encodeVariable(accountId) +'&RecordType='+ PageUtils.encodeVariable(recordTypeID)+ '&nooverride=1' +'&retURL=/apex/MAContactSearch?accountName='+PageUtils.encodeVariable(accountName+ '&accountId='+ accountId + '&RecordType='+ recordTypeID +(StringUtils.isNotBlank(created) && StringUtils.containsIgnoreCase('true', created)? '&created=true':''));
        
        
        //String urlStrForSecureWork = '';
         //if(StringUtils.equalsIgnoreCase(recordTypeID, PageUtils.getRecordTypeId('Referral_Lead__c', 'Secureworks Lead', true))){
            String acctExecName = ''; String ISRName = '';
            List<Account> dbAcctList = [SELECT owner.name FROM Account WHERE id=:accountId limit 1];
            System.debug('dbAcctList[0].owner.name='+dbAcctList[0].owner.name);
        
            MAExt.doSelectContact().getUrl();
            //SIT
            //urlStr = '/'+ sObjectPrefix +'/e' + '?CF00NA00000063PC4_lkid=' + PageUtils.encodeVariable(contactID) +'&CF00NA00000063PC4=' + PageUtils.encodeVariable(contactName) + '&00NA00000063Ubn='+ PageUtils.encodeVariable(contactMailingPostalCode) +'&CF00NA00000063PBw=' + PageUtils.encodeVariable(accountName) + '&CF00NA00000063PBw_lkid='+ PageUtils.encodeVariable(accountId)+ '&00NQ0000000jzJk='+ PageUtils.encodeVariable(ISRName) + '&00NQ0000000jzJj='+ PageUtils.encodeVariable(acctExecName) +'&RecordType='+ PageUtils.encodeVariable(recordTypeID)+ '&nooverride=1' +'&retURL=/apex/MAContactSearch?accountName='+PageUtils.encodeVariable(accountName+ '&accountId='+ accountId + '&RecordType='+ recordTypeID +(StringUtils.isNotBlank(created) && StringUtils.containsIgnoreCase('true', created)? '&created=true':''));
            
            //PROD
            urlStr = '/'+ sObjectPrefix +'/e' + '?CF00NA00000063PC4_lkid=' + PageUtils.encodeVariable(contactID) +'&CF00NA00000063PC4=' + PageUtils.encodeVariable(contactName) + '&00NA00000063Ubn='+ PageUtils.encodeVariable(contactMailingPostalCode) +'&CF00NA00000063PBw=' + PageUtils.encodeVariable(accountName) + '&CF00NA00000063PBw_lkid='+ PageUtils.encodeVariable(accountId)+ '&00NA00000063RkE='+ PageUtils.encodeVariable(ISRName) + '&00NA00000063Rk9='+ PageUtils.encodeVariable(acctExecName) +'&RecordType='+ PageUtils.encodeVariable(recordTypeID)+ '&nooverride=1' +'&retURL=/apex/MAContactSearch?accountName='+PageUtils.encodeVariable(accountName+ '&accountId='+ accountId + '&RecordType='+ recordTypeID +(StringUtils.isNotBlank(created) && StringUtils.containsIgnoreCase('true', created)? '&created=true':''));
            
            //SIT
            //urlStrForSecureWork = '/'+ sObjectPrefix +'/e' + '?CF00NA00000063PC4_lkid=' + PageUtils.encodeVariable(contactID) +'&CF00NA00000063PC4=' + PageUtils.encodeVariable(contactName) + '&00NA00000063Ubn='+ PageUtils.encodeVariable(contactMailingPostalCode) +'&CF00NA00000063PBw=' + PageUtils.encodeVariable(accountName) + '&CF00NA00000063PBw_lkid='+ PageUtils.encodeVariable(accountId)+ '&00NQ0000000jzJk='+ PageUtils.encodeVariable(ISRName) + '&00NQ0000000jzJj='+ PageUtils.encodeVariable(acctExecName) +'&RecordType='+ PageUtils.encodeVariable(recordTypeID)+ '&nooverride=1' +'&retURL=/apex/MAContactSearch?accountName='+PageUtils.encodeVariable(accountName+ '&accountId='+ accountId + '&RecordType='+ recordTypeID +(StringUtils.isNotBlank(created) && StringUtils.containsIgnoreCase('true', created)? '&created=true':''));
            
            //PROD
            //urlStrForSecureWork = '/'+ sObjectPrefix +'/e' + '?CF00NA00000063PC4_lkid=' + PageUtils.encodeVariable(contactID) +'&CF00NA00000063PC4=' + PageUtils.encodeVariable(contactName) + '&00NA00000063Ubn='+ PageUtils.encodeVariable(contactMailingPostalCode)+'&CF00NA00000063PBw=' + PageUtils.encodeVariable(accountName) + '&CF00NA00000063PBw_lkid='+ PageUtils.encodeVariable(accountId)+ '&00NA00000063RkE='+ PageUtils.encodeVariable(ISRName) + '&00NA00000063Rk9='+ PageUtils.encodeVariable(acctExecName) +'&RecordType='+ PageUtils.encodeVariable(recordTypeID)+ '&nooverride=1' +'&retURL=/apex/MAContactSearch?accountName='+PageUtils.encodeVariable(accountName+ '&accountId='+ accountId + '&RecordType='+ recordTypeID +(StringUtils.isNotBlank(created) && StringUtils.containsIgnoreCase('true', created)? '&created=true':''));
        // }
        
       /* if(recordTypeID.equalsIgnoreCase(PageUtils.getRecordTypeId('Referral_Lead__c', 'Secureworks Lead', true))){
            system.assertEquals(urlStr,urlStrForSecureWork);
        }else{
            system.assertNotEquals(urlStrForSecureWork,null); */
            //system.assertNotEquals(urlStr,'/'+ sObjectPrefix +'/e' + '?CF00NA00000063PC4_lkid=' + PageUtils.encodeVariable(contactID) +'&CF00NA00000063PC4=' + PageUtils.encodeVariable(contactName) +'&CF00NA00000063PBw=' + PageUtils.encodeVariable(accountName) + '&CF00NA00000063PBw_lkid='+ PageUtils.encodeVariable(accountId) +'&RecordType='+ PageUtils.encodeVariable(recordTypeID)+ '&nooverride=1' +'&retURL=/apex/MAContactSearch?accountName='+PageUtils.encodeVariable(accountName+ '&accountId='+ accountId + '&RecordType='+ recordTypeID +(StringUtils.isNotBlank(created) && StringUtils.containsIgnoreCase('true', created)? '&created=true':'')));
            system.assertNotEquals(urlStr,'/'+ sObjectPrefix +'/e' + '?CF00NA00000063PC4_lkid=' + PageUtils.encodeVariable(contactID) +'&CF00NA00000063PC4=' + PageUtils.encodeVariable(contactName) + '&00NA00000063Ubn='+ PageUtils.encodeVariable(contactMailingPostalCode) +'&CF00NA00000063PBw=' + PageUtils.encodeVariable(accountName) + '&CF00NA00000063PBw_lkid='+ PageUtils.encodeVariable(accountId) +'&RecordType='+ PageUtils.encodeVariable(recordTypeID)+ '&nooverride=1' +'&retURL=/apex/MAContactSearch?accountName='+PageUtils.encodeVariable(accountName+ '&accountId='+ accountId + '&RecordType='+ recordTypeID +(StringUtils.isNotBlank(created) && StringUtils.containsIgnoreCase('true', created)? '&created=true':'')));           
           
      //  }
        
        
    }
    

/*
    private static testmethod void doSelectContact2(){
        String accountName  = '';
        String accountId    = '';
        String accountId_temp    = '';
        String recordTypeID = '';
        String created      = 'true';
        String sObjectPrefix                = Referral_lead__c.sObjectType.getDescribe().getKeyPrefix();
        
        Map<String, String> sParams;

        //Create Account
        sParams = new Map<String, String>();
        sParams.put('str_name', 'Test Account');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();    
        
        accountId = testAcc.id;
        ApexPages.currentPage().getParameters().put('accountid', accountId_temp);
        
        //Create contact
         List<Contact> contactList=new List<Contact>();
         
            for(integer count=0;count<5;count++){
                Contact newContact=new Contact(Status__c='Active', AccountId=testAcc.Id, 
                                    EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                    firstname='Test'+count,MobilePhone='111-1000', Decision_Making_Role__c='Influencer', LastName='TestContact0367');
                contactList.add(newContact);
            }
         
         insert contactList;

        String contactID = contactList[0].id;
        String contactName = contactList[0].name;   
    
    }
*/  
}