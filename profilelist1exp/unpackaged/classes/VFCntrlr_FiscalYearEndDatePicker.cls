/**
* Name          : VFCntrlr_FiscalYearEndDatePicker
* Description   : Reformat the ‘Fiscal Year End’ field to DD/MMM
* -------------------------------------------------------------------------------
* Revision  Name         Date         Description
* 1.0       Josipinna    20-Jul-2011  Creation/ Fix for Defect 71606 (CR 6221)
* -------------------------------------------------------------------------------
**/

public class VFCntrlr_FiscalYearEndDatePicker {

    //Variable Declaration
    private Account AccountRecord;
    public String aAccountId  {get;set;}
    
    
    public Date newSelectedDate {get;set;}

       
        /* Constructor */
    public VFCntrlr_FiscalYearEndDatePicker(ApexPages.StandardController controller){
            
            System.debug('***************** In the Class Constructor *****************'); 
            this.AccountRecord = (Account)controller.getRecord();
            aAccountId = AccountRecord.Id;

            System.debug('#####aAccountId :' +aAccountId);
    }//End of Constructor        


    public PageReference doSave()
    {
    
     newSelectedDate = this.AccountRecord.Fiscal_Year_End__c;
     Account updAcc = new Account(Id = aAccountId);
     updAcc.Fiscal_Year_End__c = newSelectedDate;
     
     update updAcc;
     
    return new PageReference('/'+aAccountId);
   }
  


    public PageReference doCancel(){
    
        return new PageReference('/'+aAccountId);
    }//End of doCancel()


}//End of Class VFCntrlr_FiscalYearEndDatePicker