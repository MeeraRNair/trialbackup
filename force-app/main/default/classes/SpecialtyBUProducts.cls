/*
* Author  : Ershad
* Purpose : Give Rollup Summary value for the field Opportunity.Specialty_BU_Products__c, when FPG_DPS__c,FPG_MDC__c and FPG_UDS__c products added or deleted.
* Objects : Opportunity, OpportunityLineItem.
*/
Public class SpecialtyBUProducts {
public static void rollupsummarySpecialityBUProducts(List<OpportunityLineItem> listOppLine) {
        Set<Id> setOpportunityIds33 = new Set<Id>();
        
        List<Opportunity> listOppsToUpdate=New List<Opportunity>();
        
        for(OpportunityLineItem oli : listOppLine) {
            If(oli.OpportunityId != null &&(oli.FPG_DPS__c==True||oli.FPG_MDC__c==True||oli.FPG_UDS__c==True)) {
                setOpportunityIds33.add(oli.OpportunityId);
				system.debug('mapOpportunityIds'+setOpportunityIds33);
            }
		}
      List<Opportunity> listOPTs=[select Id,Specialty_BU_Products__c,(select id,FPG_DPS__c,FPG_MDC__c,FPG_UDS__c from OpportunityLineItems)from Opportunity where Id in :setOpportunityIds33];
         for(Opportunity lsOPT:listOPTs)
         {
        String str7='';
        String str1='';
        String str2='';
        String str3='';
        String str4='';
        String str5='';
        String str6='';  
           for(OpportunityLineItem optl:lsOPT.OpportunityLineItems)
               {
               system.debug('ABCDE'+lsOPT.OpportunityLineItems);
			  If(optl.FPG_DPS__c!=False && optl.FPG_UDS__c!=False && optl.FPG_MDC__c!=False){
			     str7='DPS;UDS;MDC';
                 system.debug('str7++++'+str7); 
				}
			   If(optl.FPG_DPS__c!=False && optl.FPG_UDS__c!=False){
			     str1='DPS;UDS';
			    }
			   If(optl.FPG_DPS__c!=False && optl.FPG_MDC__c!=False){
			     str2='DPS;MDC';
			    }	
			   If(optl.FPG_UDS__c!=False && optl.FPG_MDC__c!=False){
			      str3='UDS;MDC';
			    }
			   If(optl.FPG_UDS__c!=False){
			     str4='UDS';
                 system.debug('---->>>>>'+str4);    
				}
			   If(optl.FPG_MDC__c!=False){
			     str5='MDC';
			   }
			   If(optl.FPG_DPS__c!=False){
			      str6='DPS';
                  system.debug('---->>>>>'+str6);  
			    }
			   }
             If((str7!=Null && str7!='')||(str1!=''&& str2!='')||(str2!='' && str3!='')||(str1!='' && str5!='')||(str2!='' && str4!='')||(str3!='' && str6!='')||(str4!=''&& str5!='' && str6!=''))
               {
			  Opportunity optts=new Opportunity();
			  optts.id=lsOPT.Id;
			  optts.Specialty_BU_Products__c='DPS;UDS;MDC';
			  listOppsToUpdate.add(optts);
              system.debug('listOppsToUpdate'+listOppsToUpdate);
			  }
			  Else If((str1!=Null && str1!='') && (str7!=Null && str7!='')|| (str4!='' && str6!=''))
              {
			  Opportunity opts1=new Opportunity();
			  opts1.id=lsOPT.Id;
			  opts1.Specialty_BU_Products__c='DPS;UDS';
			  listOppsToUpdate.add(opts1);
			  }
			  Else If((str2!=Null && str2!='') && (str7!=Null && str7!='') || (str5!='' && str6!=''))
              {
			  Opportunity opts2=new Opportunity();
			  opts2.id=lsOPT.Id;
			  opts2.Specialty_BU_Products__c='DPS;MDC';
			  listOppsToUpdate.add(opts2);
			  }
			  Else If((str3!=Null && str3!='') && (str7!=Null && str7!='') || (str4!='' && str5!=''))
              {
			  Opportunity opts3=new Opportunity();
			  opts3.id=lsOPT.Id;
			  opts3.Specialty_BU_Products__c='UDS;MDC';
			  listOppsToUpdate.add(opts3);
			  }
			  Else If(str4!=Null && str4!='' && str7=='' && str1=='' && str3=='' && str2=='')
              {
			  Opportunity opts4=new Opportunity();
			  opts4.id=lsOPT.Id;
			  opts4.Specialty_BU_Products__c='UDS';
			  listOppsToUpdate.add(opts4);
			  }
			  Else If(str5!=Null && str5!='' && str7=='' && str1=='' && str3=='' && str2=='')
              {
			  Opportunity opts5=new Opportunity();
			  opts5.id=lsOPT.Id;
			  opts5.Specialty_BU_Products__c='MDC';
			  listOppsToUpdate.add(opts5);
			  }
			  Else If(str6!=Null && str6!='' && str7=='' && str1=='' && str3=='' && str2==''){
			  Opportunity opts6=new Opportunity();
			  opts6.id=lsOPT.Id;
			  opts6.Specialty_BU_Products__c='DPS';
			  listOppsToUpdate.add(opts6);
			  }
             Else If(str6=='' && str7=='' && str1=='' && str3=='' && str2=='' && str4=='' && str5==''){
			  Opportunity opts8=new Opportunity();
			  opts8.id=lsOPT.Id;
			  opts8.Specialty_BU_Products__c='';
			  listOppsToUpdate.add(opts8);
			  }
             }
           
        if (!listOppsToUpdate.isEmpty()) {
           TriggerExecutionController.setSkipOpportunityTriggers(true);  
            update listOppsToUpdate;
           TriggerExecutionController.setSkipOpportunityTriggers(false);  
             }
           } 
      }