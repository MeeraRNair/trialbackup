public class VFCntrlr_Add_Billing_Contact {
    
    public Marketing_Plan__c MPlan {get; set;}
    List <MDF_Associated_Contact__c> billingContactList = new List <MDF_Associated_Contact__c>{};
    public boolean new_contact_info_rendered {get; set;}
    public boolean contact_table_rendered {get; set;}
    public String billingcontactId {get; set;}
    MDF_Associated_Contact__c tempBillingContact = new MDF_Associated_Contact__c();
    public RecordType mdfContactRT = [Select Id,Name from RecordType where sObjectType ='MDF_Contact__c'and isActive=true and Name ='Partner Contact'];
    public Marketing_Plan__c mktgplan{get;set;}
    public Profile profileName;
    Country__c tempCountry;
            
    
    public VFCntrlr_Add_Billing_Contact(ApexPages.StandardController controller) {
        
        this.MPlan = (Marketing_Plan__c)controller.getRecord();
        mktgplan = [select Id,Vendor__c,Contract_Type__c,Billing_Contact_Name__c,Billing_Contact_Country__c,Billing_Contact_Email__c,Billing_Contact_Phone__c,Bill_To_Address__c,Billing_Cell__c,Billing_City__c,Billing_Contact_Title__c,Billing_State__c,Billing_Zip__c,Billing_Fax__c from Marketing_Plan__c where Id=:MPlan.Id];
        billingContactList = [Select Id,Name,MDF_Contact__c,MDF_Contact__r.Name,MDF_Contact__r.Phone__c,MDF_Contact__r.Email__c,MDF_Contact__r.Country__c,MDF_Contact__r.Partner_Contact_Type__c,MDF_Contact__r.Address__c,MDF_Contact__r.Mobile_Phone__c,MDF_Contact__r.City_Town__c,MDF_Contact__r.State_Province__c,MDF_Contact__r.Title__c,
        MDF_Contact__r.Zip_Postal_Code__c,
        MDF_Contact__r.Fax__c  from MDF_Associated_Contact__c where Vendor__c=:mktgplan.Vendor__c and MDF_Contact__r.RecordTypeId =:mdfContactRT.Id and MDF_Contact__r.Partner_Contact_Type__c IN ('Billing','Headcount-Billing')];
        
        contact_table_rendered = true;
        if(billingContactList.size()==0){
            contact_table_rendered = false;
        }
        
        new_contact_info_rendered = false;
        
        Id profileId=UserInfo.getProfileId();
        profileName = [select Id,Name from Profile where Id=:profileId];
        
    }
    
    public List <MDF_Associated_Contact__c> getBillingContactList(){
        return billingContactList;
    }
    
    Public PageReference select_action(){
        if(billingcontactId != null){
            tempBillingContact = [Select Id,Name,MDF_Contact__c,MDF_Contact__r.Name,MDF_Contact__r.Phone__c,MDF_Contact__r.Email__c,MDF_Contact__r.Country__c,MDF_Contact__r.Partner_Contact_Type__c,MDF_Contact__r.Address__c,MDF_Contact__r.Mobile_Phone__c,MDF_Contact__r.City_Town__c,MDF_Contact__r.State_Province__c,MDF_Contact__r.Title__c,
            MDF_Contact__r.Zip_Postal_Code__c, MDF_Contact__r.Partner_Contact_Country__c,
            MDF_Contact__r.Fax__c from MDF_Associated_Contact__c where Id=:billingcontactId];
        }
        if(tempBillingContact != null){
            if(tempBillingContact.MDF_Contact__r.Partner_Contact_Country__c != null){
                tempCountry = [Select Id, Name from Country__c where Id=:tempBillingContact.MDF_Contact__r.Partner_Contact_Country__c];
            }
            new_contact_info_rendered = true;
            MPlan.Billing_Contact_Name__c= tempBillingContact.MDF_Contact__r.Name;
            //MPlan.Billing_Contact_Country__c = tempBillingContact.MDF_Contact__r.Country__c;
            if(tempCountry != null){
                MPlan.Billing_Contact_Country__c = tempCountry.Name;
            }
            MPlan.Billing_Contact_Email__c = tempBillingContact.MDF_Contact__r.Email__c;
            MPlan.Billing_Contact_Phone__c = tempBillingContact.MDF_Contact__r.Phone__c;
            MPlan.Bill_To_Address__c = tempBillingContact.MDF_Contact__r.Address__c;
            MPlan.Billing_Cell__c = tempBillingContact.MDF_Contact__r.Mobile_Phone__c;
            MPlan.Billing_City__c = tempBillingContact.MDF_Contact__r.City_Town__c;
            MPlan.Billing_Contact_Title__c = tempBillingContact.MDF_Contact__r.Title__c;
            MPlan.Billing_State__c = tempBillingContact.MDF_Contact__r.State_Province__c;
            MPlan.Billing_Zip__c = tempBillingContact.MDF_Contact__r.Zip_Postal_Code__c;
            MPlan.Billing_Fax__c = tempBillingContact.MDF_Contact__r.Fax__c;
        }
        
        /*update MPlan;
        
        //Marketing_Plan__c myupdatedplan = [Select Id,Contract_Type__c from Marketing_Plan__c where Id=:MPlan.Id];
        
        if(mktgplan.Contract_Type__c=='Volume Based'){
            String urlString = '/apex/CustomerPortal_MarketingPlan?id='+mktgplan.Id;
            return new PageReference(urlString);
        }
        else if(mktgplan.Contract_Type__c=='Rebates'){
            String urlString = '/apex/CustomerPortal_MarketingPlan_Rebates?id='+mktgplan.Id;
            return new PageReference(urlString);
        }
        else if(mktgplan.Contract_Type__c=='Headcount'){
            String urlString = '/apex/CustomerPortal_MarketingPlan_Headcount?id='+mktgplan.Id;
            return new PageReference(urlString);
        }
        else if(mktgplan.Contract_Type__c=='Ala Carte'){
            String urlString = '/apex/CustomerPortal_MarketingPlan_AlaCarte?id='+mktgplan.Id;
            return new PageReference(urlString);
        }
        else*/ return null;
    }

    public PageReference new_contact_info_action(){
        MPlan.Billing_Contact_Name__c= '';
        MPlan.Billing_Contact_Country__c = '';
        MPlan.Billing_Contact_Email__c = '';
        MPlan.Billing_Contact_Phone__c = '';
        MPlan.Bill_To_Address__c = '';
        MPlan.Billing_Cell__c = '';
        MPlan.Billing_City__c = '';
        MPlan.Billing_Contact_Title__c = '';
        MPlan.Billing_State__c = '';
        MPlan.Billing_Zip__c = '';
        MPlan.Billing_Fax__c = '';
        new_contact_info_rendered = true;
        return null;
    }
    
     public PageReference edit_contact_info_action(){
        
        MPlan.Billing_Contact_Name__c= mktgplan.Billing_Contact_Name__c;
        MPlan.Billing_Contact_Country__c = mktgplan.Billing_Contact_Country__c;
        MPlan.Billing_Contact_Email__c = mktgplan.Billing_Contact_Email__c;
        MPlan.Billing_Contact_Phone__c = mktgplan.Billing_Contact_Phone__c;
        MPlan.Bill_To_Address__c = mktgplan.Bill_To_Address__c;
        MPlan.Billing_Cell__c = mktgplan.Billing_Cell__c;
        MPlan.Billing_City__c = mktgplan.Billing_City__c;
        MPlan.Billing_Contact_Title__c = mktgplan.Billing_Contact_Title__c;
        MPlan.Billing_State__c = mktgplan.Billing_State__c;
        MPlan.Billing_Zip__c = mktgplan.Billing_Zip__c;
        MPlan.Billing_Fax__c = mktgplan.Billing_Fax__c;
         new_contact_info_rendered = true;
        return null;
    }
    
    public PageReference savenewInfo(){
        
        //update MPlan;
        //Marketing_Plan__c myupdatedplan = [Select Id,Contract_Type__c from Marketing_Plan__c where Id=:MPlan.Id];
        /*&if(MPlan.Billing_Contact_Phone__c==null && MPlan.Billing_Cell__c==null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter either Phone or Cell Number'));
            return null;    
        }*/
        Database.SaveResult sr_Update = Database.update(MPlan,false);
        if(sr_Update.isSuccess()){
            
                    
            if(profileName.Name=='High Volume Customer Portal User'){
                if(mktgplan.Contract_Type__c=='Volume Based'){
                    String urlString = '/apex/CustomerPortal_MarketingPlan?id='+mktgplan.Id;
                    return new PageReference(urlString);
                }
                else if(mktgplan.Contract_Type__c=='Rebates'){
                    String urlString = '/apex/CustomerPortal_MarketingPlan_Rebates?id='+mktgplan.Id;
                    return new PageReference(urlString);
                }
                else if(mktgplan.Contract_Type__c=='Headcount'){
                    String urlString = '/apex/CustomerPortal_MarketingPlan_Headcount?id='+mktgplan.Id;
                    return new PageReference(urlString);
                }
                else if(mktgplan.Contract_Type__c=='Ala Carte'){
                    String urlString = '/apex/CustomerPortal_MarketingPlan_AlaCarte?id='+mktgplan.Id;
                    return new PageReference(urlString);
                }
                else return null;
            }
            else{
                
                return new PageReference('/'+MPlan.Id);
            }
        }
        else{
            Database.Error err = sr_Update.getErrors()[0];
            String errormessage = err.getMessage();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,errormessage));
            return null;
        }
        
    }
    
    public PageReference cancelinfo(){
        
        if(profileName.Name=='High Volume Customer Portal User'){
    
            if(mktgplan.Contract_Type__c=='Volume Based'){
                String urlString = '/apex/CustomerPortal_MarketingPlan?id='+mktgplan.Id;
                return new PageReference(urlString);
            }
            else if(mktgplan.Contract_Type__c=='Rebates'){
                String urlString = '/apex/CustomerPortal_MarketingPlan_Rebates?id='+mktgplan.Id;
                return new PageReference(urlString);
            }
            else if(mktgplan.Contract_Type__c=='Headcount'){
                String urlString = '/apex/CustomerPortal_MarketingPlan_Headcount?id='+mktgplan.Id;
                return new PageReference(urlString);
            }
            else if(mktgplan.Contract_Type__c=='Ala Carte'){
                String urlString = '/apex/CustomerPortal_MarketingPlan_AlaCarte?id='+mktgplan.Id;
                return new PageReference(urlString);
            }
            else return null;
        }
        else{
                
                return new PageReference('/'+MPlan.Id);
            }
    }
    
}