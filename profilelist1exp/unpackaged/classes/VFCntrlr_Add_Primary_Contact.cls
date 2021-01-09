public class VFCntrlr_Add_Primary_Contact {

    public Marketing_Plan__c MPlan {get; set;}
    List <MDF_Associated_Contact__c> mdfContactList = new List <MDF_Associated_Contact__c>{};
    public String contactId {get; set;}
    MDF_Associated_Contact__c tempContact = new MDF_Associated_Contact__c();
    public boolean new_contact_info_rendered {get; set;}
    public boolean contact_table_rendered {get; set;}
    public RecordType mdfContactRT = [Select Id,Name from RecordType where sObjectType ='MDF_Contact__c'and isActive=true and Name ='Partner Contact'];
    public Marketing_Plan__c myplan {get;set;}
    public Profile profileName;
    Country__c tempCountry;
    
    public VFCntrlr_Add_Primary_Contact(ApexPages.StandardController controller) {
        
        //this.MPlan = (Marketing_Plan__c)controller.getRecord();
        this.MPlan = (Marketing_Plan__c)controller.getRecord();
        myplan = [select Id,Vendor__c,Contract_Type__c,Primary_Marketing_Contact_Name__c ,Primary_Marketing_Contact_Country__c ,Primary_Marketing_Contact_E_mail__c,Primary_Marketing_Contact_Phone__c,Primary_Marketing_Contact_Address__c ,Primary_Marketing_Contact_Cell__c,Primary_Marketing_Contact_City__c,Primary_Marketing_Contact_State__c,Primary_Marketing_Contact_Title__c,Primary_Marketing_Contact_Zip__c,Primary_Marketing_Contact_Fax__c from Marketing_Plan__c where Id=:MPlan.Id];
        mdfContactList = [Select Id,Name,MDF_Contact__c,MDF_Contact__r.Name,MDF_Contact__r.Phone__c,MDF_Contact__r.Email__c,MDF_Contact__r.Country__c,MDF_Contact__r.Partner_Contact_Type__c,MDF_Contact__r.Address__c,MDF_Contact__r.Mobile_Phone__c,MDF_Contact__r.City_Town__c,MDF_Contact__r.State_Province__c,MDF_Contact__r.Title__c,
        MDF_Contact__r.Zip_Postal_Code__c,
        MDF_Contact__r.Fax__c from MDF_Associated_Contact__c where Vendor__c=:myplan.Vendor__c and MDF_Contact__r.RecordTypeId =:mdfContactRT.Id and MDF_Contact__r.Partner_Contact_Type__c IN ('Marketing','Headcount-Marketing')];
        contact_table_rendered = true;
        if(mdfContactList.size()==0){
            contact_table_rendered = false;
        }
        
        new_contact_info_rendered = false;
        Id profileId=UserInfo.getProfileId();
        profileName = [select Id,Name from Profile where Id=:profileId];
        
    }
    
    public List <MDF_Associated_Contact__c> getMdfContactList(){
        return mdfContactList;
    }
    
    Public PageReference select_action(){
        
         //tempContact =[Select Id,Name from MDF_Associated_Contact__c where Id=:contactId];
        if(contactId != null){
            tempContact = [Select Id,Name,MDF_Contact__c,MDF_Contact__r.Name,MDF_Contact__r.Phone__c,MDF_Contact__r.Email__c,MDF_Contact__r.Country__c,MDF_Contact__r.Partner_Contact_Type__c,MDF_Contact__r.Address__c,MDF_Contact__r.Mobile_Phone__c,MDF_Contact__r.City_Town__c,MDF_Contact__r.State_Province__c,MDF_Contact__r.Title__c,
            MDF_Contact__r.Zip_Postal_Code__c, MDF_Contact__r.Partner_Contact_Country__c,
            MDF_Contact__r.Fax__c from MDF_Associated_Contact__c where Id=:contactId];
        }
        if(tempContact != null){
            if(tempContact.MDF_Contact__r.Partner_Contact_Country__c != null){
                tempCountry = [Select Id, Name from Country__c where Id=:tempContact.MDF_Contact__r.Partner_Contact_Country__c];
            }
            new_contact_info_rendered = true;
            MPlan.Primary_Marketing_Contact_Name__c = tempContact.MDF_Contact__r.Name;
            //MPlan.Primary_Marketing_Contact_Country__c = tempContact.MDF_Contact__r.Country__c;
            if(tempCountry != null){
                MPlan.Primary_Marketing_Contact_Country__c = tempCountry.Name;
            }
            MPlan.Primary_Marketing_Contact_E_mail__c = tempContact.MDF_Contact__r.Email__c;
            MPlan.Primary_Marketing_Contact_Phone__c = tempContact.MDF_Contact__r.Phone__c;
            MPlan.Primary_Marketing_Contact_Address__c = tempContact.MDF_Contact__r.Address__c;
            MPlan.Primary_Marketing_Contact_Cell__c = tempContact.MDF_Contact__r.Mobile_Phone__c;
            MPlan.Primary_Marketing_Contact_City__c = tempContact.MDF_Contact__r.City_Town__c;
            MPlan.Primary_Marketing_Contact_State__c = tempContact.MDF_Contact__r.State_Province__c;
            MPlan.Primary_Marketing_Contact_Title__c = tempContact.MDF_Contact__r.Title__c;
            MPlan.Primary_Marketing_Contact_Zip__c = tempContact.MDF_Contact__r.Zip_Postal_Code__c;
            MPlan.Primary_Marketing_Contact_Fax__c = tempContact.MDF_Contact__r.Fax__c;
        }
        
        
        /*Database.SaveResult sr_update1 = Database.update(MPlan,false);
        
        //Marketing_Plan__c myupdatedplan = [Select Id,Contract_Type__c from Marketing_Plan__c where Id=:MPlan.Id];
        
        if(myplan.Contract_Type__c=='Volume Based'){
            String urlString = '/apex/CustomerPortal_MarketingPlan?id='+myplan.Id;
            return new PageReference(urlString);
        }
        else if(myplan.Contract_Type__c=='Rebates'){
            String urlString = '/apex/CustomerPortal_MarketingPlan_Rebates?id='+myplan.Id;
            return new PageReference(urlString);
        }
        else if(myplan.Contract_Type__c=='Headcount'){
            String urlString = '/apex/CustomerPortal_MarketingPlan_Headcount?id='+myplan.Id;
            return new PageReference(urlString);
        }
        else if(myplan.Contract_Type__c=='Ala Carte'){
            String urlString = '/apex/CustomerPortal_MarketingPlan_AlaCarte?id='+myplan.Id;
            return new PageReference(urlString);
        }
        else*/ return null;
    }
    
    public MDF_Associated_Contact__c gettempContact(){
        return tempContact;
    }
    
    public PageReference new_contact_info_action(){
        
        MPlan.Primary_Marketing_Contact_Name__c = '';
        MPlan.Primary_Marketing_Contact_Country__c = '';
        MPlan.Primary_Marketing_Contact_E_mail__c = '';
        MPlan.Primary_Marketing_Contact_Phone__c = '';
        MPlan.Primary_Marketing_Contact_Address__c = '';
        MPlan.Primary_Marketing_Contact_Cell__c = '';
        MPlan.Primary_Marketing_Contact_City__c = '';
        MPlan.Primary_Marketing_Contact_State__c = '';
        MPlan.Primary_Marketing_Contact_Title__c = '';
        MPlan.Primary_Marketing_Contact_Zip__c = '';
        MPlan.Primary_Marketing_Contact_Fax__c = '';
         new_contact_info_rendered = true;
        return null;
    }
    
    public PageReference edit_contact_info_action(){
        
        MPlan.Primary_Marketing_Contact_Name__c = myplan.Primary_Marketing_Contact_Name__c ;
        MPlan.Primary_Marketing_Contact_Country__c = myplan.Primary_Marketing_Contact_Country__c;
        MPlan.Primary_Marketing_Contact_E_mail__c = myplan.Primary_Marketing_Contact_E_mail__c;
        MPlan.Primary_Marketing_Contact_Phone__c =myplan.Primary_Marketing_Contact_Phone__c ;
        MPlan.Primary_Marketing_Contact_Address__c =myplan.Primary_Marketing_Contact_Address__c;
        MPlan.Primary_Marketing_Contact_Cell__c = myplan.Primary_Marketing_Contact_Cell__c;
        MPlan.Primary_Marketing_Contact_City__c =myplan.Primary_Marketing_Contact_City__c ;
        MPlan.Primary_Marketing_Contact_State__c = myplan.Primary_Marketing_Contact_State__c;
        MPlan.Primary_Marketing_Contact_Title__c =myplan.Primary_Marketing_Contact_Title__c ;
        MPlan.Primary_Marketing_Contact_Zip__c = myplan.Primary_Marketing_Contact_Zip__c;
        MPlan.Primary_Marketing_Contact_Fax__c =myplan.Primary_Marketing_Contact_Fax__c ;
         new_contact_info_rendered = true;
        return null;
    }
    
    public PageReference savenew_Info(){  
                  
        //update MPlan;
        /*if(MPlan.Primary_Marketing_Contact_Cell__c==null && MPlan.Primary_Marketing_Contact_Phone__c==null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter either Phone or Cell Number'));
            return null;    
        }*/
        Database.SaveResult sr_Update = Database.update(MPlan,false);
        //Marketing_Plan__c myupdatedplan = [Select Id,Contract_Type__c from Marketing_Plan__c where Id=:MPlan.Id];
        
        if(sr_Update.isSuccess()){
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            Id profileId=UserInfo.getProfileId();
            Profile p = [select Id,Name from Profile where Id=:profileId];
            
            if(profileName.Name=='High Volume Customer Portal User'){
                if(myplan.Contract_Type__c=='Volume Based'){
                    String urlString = '/apex/CustomerPortal_MarketingPlan?id='+myplan.Id;
                    return new PageReference(urlString);
                }
                else if(myplan.Contract_Type__c=='Rebates'){
                    String urlString = '/apex/CustomerPortal_MarketingPlan_Rebates?id='+myplan.Id;
                    return new PageReference(urlString);
                }
                else if(myplan.Contract_Type__c=='Headcount'){
                    String urlString = '/apex/CustomerPortal_MarketingPlan_Headcount?id='+myplan.Id;
                    return new PageReference(urlString);
                }
                else if(myplan.Contract_Type__c=='Ala Carte'){
                    String urlString = '/apex/CustomerPortal_MarketingPlan_AlaCarte?id='+myplan.Id;
                    return new PageReference(urlString);
                }
                else return null;
            }
            else{
                return new PageReference('/'+MPlan.Id);
            }
           }
            
            //else return null;
       
        else{
            Database.Error err = sr_Update.getErrors()[0];
            String errormessage = err.getMessage();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,errormessage));
            return null;
        }
        
    }
    
   public PageReference cancelinfo(){
        
        if(profileName.Name=='High Volume Customer Portal User'){
        if(myplan.Contract_Type__c=='Volume Based'){
            String urlString = '/apex/CustomerPortal_MarketingPlan?id='+myplan.Id;
            return new PageReference(urlString);
        }
        else if(myplan.Contract_Type__c=='Rebates'){
            String urlString = '/apex/CustomerPortal_MarketingPlan_Rebates?id='+myplan.Id;
            return new PageReference(urlString);
        }
        else if(myplan.Contract_Type__c=='Headcount'){
            String urlString = '/apex/CustomerPortal_MarketingPlan_Headcount?id='+myplan.Id;
            return new PageReference(urlString);
        }
        else if(myplan.Contract_Type__c=='Ala Carte'){
            String urlString = '/apex/CustomerPortal_MarketingPlan_AlaCarte?id='+myplan.Id;
            return new PageReference(urlString);
        }
        else return null;
        }
        else{
                return new PageReference('/'+MPlan.Id);
            }
        
   }

}