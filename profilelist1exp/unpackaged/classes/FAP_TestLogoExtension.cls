@IsTest
private with sharing class FAP_TestLogoExtension {
    private static Blob generateRandomBlob(){
        return EncodingUtil.base64Decode(''+System.currentTimeMillis()+Math.roundToLong(Math.random()*10000));  
    }

  private static testmethod void testInvalidPageFlow1(){
    Account testAccount = new Account(name='test123');
    FAP_LogoExtension controller = new FAP_LogoExtension(new ApexPages.StandardController(testAccount));
    System.assertEquals(null,controller.doOnLoad());
    System.assertEquals(FAP_LogoExtension.strinvalidPageFlow,controller.strerror);
    System.assertEquals(true,controller.strerrorOccurred);
  }

  private static testmethod void testInvalidPageFlow2(){
    Logo__c logo = new Logo__c();
    Account testAccount = new Account(name='test123');
    insert testAccount;  
    FAP_PageUtils.put('accountId',testAccount.id + 'xyz');
    FAP_LogoExtension controller = new FAP_LogoExtension(new ApexPages.StandardController(logo));
    System.assertEquals(null,controller.doOnLoad());
    System.assertEquals(FAP_LogoExtension.strinvalidPageFlow,controller.strerror);
    System.assertEquals(true,controller.strerrorOccurred);
  }

  private static testmethod void testEditLogo(){
    Logo__c logo = new Logo__c();
    logo.name = 'test.txt';
    insert logo; 
    Attachment attach = new Attachment(
      Body=generateRandomBlob(),
      ContentType='txt',
      IsPrivate=false,
      Name='test.txt',
      ParentID=logo.id);
    insert attach;
    Account testAccount = new Account(name='test123',logo__c = logo.id);
    insert testAccount;  
    
    FAP_LogoExtension controller = new FAP_LogoExtension(new ApexPages.StandardController(logo));
    System.assertEquals(null,controller.doOnLoad());
    System.assertEquals(null,controller.strerror);
    System.assertEquals(false,controller.strerrorOccurred);
    System.assertNotEquals(null,controller.account);
    System.assertEquals(testAccount.id,controller.account.id);
    System.assertNotEquals(null,controller.logoRecord);
    System.assertEquals(logo.id,controller.logoRecord.id);
    System.assertNotEquals(null,controller.logoAttachment);
    System.assertEquals(attach.id,controller.logoAttachment.id);

    final Blob newBlob = generateRandomBlob();
    final String newFilename = 'test123.txt';
    controller.strattachmentContentType = 'txt';
    controller.strattachmentFileName = newFilename;
    controller.blbattachmentFile = newBlob;
    System.assertEquals(null,controller.doReplaceLogo());

    attach = [select body,name from Attachment where parentid = :logo.id];
    System.assertEquals(newFilename,attach.name);
    //ssSystem.assertEquals(newBlob.toString(),attach.body.toString());
  }

  private static testmethod void testCreatePartnerTrackLogo(){
    FAP_Configuration.keyValue = 'Account__r.';
    Logo__c logo = new Logo__c();
    Account testAccount = new Account(name='test123');
    insert testAccount;  
    FAP_PageUtils.put('accountId',testAccount.id);
    FAP_LogoExtension controller = new FAP_LogoExtension(new ApexPages.StandardController(logo));
    System.assertEquals(null,controller.doOnLoad());
    System.assertEquals(null,controller.strerror);
    System.assertEquals(false,controller.strerrorOccurred);
    System.assertNotEquals(null,controller.account);
    System.assertEquals(testAccount.id,controller.account.id);
    System.assertEquals(logo,controller.logoRecord);
    System.assertEquals(null,controller.logoAttachment);

    final Blob newBlob = generateRandomBlob();
    final String newFilename = 'test123.txt';
    controller.strattachmentContentType = 'txt';
    controller.strattachmentFileName = newFilename;
    controller.blbattachmentFile = newBlob;
    System.assertEquals(null,controller.doReplaceLogo());     
      
    Attachment attach = [select body,name from Attachment where parentid = :logo.id];
    System.assertEquals(newFilename,attach.name);
   // System.assertEquals(newBlob.toString(),attach.body.toString());
  }
  
  private static testmethod void testCreateLogo(){
    FAP_Configuration.keyValue = 'Partner_Track__r.';
    Logo__c logo = new Logo__c();
    Partner_Track__c testAccount = new Partner_Track__c(Partner_Track_Account_Local_Name__c='test123', logo__c=logo.id);
    insert testAccount;  
    FAP_PageUtils.put('accountId',testAccount.id);
    FAP_LogoExtension controller = new FAP_LogoExtension(new ApexPages.StandardController(logo));
    controller.doOnLoad();
 
    final Blob newBlob = generateRandomBlob();
    final String newFilename = 'test123.txt';
    controller.strattachmentContentType = 'txt';
    controller.strattachmentFileName = newFilename;
    controller.blbattachmentFile = newBlob;
    controller.doReplaceLogo();     
      
  }
  
  
   private static testmethod void testEditPartnerTrackLogo(){
    FAP_Configuration.keyValue = 'Partner_Track__r.';
 
    Logo__c logo = new Logo__c();
    logo.name = 'test.txt';
    insert logo; 
    Attachment attach1 = new Attachment(
      Body=generateRandomBlob(),
      ContentType='txt',
      IsPrivate=false,
      Name='test.txt',
      ParentID=logo.id);
    insert attach1;
    Partner_Track__c testAccount = new Partner_Track__c(Partner_Track_Account_Local_Name__c='test123', logo__c=logo.id);
    insert testAccount;  
    FAP_PageUtils.put('accountId',testAccount.id);
    FAP_LogoExtension controller = new FAP_LogoExtension(new ApexPages.StandardController(logo));
    controller.doOnLoad();
    //controller.strerror;
    //controller.strerrorOccurred;
    //controller.partnerTrack;
    
    final Blob newBlob = generateRandomBlob();
    final String newFilename = 'test123.txt';
    controller.strattachmentContentType = 'txt';
    controller.strattachmentFileName = newFilename;
    controller.blbattachmentFile = newBlob;
    
    controller.doReplaceLogo();     
      
    Attachment attach = [select body,name from Attachment where parentid = :logo.id];
    //System.assertEquals(newFilename,attach.name);
    controller.doreturn();
    controller.docancel();
  }


  private static testmethod void testCreateLogoWithOrphanedLogo(){
    Logo__c logo = new Logo__c();
    logo.name = 'test.txt';
    Logo__c logo2 = new Logo__c();
    logo2.name = 'test2.txt';
    insert logo2; 
    Account testAccount = new Account(name='test123',logo__c = logo2.id);
    insert testAccount;  
    FAP_PageUtils.put('accountId',testAccount.id);
    FAP_LogoExtension controller = new FAP_LogoExtension(new ApexPages.StandardController(logo));
    PageReference next = controller.doOnLoad();
    System.assertNotEquals(null,next);
    
               
    
  }
 private static testmethod void testPreviewLogoFromPartnerPageLayoutEx(){
   Partner_Track__c pt=new Partner_Track__c();
        pt.Approved_for_Partner_Finder__c=true;
        pt.Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now();
        pt.User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId();
        pt.Partner_Program_Tier__c='Gold';
        insert pt;
        pt.Partner_Account__c = true;       
        update pt;
         ApexPages.StandardController sc2 = new ApexPages.standardController(pt);
        FAP_PreviewLogoFromAccountPageLayoutExt plogocontroller = new FAP_PreviewLogoFromAccountPageLayoutExt(sc2);
        plogocontroller.doOnLoad();
        System.assertEquals(plogocontroller.errorOccurred,true);
        
        Account ac=new Account(Name='Test123');
        ac.Approved_for_Partner_Finder__c=true;
        ac.Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now();
        ac.Partner_User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId();
        insert ac;
        update ac;
         ApexPages.StandardController sc = new ApexPages.standardController(ac);
        FAP_PreviewLogoFromAccountPageLayoutExt plogocontroller1 = new FAP_PreviewLogoFromAccountPageLayoutExt(sc);
        plogocontroller1.doOnLoad();
        System.assertEquals(plogocontroller1.errorOccurred,true);
        
  }
  private static testmethod void testPreviewLogoFromAccountPageLayoutEx(){

                Logo__c logo = new Logo__c();
        logo.name = 'test.txt';
        insert logo; 
        Attachment attach = new Attachment(
          Body=generateRandomBlob(),
          ContentType='txt',
          IsPrivate=false,
          Name='test.txt',
          ParentID=logo.id);
          
        Partner_Track__c pt=new Partner_Track__c();
        pt.Approved_for_Partner_Finder__c=true;
        pt.Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now();
        pt.User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId();
        pt.logo__c = logo.Id;
        pt.Partner_Program_Tier__c='Gold';
        insert pt;
        pt.Partner_Account__c = true;       
        update pt;
         ApexPages.StandardController sc2 = new ApexPages.standardController(pt);
        FAP_PreviewLogoFromAccountPageLayoutExt plogocontroller = new FAP_PreviewLogoFromAccountPageLayoutExt(sc2);
        plogocontroller.doOnLoad();
        System.assertEquals(plogocontroller.errorOccurred,true);
        
  }
}