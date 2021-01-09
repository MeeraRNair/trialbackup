/*****************************************************************************************************************************
History:
Version     Date           Modified By     Description
------------------------------------------------------------------------------------------------------------------------------
Initial     05-Apr-2012    RP              CR7042 & CR7043: Created For R13.4 Maintenance Project - Ala Carte and Volume Based Template Modification
*******************************************************************************************************************************/
public with sharing class VolumeBasedMP {

    string header;
    List<Associated_Programs_Vendors__c> associatedVendorsList;
    Double budgetedPrice = 0;
    Double invoiceAmount = 0; 
    
    public VolumeBasedMP(string header, List<Associated_Programs_Vendors__c> vendorList ){
        this.header = header;
        this.associatedVendorsList = vendorList;
        for(Associated_Programs_Vendors__c apv : vendorList){
            budgetedPrice = budgetedPrice + apv.Budgeted_Price__c;            
            if(apv.Invoice_Amount__c != null && ((apv.POP_Status__c == 'Executed' && apv.POP_Status_Reason__c != 'Vendor Dissatisfied with Program') || (apv.POP_Status__c == 'Not Executed' && apv.POP_Status_Reason__c == 'Vendor Absent – Charge'))){
                invoiceAmount = invoiceAmount + apv.Invoice_Amount__c;                
            }
        }
        
    }

    public string getHeader(){
        return this.header;
    }

    public List<Associated_Programs_Vendors__c> getAssociatedVendorsList(){
        return this.associatedVendorsList;
    }
    public Double getbudgetedPrice(){
        return budgetedPrice;
    }
    public Double getinvoiceAmount(){
        return invoiceAmount;
    }

 }