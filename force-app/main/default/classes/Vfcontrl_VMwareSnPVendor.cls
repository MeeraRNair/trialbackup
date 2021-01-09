/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR13257                 30-June-2016     Syidah         auto-display VMware Products within S&P Vendor record with additional info
 * 
 * 1.1                              18-Jul-2016      Kenny          Calling standard controller in order to embed the visualforce page in VMWare_PL page layout 
 * 2.0      CR14564                 03-Jul-2017      Jessie         VMware API – Add Discount %
 * 2.1      CR14618                 10-Jul-2017      Jessie         Add Eligible to Lead Services field of Opp Product into SOQL 
 -------- ---------   ----------  -----------     ------------    ---------------------------------------------------------------------------------------------
 */

public class Vfcontrl_VMwareSnPVendor {   
 public ApexPages.StandardController controller;
 public S_P_Vendors__c snpVendors;
 public list<OpportunityLineItem> lineItems {get;set;}

// 1.1 Start
   public Vfcontrl_VMwareSnPVendor(ApexPages.StandardController controller) {
       this.snpVendors = (S_P_Vendors__c)controller.getRecord();
       if(snpVendors.id != null)
       {
           snpVendors = [Select Opportunity__c from S_P_Vendors__c where id =: snpVendors.id];
       }
}  

public void displayVMware(){
    
    lineItems = new list<OpportunityLineItem>();
                        
        System.Debug('##snpVendors.Opportunity__c##'+snpVendors.Opportunity__c);
        lineItems = [SELECT Id, Product2.Description, Quantity,Rejected__c, Approved__c, Discount__c, Eligible_to_Lead_Services__c //v2.1
                     FROM OpportunityLineItem 
                     WHERE OpportunityId =: snpVendors.Opportunity__c AND S_P_Registerable__c = 'TRUE' and Brand_Desc__c = 'VMware'];
         
    }
// 1.1 End

}