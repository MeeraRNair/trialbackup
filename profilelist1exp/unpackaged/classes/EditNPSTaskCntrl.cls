/* ============================================================
* This Controller Created for Editing NPS task to reflect primary 
 * and Secondary root cause values dynamically from Root Casue Table
* CR 9028 - Version 0.1 Developed by Rakesh Muppiri on 22-01-2014
* CR 10637 - Updated code to Auto populate Nss Catagory Route cause values with Nss Catagory.
* ============================================================
*/

public with sharing class EditNPSTaskCntrl {
    public string NSSCategoryRootCause{set;get;}
    public List<SelectOption>NSSCategoryRootCauses{get;set;}
    
    public Task t{set;get;}
    public List<SelectOption> primary{set;get;}
    public List<SelectOption> secondary{set;get;}
    
    public boolean AbletoEdit {set;get;}
    public Id i {set;get;}
    public String cont = 'con\'t';
    Public String getcont(){
        return cont;
    }
    public String Category{set;get;}
    public String primaryvalue{set;get;}
    public String secondaryvalue{set;get;}
    List<Root_Cause_Table__c> LRoot{set;get;}
    public EditNPSTaskCntrl(ApexPages.StandardController controller) {
        primary = new List<SelectOption>();
       secondary = new List<SelectOption>();
        NSSCategoryRootCauses = new List<SelectOption>();
        List<String> LNSSCateogry= new List<String>();
        Set<String> SNSSCateogry= new Set<String>();
        for(NSS_Category__c temp : [SELECT Name FROM NSS_Category__c]){
            SNSSCateogry.add(temp.Name);
        }
        LNSSCateogry.addAll(SNSSCateogry);
        LNSSCateogry.sort();
        NSSCategoryRootCauses.add(new SelectOption('','--select--'));
        for(String s : LNSSCateogry){
            NSSCategoryRootCauses.add(new SelectOption(s,s));            
        }
               i = controller.getID();
               UserRecordAccess temp = [SELECT RecordId, HasEditAccess, HasTransferAccess, MaxAccessLevel FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId =:controller.getID()];
               if(temp.HasEditAccess == false)
                   AbletoEdit  = false;
                else{
                    AbletoEdit  = true;
                   t = [SELECT ReminderDateTime,Description, Primary_Root_Cause__c, Primary_Root_Causes__c, Secondary_Root_Cause__c, Secondary_Root_Causes__c, OwnerId, NSS_Category__c, Status, Collaboration_Method__c, In_Flight_Issue_Resolved__c, ActivityDate, NSS_Category_Root_Cause__c, Root_Cause_Comments__c, Root_Cause_Commentss__c,WhatId FROM Task WHERE ID =: controller.getID()];
                   if(t.NSS_Category_Root_Cause__c != null)
                       LRoot = [SELECT Primary_Root_Cause__c, Secondary_Root_Cause__c FROM Root_Cause_Table__c WHERE NSS_Category__r.Name =: t.NSS_Category_Root_Cause__c];
                   else
                       LRoot = [SELECT Primary_Root_Cause__c, Secondary_Root_Cause__c FROM Root_Cause_Table__c WHERE NSS_Category__r.Name =: t.NSS_Category__c];
                   //NSSCategoryMethod();
                   if(t.NSS_Category_Root_Cause__c != null)
                       NSSCategoryRootCause = t.NSS_Category_Root_Cause__c;
                   primaryvalue = t.Primary_Root_Cause__c;
                   secondaryvalue = t.Secondary_Root_Cause__c;
                 }
                 if(t.Primary_root_Cause__c != null)
                   primary.add(new SelectOption(t.Primary_root_Cause__c ,t.Primary_root_Cause__c ));
      
                if(t.Secondary_root_Cause__c != null)
                   secondary.add(new SelectOption(t.Secondary_root_Cause__c ,t.Secondary_root_Cause__c ));
                if(t.Secondary_root_Cause__c ==null && t.Primary_root_Cause__c==null)
                    NSSCategoryMethod();
                NSSCategoryRootCause = t.NSS_Category__c;
    system.debug('---------');
    }
    
    public Set<String> SPrimary = new Set<String>();
    public Set<String> SSecondary = new Set<String>();
    
    public List<String> ListPrimary = new List<String>();
    public List<String> ListSecondary = new List<String>();
    public PageReference Save(){
        if(primaryvalue == null ){
            t.addError('Primary Root Casue Value is Required');
            return null;
        }
        t.Primary_root_Cause__c = primaryvalue;
        t.Secondary_Root_cause__c = secondaryvalue;
        t.NSS_Category_Root_Cause__c = NSSCategoryRootCause;
        t.isReminderSet=true;
        try{
        update t;
        }Catch(Exception e){
            UserRecordAccess temp = [SELECT RecordId, HasEditAccess, HasTransferAccess, MaxAccessLevel FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId =: t.Id LIMIT 1];
            if(temp.HasEditAccess == false)
                t.addError('This taks is assigned to some other user, You dont have Edit access to update this Task');

            return null;
        }
        return new PageReference('/'+t.Id);
    }
    public PageReference Cancel(){
        return new PageReference('/'+t.Id);
    }
    
    //LoadSecondary function will be called after selecting value from Primary Root Cause
    public PageReference LoadSecondary(){
        SSecondary.clear();
        ListSecondary.clear();
        if(secondary!=null)
            secondary.clear();
        Secondary.add(new SelectOption('','--Select--'));          //Adding values of Secondary Root Casue from List to Select Option
        for(Root_Cause_Table__c R : LRoot){
           if(R.Primary_Root_Cause__c == primaryvalue)
            SSecondary.add(R.Secondary_Root_Cause__c );
       }
        ListSecondary.addAll(SSecondary);
        ListSecondary.sort();        
        for(String s: ListSecondary){
           if(s!=null)
           secondary.add(new SelectOption(s,s));
       } 
        return null;
    }
    //NSSCateogryMethod Method to load Primary, Secondary Root cause Values
    public void NSSCategoryMethod(){
        SSecondary.clear();
        ListSecondary.clear();
        if(secondary != null)
            secondary.clear();
        SPrimary.clear();
        ListPrimary.clear();
        if(primary != null)
            primary.clear();
        for(Root_Cause_Table__c R : LRoot){
           SPrimary.add(R.Primary_Root_Cause__c);
           SSecondary.add(R.Secondary_Root_Cause__c );
       }
       ListPrimary.addAll(SPrimary);
       ListSecondary.addAll(SSecondary);       
       
        
       primary.add(new SelectOption('','--Select--'));            //Adding values of Primary Root Casue from List to Select Option
       
        
       Secondary.add(new SelectOption('','--Select--'));          //Adding values of Secondary Root Casue from List to Select Option
       for(String p: ListPrimary){
           primary.add(new SelectOption(p,p));
       }
       for(String s: ListSecondary){
           if(s!=null)
               secondary.add(new SelectOption(s,s));
       }  
       
    }
    
    // Function will be called once if we change value NSS Category Root Cause
    public PageReference LoadPrimarySecondary(){
        system.debug('Yesss'+NSSCategoryRootCause);
        
        if(Category== ''){
             LRoot.clear();
            //LRoot = [SELECT Primary_Root_Cause__c, Secondary_Root_Cause__c FROM Root_Cause_Table__c WHERE NSS_Category__r.Name =: t.NSS_Category__c];
            NSSCategoryMethod();
        }
        else{
            LRoot.clear();
            LRoot = [SELECT Primary_Root_Cause__c, Secondary_Root_Cause__c FROM Root_Cause_Table__c WHERE NSS_Category__r.Name =: Category];
            NSSCategoryMethod();
        }
        return null;
    }
}