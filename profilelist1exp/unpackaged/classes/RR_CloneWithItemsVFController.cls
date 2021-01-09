public class RR_CloneWithItemsVFController{ 
    
    public Rebate_Rule_Header__c new_RRH{get;set;}
    public Rebate_Rule_Header__c clone_RRH;
    public Rebate_Rule_Header__c cloned_RRH;
    public String strRRID {get;set;}
    
    public List <Rebate_Rule_Line_Item__c> clone_RRLI_list= new List<Rebate_Rule_Line_Item__c>();
    public List <Rebate_Rule_Line_Item__c> new_RRLI_List= new List<Rebate_Rule_Line_Item__c>();
    public Rebate_Rule_Line_Item__c cloned_RR_lineItem ;
    
    public Rebate_Rule_Line_Item__c rrli{get;set;}
    public boolean datesError{get;set;}
    
    Vendor__c Vendor =new Vendor__c();  
    
    public ID currid;
    public ID clonedRRHId;
    
    public Boolean displayerr=False;
    public Boolean fiscalyrerr=False;
    public Boolean newfiscalyr=True;
    public Boolean duprecordexist=False;
    Public Boolean Showdates{get;set;}
    
    
    public RR_CloneWithItemsVFController(ApexPages.StandardController controller){
        //currid= ApexPages.currentPage().getParameters().get('id');
        strRRID = apexpages.currentpage().getparameters().get('id');
        currid=controller.getId();
        new_RRH = new Rebate_Rule_Header__c();
        
        rrli = new Rebate_Rule_Line_Item__c();
        
        clone_RRH=[select Name,Fiscal_Quarter__c,Vendor__c,Region__c,Country__c,Sub_Region__c,Status__c
                        from Rebate_Rule_Header__c where id=:currid];
                        
        clone_RRLI_list=[select Name,Amount__c,Business_Segment__c,Class__c,Comments__c,Dell_SKU__c,Effective_Date_From__c,Effective_Date_To__c,
                      Flat_Rate__c,Max_Amount__c,Max_Units__c,Mfg_SKU__c,Min_Units__c,Rebate__c,Rebate_Rule_Header__c,Sub_Class__c,
                      Units_Forecasted__c,Vendor__c  from Rebate_Rule_Line_Item__c where Rebate_Rule_Header__c=:currid];
                      
        If(clone_RRLI_list.size()>0) 
          Showdates = True;      
                              
        new_RRH.Fiscal_Quarter__c = clone_RRH.Fiscal_Quarter__c;
        datesError = false;
    }
    
    public Boolean getdisplayerr(){
    return displayerr;
    }
    
    public Boolean getnewfiscalyr(){
    return newfiscalyr;
    }
    
    public Boolean getfiscalyrerr(){
    return fiscalyrerr;
    }
    
    public Boolean getduprecordexist(){
    return duprecordexist;
    }
    
    /*
    public Rebate_Rule_Header__c getnew_RRH (){
    return new_RRH;
    }
    
    public void setnew_RRH (Rebate_Rule_Header__c toclone){
    new_RRH = toclone;
    }
    */
    
    Public pagereference RRCloneWithItems() {
         
         Rebate_Rule_Header__c rrh = [select Id,Fiscal_Quarter__c from Rebate_Rule_Header__c where Id =:currid];
         
         PageReference currpage;
    //Check for duplicate fiscal year
         if (new_RRH.Fiscal_Quarter__c== clone_RRH.Fiscal_Quarter__c){
             system.debug('*****'+fiscalyrerr);
             fiscalyrerr=True;
             if (duprecordexist==True){
                 duprecordexist=False;
             }
//             currpage = new PageReference('/apex/RebateRuleClonePage');
             return null;
         }   
         
    //Check for duplicate record with same name, sub-vendor, region and fiscal qtr 
        List <Rebate_Rule_Header__c> dupRRList=new List<Rebate_Rule_Header__c>();
        dupRRList=[select Name,Fiscal_Quarter__c,Vendor__c,Region__c,Sub_Region__c,Country__c from Rebate_Rule_Header__c 
                   where Name=:clone_RRH.Name AND Fiscal_Quarter__c=:new_RRH.Fiscal_Quarter__c AND Vendor__c=:clone_RRH.Vendor__c AND Region__c=:clone_RRH.Region__c];          
        if( dupRRList.size()>0){
            duprecordexist=True;
            system.debug('*****'+fiscalyrerr);
            if (fiscalyrerr==True){
                fiscalyrerr=False;
            }
//            currpage = new PageReference('/apex/RebateRuleClonePage');
            return null;    
        }          
    //Clone RRH rule 
    
         Savepoint sp = Database.setSavepoint();  
         /*
         Rebate_Rule_Header__c rrhTemp = clone_RRH.clone(false);
         rrhTemp.Fiscal_Quarter__c = new_RRH.Fiscal_Quarter__c;
         rrhTemp.Status__c = 'Pending';
         rrhTemp.Name = new_RRH.Name;
         cloned_RRH = rrhTemp;
          system.debug(cloned_RRH+'=='+rrhTemp+'*****'+new_RRH.Fiscal_Quarter__c);
         */
         
        // clone_RRH.Fiscal_Quarter__c = new_RRH.Fiscal_Quarter__c;
//         clone_RRH.Name=new_RRH.Name;
         clone_RRH.Status__c='Pending';
         cloned_RRH=clone_RRH.clone(false);
         cloned_RRH.Fiscal_Quarter__c = new_RRH.Fiscal_Quarter__c;
         cloned_RRH.Region__c = clone_RRH.Region__c;
         cloned_RRH.Sub_Region__c = clone_RRH.Sub_Region__c;
         cloned_RRH.Country__c = clone_RRH.Country__c;
         
         insert cloned_RRH;
         
         system.debug('*****'+cloned_RRH.Id);
         clonedRRHId=cloned_RRH.id;
         
        //Clone RR line item
         try{ 
        // Boolean ValidFromDate;
        // Boolean ValidToDate;  
         for(Rebate_Rule_Line_Item__c RRL : clone_RRLI_list) {
               cloned_RR_lineItem = new Rebate_Rule_Line_Item__c();      
               cloned_RR_lineItem = RRL.clone(false); 
               cloned_RR_lineItem.Rebate_Rule_Header__c = clonedRRHId;
               cloned_RR_lineItem.Effective_Date_From__c =  rrli.Effective_Date_From__c; 
               cloned_RR_lineItem.Effective_Date_To__c =  rrli.Effective_Date_To__c; 
               
               system.debug(rrli.Effective_Date_From__c+'$$$$$$$$$$'+rrli.Effective_Date_To__c);
               system.debug(cloned_RR_lineItem.Effective_Date_From__c+'---------'+cloned_RR_lineItem.Effective_Date_To__c);
               new_RRLI_List.add(cloned_RR_lineItem);
           } 
         
         /*  
        String FY= cloned_RRH.Fiscal_Quarter__c;
        String FisYear= String.Valueof(FY); 
        ValidFromDate=DateValidationForFiscalQtr.DateValidation(FisYear,new_RRLI_List[0].Effective_Date_From__c);
        ValidToDate=DateValidationForFiscalQtr.DateValidation(FisYear,new_RRLI_List[0].Effective_Date_To__c);         
        
        if ( !ValidFromDate && !ValidToDate ){
            cloned_RRH.addError('Please enter valid From and To dates that falls in the Fiscal Quarter of the Rebate Rule Header');             
        } else if(!ValidToDate) {
            cloned_RRH.addError('Please enter a valid To_date that falls in the Fiscal Quarter of the Rebate Rule Header');  
        } else if ( !ValidFromDate ){ 
            cloned_RRH.addError('Please enter a valid From_date that falls in the Fiscal Quarter of the Rebate Rule Header'); 
        }         
      */
         
         insert new_RRLI_List; 
         datesError = false;
         currpage=new PageReference('/'+ clonedRRHId); 
         return currpage;
        } catch (DmlException e){
            system.debug('*****'+e.getMessage());
            Database.rollback(sp);
            new_RRLI_List.clear();
            //delete cloned_RRH;
            ApexPages.addMessages(e);
            datesError = true;
          //  fiscalyrerr=True;
            //displayerr=True;
            if((e.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION')) && (e.getMessage().contains('Vendor__c'))) {
                 displayerr=True;
                // fiscalyrerr=True;
                 newfiscalyr=False;
//                 currpage = new PageReference('/apex/RebateRuleClonePage');
                 return null;
            }  
        }           
        return currpage;
    }
    
    Public void AutoApproveRR() {
        PageReference currpage=new PageReference('/'+currid);
        try{
        
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for Auto-approval.');
            req1.setObjectId(currid); 
            req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});   
            
            Approval.ProcessResult result = Approval.process(req1);
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance status'+result.getInstanceStatus());
            if(result.isSuccess()==true){
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
            
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Auto-approved');
            req2.setAction('Approve');              
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req2.setWorkitemId(newWorkItemIds.get(0));
            
            Approval.ProcessResult result2 = Approval.process(req2);
            System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
            System.assertEquals('Approved', result2.getInstanceStatus(), 'Instance Status'+result2.getInstanceStatus());
            }
        }catch(Exception e){
            //chkForUrl();
            system.debug('###'+e.getMessage());
        }
        
     // return currpage;
     } 
}