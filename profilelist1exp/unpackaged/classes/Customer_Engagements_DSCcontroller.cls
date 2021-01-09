public class Customer_Engagements_DSCcontroller{

public Customer_Engagement__c customerEng {get;set;}
public string err{get;set;}
public boolean showHideErr{get;set;}
public boolean editFlag{get;set;}
public String posId {get;set;}
public id dscRTId;
public id RecordTy{get;set;}


public Customer_Engagements_DSCcontroller(ApexPages.StandardController controller) {
/* FOR EXISTING RECORDS */
 if(ApexPages.currentPage().getParameters().get('Id')!= null){
   customerEng = [Select Id,RecordTypeid,Dell_Solution_Center_Site__c,Event_Type__c from Customer_Engagement__c where ID =: ApexPages.currentPage().getParameters().get('Id')];
    posId=customerEng.Dell_Solution_Center_Site__c;
   editFlag = true;
    }
/* FOR NEW RECORD */
    else{
         editFlag = false;
         customerEng = new Customer_Engagement__c();
         id RecordTy =[SELECT Id FROM RecordType WHERE SobjectType = 'Customer_Engagement__c' AND Name = 'Dell Solution Centers'].id;
         customerEng.recordtypeId = RecordTy ;
        }
        
    showHideErr = false;   
    List<RecordType> dscRT=[select id,name,SobjectType  from RecordType where SobjectType='Customer_Engagement__c' and name='Dell Solution Centers' limit 1];
        for(RecordType a:dscRT){
            dscRTId=a.Id;
        }    
}

/* TO DISPLAY ERROR ON PAGE IF NO FIELD VALUES ARE SELECTED AND
   NAVIGATE VF PAGE TO STANDARD EDIT PAGE */
 
   public PageReference Displayerr(){ 
   
     if( customerEng.Event_Type__c == null && posId=='--None--')
        {
         showHideErr = True;
         err = system.Label.customer_engagement_DSC_page_error_1;
         return null;
        }
        
          if( customerEng.Event_Type__c== null)
             {
              showHideErr = True;
              err = system.Label.customer_engagement_DSC_page_error_2;
              return null;
             }
              
            if( posId=='--None--')
               {
               showHideErr = True;
               err = system.Label.customer_engagement_DSC_page_error_3;
               return null;
               }
    
                else{
                    PageReference page;
                    string lkName = [SELECT Name FROM Event_Location__c where Id=:posId].Name;
                    string a =customerEng.Event_Type__c ;
                    a=EncodingUtil.urlEncode(a,'UTF-8');
                    string b = posId ;
                    b=EncodingUtil.urlEncode(b,'UTF-8');
                    string c =lkName ;
                    c=EncodingUtil.urlEncode(c,'UTF-8');
                    
                   if(editFlag){
                     
                        page = new PageReference('/'+customerEng.Id+'/e?retURL=%2F'+customerEng.Id+'&nooverride=1&CF'+system.label.customer_engagement_DSC_site_id+'_lkid='+b+
                                '&CF'+system.label.customer_engagement_DSC_site_id+'='+c+'&'+system.label.customer_engagement_DSC_event_type_id+'='+a);
                      
                      }
                      
                      else{
                               
                      page = new PageReference('/a17/e?RecordType='+dscRTId+'&nooverride=0&'+system.label.customer_engagement_DSC_event_type_id+'='+a+
                                       '&CF'+system.label.customer_engagement_DSC_site_id+'_lkid='+b+'&CF'+system.label.customer_engagement_DSC_site_id+'='+c);
                                                                                                 
                  
                         }
                           
                     page.setRedirect(true);
                     return page;
                    }
                       
              }
            
                       
/* TO GET ALL THE SITES HAVING ENGAGEMENT TYPE AS DSC */

        public List<SelectOption> getsites() {
       
        List<Event_Location__c> site=[SELECT Event__c,Id,Name FROM Event_Location__c where recordType.name='sites' and Active__c=true and Engagement_Type__c='DSC' ORDER BY Name ASC];
        List<SelectOption> options = new List<SelectOption>();                       
        options.add(new SelectOption('--None--','--None--'));                   
              for(Event_Location__c s:site)
                 {                                   
                  options.add(new SelectOption(s.Id,s.Name));
                 }         
           
        return options;
        }
        
  /* PAGE NAVIGATION ON CLICK OF EDIT BUTTON OF DETAIL PAGE OF RECORD 
                    
      public PageReference redirect() {
      PageReference page ;
      
      if( customerEng.RecordTypeid==dscRTId)
        {
        return null;
        }
      
      else
      {
       page = new PageReference('/'+customerEng.Id+'/e?retURL=%2F'+customerEng.Id+'&nooverride=1');
       return page;
  
      }
  }   */    

 }