public class VFCntrlr_CustomerPortal_MPlan_Rebates {
        
        public Marketing_Plan__c myMPPlan {get; set;}
        public boolean contact_buttons_rendered{get; set;}
        public boolean purchaseorder_render {get; set;}
        public List <Rebate_Rule_Line_Item__c> RebateLineItemList = new List <Rebate_Rule_Line_Item__c>{};
		public VFCntrlr_CustomerPortal_MPlan_Rebates(ApexPages.StandardController controller) {            
            this.myMPPlan = (Marketing_Plan__c)controller.getRecord();
            contact_buttons_rendered = true;
            purchaseorder_render = true;
            if(myMPPlan.Rebate_Rule_Header__c!=null){
                    RebateLineItemList = [SELECT Id,Name,Dell_SKU__c,Mfg_SKU__c,Class__c,Sub_Class__c,Amount__c,Rebate__c,Flat_Rate__c,Effective_Date_To__c,Effective_Date_From__c,Max_Units__c,Min_Units__c,Max_Amount__c,Comments__c,Business_Segment__c FROM Rebate_Rule_Line_Item__c WHERE Rebate_Rule_Header__c =:myMPPlan.Rebate_Rule_Header__c];
            }
		}
    
	    public List<Rebate_Rule_Line_Item__c> getRebateLineItemList(){
	        return RebateLineItemList;
	    }
        
        public PageReference addPrimaryContact(){
                String urlString = '/apex/add_Primary_Contact?id='+myMPPlan.Id;
                return new PageReference(urlString);
        }
        
        public PageReference addBillingContact(){
                String urlString = '/apex/add_Billing_Contact?id='+myMPPlan.Id;
                return new PageReference(urlString);
        }
        
        public PageReference accept_decline_MP(){
                if(myMPPlan.Primary_Marketing_Contact_Name__c==null ||myMPPlan.Billing_Contact_Name__c==null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please make sure that the Marketing and Billing Contact information are filled before reviewing the programs and packages.'));
        }
        else{
                contact_buttons_rendered = false;
        }
                return null;
                
        }
        
        public PageReference saveStatusrebates(){
                contact_buttons_rendered = true;
             
                if(myMPPlan.MP_Status__c=='Accept'){
                     myMPPlan.Contract_Status__c = 'Accepted';
                     myMPPlan.MP_Status__c=null;  
                     System.debug('hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii'); 
                     update myMPPlan;                                         
                }
                if(myMPPlan.MP_Status__c=='Decline'){
                     myMPPlan.Contract_Status__c = 'Cancelled / Declined';
                     myMPPlan.MP_Status__c=null;  
                     update myMPPlan;                                            
                }
                //update myMPPlan;
                return null;
        }
        
        public PageReference addpurchaseorder(){
                purchaseorder_render = false;               
                return null;
        }
        
        public PageReference savepruchaseorder(){
                purchaseorder_render = true;
                update myMPPlan;
                return null;
        }
        public PageReference cancelfn(){
                PageReference p = new PageReference('/apex/CustomerPortal_MarketingPlan_Rebates?id='+myMPPlan.Id);
                p.setRedirect(true);    
                return p;
   }

}