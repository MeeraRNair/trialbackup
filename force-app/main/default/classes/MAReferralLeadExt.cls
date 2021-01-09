/*------------------------------------------------------------------------
Name          : MAReferralLeadExt
Description   : Controller for MAContactSearch
--------------------------------------------------------------------------
Revision  Developer          Date        Description

1.0       Krishnamoorthi     23.05.2011  CR6059 - Removed the filter in the code which restricts displaying the contacts that are already tied to a referral lead 
2.0       Krishnamoorthi     26.05.2011  CR6070 - To populate the corresponding 'Zip/Postal Code' from Contact to Referral Lead page 
3.0       Jessie             14.03.2016  CR12724 - To route to standard Create Contact page instead of Custom Contact Duplication Check VF (/apex/contactDupeChecker) 
4.0       Kokila             27.09.2016  CR13528 - To Remove references of SecureWorks 
5.0       Sakshi             04.06.2018  Reduce code
--------------------------------------------------------------------------*/
public class MAReferralLeadExt {

    public String accountId                     {get;set;}
    public String accountName                   {get;set;}
    public String created                       {get;set;}
    public String newid                         {get;set;}
    public String recordTypeID                  {get;set;}
            
    public SObjectPaginator contactPaginator    {get;set;}
    public List<Contact> contactList            {get;set;}
    public List<Contact> contactPaginationList  {get;set;}
    public Account account                      {get;set;}
    
    public Boolean getShowErrorMsg()            {return StringUtils.isBlank(accountId);}
    public Boolean getShowCreateButton()        {return ((StringUtils.isBlank(created))&& !(StringUtils.equalsIgnoreCase(created,'true')));}    
    
    public MAReferralLeadExt(ApexPages.Standardcontroller c){
        //required to change id for accountID
       accountId = ApexPages.currentPage().getParameters().get('accountId');
       
       if(StringUtils.isBlank(ApexPages.currentPage().getParameters().get('accountId'))){
             accountId = ApexPages.currentPage().getParameters().get('CF00NA00000063PBw_lkid');
        }       
        recordTypeID = ApexPages.currentPage().getParameters().get('RecordType');
        created      = ApexPages.currentPage().getParameters().get('created');
        newid        = ApexPages.currentPage().getParameters().get('newid');
      
        if(StringUtils.isBlank(accountId)){
            PageUtils.addError(System.Label.Boomi_NoAccount_Error);                                              
            return;
         }
             
    }
    
    public PageReference doPageLoad(){      
        doSearch();
        return null;
    }
    
    
    public PageReference doSearch(){
        BoomiContactPaginationCtrlExt PaginatorCtrl = new BoomiContactPaginationCtrlExt();
        
        List<Contact> contactList = doQueryContactSearch();
        
        if(contactList.size()>0){
            accountName = contactList.get(0).Account.name;
        }                    
                   
        contactPaginator                            = PaginatorCtrl.getContactPaginator(contactList);           
        contactPaginationList                       = PaginatorCtrl.contacts;
              
        return null;
    }
    
    public List<Contact> doQueryContactSearch(){
                
        String soql = 'SELECT id, Phone, MobilePhone ,Name, Email,Account.name,MailingPostalCode FROM Contact WHERE accountId =:accountId ORDER BY ' + (StringUtils.isNotBlank(created) && StringUtils.containsIgnoreCase('true', created)? ' CreatedDate DESC ':' name ' ) + ' LIMIT 1000 ';
                     
        List<Contact> searchContactList = Database.query(soql);
          
        return searchContactList;
    } 
    
    public Pagereference doCreateContact(){
        
        //v3.0 - start
        //Route to standard Create Contact page
        PageReference newContactView = new PageReference('/003/e?con4_lkid=' + accountId + '&CF00NA00000064sQh=' + PageUtils.encodeVariable(UserInfo.getName()) +  ('&saveURL=/apex/MAContactSearch?accountName='+PageUtils.encodeVariable(accountName+ '&accountId='+ accountId + '&RecordType='+ recordTypeID +'&created=true')) + ('&retURL=/apex/MAContactSearch?accountName='+PageUtils.encodeVariable(accountName + '&accountId='+ accountId  + '&RecordType=' + recordTypeID)  ));                      
        //v3.0 - end 
        
        return newContactView;
    }
    
    public PageReference doSelectContact(){
        String contactID = ApexPages.currentPage().getParameters().get('linkcontactID');    
        String contactName = ApexPages.currentPage().getParameters().get('linkcontactName');
        String MailingPostalCode = ApexPages.currentPage().getParameters().get('linkcontactMailingPostalCode');
                        
       //Rev 2.0 - Added 'MailingPostalCode' in the String urlStr
        //String urlStr = '/'+ PageUtils.getSObjectPath('Referral_lead__c') +'/e' + '?CF00NT0000001Km7f_lkid=' + PageUtils.encodeVariable(contactID) +'&CF00NT0000001Km7f=' + PageUtils.encodeVariable(contactName) +'&CF00NT0000001KlqU=' + PageUtils.encodeVariable(accountName) + '&CF00NT0000001KlqU_lkid='+ PageUtils.encodeVariable(accountId) +'&RecordType='+ PageUtils.encodeVariable(recordTypeID)+ '&nooverride=1' +'&retURL=/apex/MAContactSearch?accountName='+PageUtils.encodeVariable(accountName+ '&accountId='+ accountId + '&RecordType='+ recordTypeID +(StringUtils.isNotBlank(created) && StringUtils.containsIgnoreCase('true', created)? '&created=true':''));     
        String urlStr = '/'+ PageUtils.getSObjectPath('Referral_lead__c') +'/e' + '?CF00NA00000063PC4_lkid=' + PageUtils.encodeVariable(contactID) +'&CF00NA00000063PC4=' + PageUtils.encodeVariable(contactName) 
                        + (!StringUtils.isBlank(MailingPostalCode) ?  '&00NA00000063Ubn='+ PageUtils.encodeVariable(MailingPostalCode) : '')  + '&CF00NA00000063PBw=' + PageUtils.encodeVariable(accountName) + '&CF00NA00000063PBw_lkid='+ PageUtils.encodeVariable(accountId) +'&RecordType='+ PageUtils.encodeVariable(recordTypeID)+ '&nooverride=1' +'&retURL=/apex/MAContactSearch?accountName='+PageUtils.encodeVariable(accountName+ '&accountId='+ accountId + '&RecordType='+ recordTypeID +(StringUtils.isNotBlank(created) && StringUtils.containsIgnoreCase('true', created)? '&created=true':''));     

        //End v4.0 - Commenting the references of SecureWorks
        PageReference referralLeadPage = new PageReference(urlStr);
        return referralLeadPage;
    }
    
    public PageReference doCancel(){        
        return PageUtils.redirect('/' + accountId);
    }
    
}