/*
Author: Ranjini

History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0      24-FEB-2011    Ranjini       	Created for Partner Management module of VIPER-I
2.0      21-Jun-2011    Ranjini       	updated for CR :6264,6265 .VIPER -II
3.0		 05-Dec-2012	Krishnamoorthi	updated for R14.2 Maintenance CR 7740 Viper – Correct MDF Calculation for Forecast when Outlook is zero
*/
public class PlanBreakOutUpdate {
    
    public static void method_Plan_Breakout(Set <Id> vendors,List<Volume_Based_Forecast__c> vBFCList){
        
        try{
            Decimal plan_Breakout_CSMR,plan_Breakout_LE,plan_Breakout_PUB,plan_Breakout_SMB;   
            Map<Id,List<Associated_Programs_Vendors__c>> vendorAPVMap=new Map<Id,List<Associated_Programs_Vendors__c>>();
            for(Associated_Programs_Vendors__c apvElt: [Select Id,Vendor__c ,Status__c,Business_Segment__c,Budgeted_Price__c,MP_Region__c,POP_Status_Reason__c,
                                                        MP_Fiscal_Quarter__c,MP_Contract_Type__c,Marketing_Plan__r.Contract_Type__c,CSMR__c,POP_Status__c,
                                                        LE__c,PUB__c,SMB__c from Associated_Programs_Vendors__c where Vendor__c IN:vendors and 
                                                        MP_Contract_Type__c ='Volume Based' and Status__c!='Declined' and ((POP_Status__c='Not Executed'and POP_Status_Reason__c='Vendor Absent – Charge')
                                                        OR((NOT(POP_Status__c='Replaced')) AND (NOT(POP_Status__c='Not Executed'))))]){
                                                  
               		if(vendorAPVMap.containsKey(apvElt.Vendor__c)) {
                        vendorAPVMap.get(apvElt.Vendor__c).add(apvElt);
                    }else{
                        vendorAPVMap.put(apvElt.Vendor__c,new List<Associated_Programs_Vendors__c>{apvElt});            
                    }                                                           
            } 
                
            if(vendorAPVMap.size()>0){
        
                String vBFC_Region;
                String vBFC_Quarter;
            
                for(Volume_Based_Forecast__c vBFC: vBFCList){
                    
                    vBFC_Region = vBFC.Region__c; 
                    vBFC_Quarter = vBFC.Fiscal_Quarter__c;
                    plan_Breakout_CSMR=plan_Breakout_LE=plan_Breakout_PUB=plan_Breakout_SMB=0;
                    List<Associated_Programs_Vendors__c> apvList=vendorAPVMap.get(vBFC.Sub_Vendor__c);
                
                    for(Associated_Programs_Vendors__c apv :apvList){
                        
                        if(apv.MP_Region__c==vBFC_Region && apv.MP_Fiscal_Quarter__c ==vBFC_Quarter && apv.Vendor__c ==vBFC.Sub_Vendor__c && apv.Status__c!='Declined'){
                            
                            if(apv.CSMR__c!=null)
                                plan_Breakout_CSMR = plan_Breakout_CSMR + apv.CSMR__c; // caluating vbf CSMR
                            if(apv.LE__c!=null)
                                plan_Breakout_LE = plan_Breakout_LE + apv.LE__c; // caluating vbf LE
                            if(apv.PUB__c!=null)
                                plan_Breakout_PUB = plan_Breakout_PUB + apv.PUB__c; // caluating vbf PUB
                            if(apv.SMB__c!=null)
                                plan_Breakout_SMB = plan_Breakout_SMB + apv.SMB__c; // caluating vbf SMB
                        }
                        
                    }// end of apvList for loop
                
                    //Assign plan break out values (CSMR,LE,PUB,SMB)            
                    vBFC.Plan_Breakout_CSMR__c = plan_Breakout_CSMR;
                    vBFC.Plan_Breakout_LE__c = plan_Breakout_LE;
                    vBFC.Plan_Breakout_PUB__c = plan_Breakout_PUB;
                    vBFC.Plan_Breakout_SMB__c = plan_Breakout_SMB;                     
                            
                }// end of vBFC loop
        	}
    	}
    	Catch(Exception e){
      	}
    }
    
    public static void method_outlook_values(Set <Id> vendorIds,List<Volume_Based_Forecast__c> vBFCList){
        try{    	
        	String unique1,unique2,unique3,unique4,uniqueString;
        	Outlook_Forecast_Line_Item__c oFL_Item = new Outlook_Forecast_Line_Item__c();       	
            Map<String,Outlook_Forecast_Line_Item__c> vendorOLMap=new Map<String,Outlook_Forecast_Line_Item__c> ();
            for(Outlook_Forecast_Line_Item__c olElt:[Select Id,CSMR__c,LE__c,PUB__c,SMB__c,Vendor__c,Outlook_Forecast__r.Category__c,Outlook_Forecast__r.Region__c,Outlook_Forecast__r.Fiscal_Quarter__c from Outlook_Forecast_Line_Item__c where Vendor__c IN:vendorIds]){	
				uniqueString = olElt.Vendor__c +':'+ olElt.Outlook_Forecast__r.Region__c +':'+ olElt.Outlook_Forecast__r.Fiscal_Quarter__c +':'+olElt.Outlook_Forecast__r.Category__c;
				vendorOLMap.put(uniqueString, olElt);
																		
			}			
			if(vendorOLMap.size()>0){
				for(Volume_Based_Forecast__c vBFC:vBFCList){
					unique1=vBFC.Sub_Vendor__c+':'+vBFC.Region__c+':'+vBFC.Fiscal_Quarter__c+':Outlook 1';
					unique2=vBFC.Sub_Vendor__c+':'+vBFC.Region__c+':'+vBFC.Fiscal_Quarter__c+':Outlook 2';
					unique3=vBFC.Sub_Vendor__c+':'+vBFC.Region__c+':'+vBFC.Fiscal_Quarter__c+':Final Outlook';
					unique4=vBFC.Sub_Vendor__c+':'+vBFC.Region__c+':'+vBFC.Fiscal_Quarter__c+':Final Invoice Amount';
					
					oFL_Item=vendorOLMap.get(unique1);
					
					//Rev 3.0 changes -- Commented the null check for the below fields to take blank values also
					if(oFL_Item!=null){
							vBFC.Outlook_1_CSMR__c = oFL_Item.CSMR__c;
							vBFC.Outlook_1_LE__c = oFL_Item.LE__c;
							vBFC.Outlook_1_PUB__c = oFL_Item.PUB__c;
							vBFC.Outlook_1_SMB__c = oFL_Item.SMB__c;
					}
					oFL_Item=vendorOLMap.get(unique2);
					if(oFL_Item!=null){
							vBFC.Outlook_2_CSMR__c = oFL_Item.CSMR__c;
							vBFC.Outlook_2_LE__c = oFL_Item.LE__c;
							vBFC.Outlook_2_PUB__c = oFL_Item.PUB__c;
							vBFC.Outlook_2_SMB__c = oFL_Item.SMB__c;
					}
					oFL_Item=vendorOLMap.get(unique3);
					if(oFL_Item!=null){
							vBFC.Final_Outlook_CSMR__c = oFL_Item.CSMR__c;
							vBFC.Final_Outlook_LE__c = oFL_Item.LE__c;
							vBFC.Final_Outlook_PUB__c = oFL_Item.PUB__c;
							vBFC.Final_Outlook_SMB__c = oFL_Item.SMB__c;
					}
					oFL_Item=vendorOLMap.get(unique4);
					if(oFL_Item!=null){
							vBFC.Invoice_Amount_CSMR__c = oFL_Item.CSMR__c;
							vBFC.Invoice_Amount_LE__c = oFL_Item.LE__c;
							vBFC.Invoice_Amount_PUB__c= oFL_Item.PUB__c;
							vBFC.Invoice_Amount_SMB__c = oFL_Item.SMB__c;
					}
					
				}
			} 
        
    	}
    	Catch(Exception e){
      	}
    }
    
    public static void method_plan_breakout_for_alacarte(Set <Id> vendors,List<Volume_Based_Forecast__c> vBFCList){
        System.debug('hiiiii->i m here');
        try{
        
        Decimal alacarte_plan_Breakout_CSMR,alacarte_plan_Breakout_LE,alacarte_plan_Breakout_PUB,alacarte_plan_Breakout_SMB,alacarte_plan_Breakout_ABU_SP,alacarte_plan_Breakout_Global_Mktg,alacarte_plan_Breakout_ASAP,alacarte_plan_Breakout_CSRM_SP,alacarte_plan_Breakout_Corporate_Events,alacarte_plan_Breakout_Intl,alacarte_plan_Breakout_SMB_Direct,alacarte_plan_Breakout_SMB_Channel,alacarte_plan_Breakout_All_Segments;
                
        Map<Id,List<Associated_Programs_Vendors__c>> vendorAPVMap=new Map<Id,List<Associated_Programs_Vendors__c>>();
        
        for(Associated_Programs_Vendors__c apvElt: [Select Id,Vendor__c ,Region__c,Status__c,Business_Segment__c,Budgeted_Price__c,MP_Region__c,POP_Status__c,
                                                        MP_Fiscal_Quarter__c,MP_Contract_Type__c,Marketing_Plan__r.Contract_Type__c,CSMR__c,POP_Status_Reason__c,
                                                        LE__c,PUB__c,SMB__c from Associated_Programs_Vendors__c where Vendor__c IN:vendors and 
                                                        MP_Contract_Type__c ='Ala Carte' and Status__c!='Declined' and MDF_Program__r.Program_Type__c!='Headcount' and ((POP_Status__c='Not Executed'and POP_Status_Reason__c='Vendor Absent – Charge')OR((NOT(POP_Status__c='Replaced')) AND (NOT(POP_Status__c='Not Executed'))))]){
                                                            
                        if(vendorAPVMap.containsKey(apvElt.Vendor__c)) {
                            vendorAPVMap.get(apvElt.Vendor__c).add(apvElt);
                        }else{
                            vendorAPVMap.put(apvElt.Vendor__c,new List<Associated_Programs_Vendors__c>{apvElt});            
                        }
                                                            
        } 
        if(vendorAPVMap.size()>0){
            
            for(Volume_Based_Forecast__c vBFC: vBFCList){
                alacarte_plan_Breakout_CSMR=alacarte_plan_Breakout_LE=alacarte_plan_Breakout_PUB=alacarte_plan_Breakout_SMB=alacarte_plan_Breakout_ABU_SP=alacarte_plan_Breakout_Global_Mktg=alacarte_plan_Breakout_ASAP=alacarte_plan_Breakout_CSRM_SP=alacarte_plan_Breakout_Corporate_Events=alacarte_plan_Breakout_Intl=alacarte_plan_Breakout_SMB_Direct=alacarte_plan_Breakout_SMB_Channel=alacarte_plan_Breakout_All_Segments=0;
                        
                for(Associated_Programs_Vendors__c apv :vendorAPVMap.get(vBFC.Sub_Vendor__c)){
                    
                    if(apv.MP_Region__c==vBFC.Region__c && apv.MP_Fiscal_Quarter__c ==vBFC.Fiscal_Quarter__c && apv.Vendor__c ==vBFC.Sub_Vendor__c ){
                        
                            if(apv.CSMR__c!=null||apv.LE__c!=null||apv.PUB__c!=null||apv.SMB__c!=null){
                                if(apv.CSMR__c!=null)alacarte_plan_Breakout_CSMR = alacarte_plan_Breakout_CSMR+apv.CSMR__c;
                                if(apv.LE__c!=null)alacarte_plan_Breakout_LE= alacarte_plan_Breakout_LE+apv.LE__c;
                                if(apv.PUB__c!=null)alacarte_plan_Breakout_PUB= alacarte_plan_Breakout_PUB+apv.PUB__c;
                                if(apv.SMB__c!=null &&(apv.Region__c=='APJ'||apv.Region__c=='Americas'))alacarte_plan_Breakout_SMB= alacarte_plan_Breakout_SMB+apv.SMB__c;
                            }
                            else if(vBFC.Region__c=='Americas'){
                                if(apv.Business_Segment__c=='ABU S&P')
                                    alacarte_plan_Breakout_ABU_SP=alacarte_plan_Breakout_ABU_SP+apv.Budgeted_Price__c;
                                else if(apv.Business_Segment__c=='Global Mktg')
                                    alacarte_plan_Breakout_Global_Mktg = alacarte_plan_Breakout_Global_Mktg+apv.Budgeted_Price__c;
                                else if(apv.Business_Segment__c=='ASAP')
                                    alacarte_plan_Breakout_ASAP = alacarte_plan_Breakout_ASAP+apv.Budgeted_Price__c;
                                else if(apv.Business_Segment__c=='CSRM S&P')
                                    alacarte_plan_Breakout_CSRM_SP = alacarte_plan_Breakout_CSRM_SP+apv.Budgeted_Price__c;
                                else if(apv.Business_Segment__c=='Corporate Events')
                                    alacarte_plan_Breakout_Corporate_Events = alacarte_plan_Breakout_Corporate_Events + apv.Budgeted_Price__c;
                                else if(apv.Business_Segment__c=='Int\'l')
                                    alacarte_plan_Breakout_Intl = alacarte_plan_Breakout_Intl + apv.Budgeted_Price__c;
                            }
                           else if(vBFC.Region__c=='EMEA'){
                                if(apv.Business_Segment__c=='SMB Direct')
                                    alacarte_plan_Breakout_SMB_Direct = alacarte_plan_Breakout_SMB_Direct +apv.Budgeted_Price__c;
                                if(apv.Business_Segment__c=='SMB Channel')
                                    alacarte_plan_Breakout_SMB_Channel = alacarte_plan_Breakout_SMB_Channel+apv.Budgeted_Price__c;
                                if(apv.Business_Segment__c=='All Segments')
                                    alacarte_plan_Breakout_All_Segments = alacarte_plan_Breakout_All_Segments + apv.Budgeted_Price__c;
                           }
                    }
                    
                }
                
                vBFC.AlaCarte_Plan_Breakout_CSMR__c = alacarte_plan_Breakout_CSMR;
                vBFC.AlaCarte_Plan_Breakout_LE__c = alacarte_plan_Breakout_LE;
                vBFC.AlaCarte_Plan_Breakout_PUB__c = alacarte_plan_Breakout_PUB;
                vBFC.AlaCarte_Plan_Breakout_SMB__C = alacarte_plan_Breakout_SMB;
                vBFC.AlaCarte_Plan_Breakout_ABU_S_P__c = alacarte_plan_Breakout_ABU_SP;
                vBFC.AlaCarte_Plan_Breakout_Global_Mktg__c = alacarte_plan_Breakout_Global_Mktg;
                vBFC.AlaCarte_Plan_Breakout_ASAP__c = alacarte_plan_Breakout_ASAP;
                vBFC.AlaCarte_Plan_Breakout_CSRM_S_P__c = alacarte_plan_Breakout_CSRM_SP;
                vBFC.AlaCarte_Plan_Breakout_Corporate_Events__c = alacarte_plan_Breakout_Corporate_Events;
                vBFC.AlaCarte_Plan_Breakout_Int_l__c = alacarte_plan_Breakout_Intl;
                vBFC.AlaCarte_Plan_Breakout_SMB_Direct__c = alacarte_plan_Breakout_SMB_Direct;
                vBFC.AlaCarte_Plan_Breakout_SMB_Channel__c = alacarte_plan_Breakout_SMB_Channel;
                vBFC.AlaCarte_Plan_Breakout_All_Segments__c = alacarte_plan_Breakout_All_Segments;
            }
         }           
        }
        catch(Exception e){ 
            
        }
    }
    
    public static List<Associated_Programs_Vendors__c> get_apv_list(Volume_Based_Forecast__c FCrecord,String statusvalue){
        
        VfCtrl_ViperSOQLMethod_Utility ViperSOQLMethod= new VfCtrl_ViperSOQLMethod_Utility();
        List<Associated_Programs_Vendors__c> apvList;
        RecordType ACFCRtId = [Select Id from RecordType where SobjectType='Volume_Based_Forecast__c' and Name ='Ala Carte'];
        RecordType VBFCRtId = [Select Id from RecordType where SobjectType='Volume_Based_Forecast__c' and Name ='Volume Based'];
        
        if(FCrecord.RecordTypeId==ACFCRtId.id){
            if(statusvalue!='Declined'){
                apvList = database.query(ViperSOQLMethod.getQueryMethod2(new Associated_Programs_Vendors__c(),'PlanBreakOutUpdate') + ' where Vendor__c=\''+FCrecord.Sub_Vendor__c+'\' and MP_Fiscal_Quarter__c=\''+FCrecord.Fiscal_Quarter__c+'\' and MP_Region__c=\''+FCrecord.Region__c+'\' and MP_Contract_Type__c =\'Ala Carte\' and Status__c!=\'Declined\' and ((POP_Status__c=\'Not Executed\'and POP_Status_Reason__c=\'Vendor Absent – Charge\')OR((NOT(POP_Status__c=\'Replaced\')) AND (NOT(POP_Status__c=\'Not Executed\'))))and MDF_Program__r.Program_Type__c!=\'Headcount\'Order By Status__c,Business_Segment__c');
                           
            }
            else
                apvList = database.query(ViperSOQLMethod.getQueryMethod2(new Associated_Programs_Vendors__c(),'PlanBreakOutUpdate') + ' where Vendor__c=\''+FCrecord.Sub_Vendor__c+'\' and MP_Fiscal_Quarter__c=\''+FCrecord.Fiscal_Quarter__c+'\' and MP_Region__c=\''+FCrecord.Region__c+'\' and MP_Contract_Type__c =\'Ala Carte\' and Status__c=\'Declined\' Order By Business_Segment__c');
                          
        }
        
        if(FCrecord.RecordTypeId==VBFCRtId.id){
            if(statusvalue!='Declined'){
                apvList = database.query(ViperSOQLMethod.getQueryMethod2(new Associated_Programs_Vendors__c(),'PlanBreakOutUpdate') + ' where Vendor__c=\''+FCrecord.Sub_Vendor__c+'\' and MP_Fiscal_Quarter__c=\''+FCrecord.Fiscal_Quarter__c+'\' and MP_Region__c=\''+FCrecord.Region__c+'\' and MP_Contract_Type__c =\'Volume Based\' and Status__c!=\'Declined\'and ((POP_Status__c=\'Not Executed\'and POP_Status_Reason__c=\'Vendor Absent – Charge\')OR((NOT(POP_Status__c=\'Replaced\')) AND (NOT(POP_Status__c=\'Not Executed\')))) Order By Status__c,Business_Segment__c');
                       
            }
            else
                apvList = database.query(ViperSOQLMethod.getQueryMethod2(new Associated_Programs_Vendors__c(),'PlanBreakOutUpdate') + ' where Vendor__c=\''+FCrecord.Sub_Vendor__c+'\' and MP_Fiscal_Quarter__c=\''+FCrecord.Fiscal_Quarter__c+'\' and MP_Region__c=\''+FCrecord.Region__c+'\' and MP_Contract_Type__c =\'Volume Based\' and Status__c=\'Declined\' Order By Business_Segment__c');
                        
        }
        
        return apvList;
    }
    
    public static List<MDF_Program_Wish_List__c> get_wish_list(Volume_Based_Forecast__c FCrecord){
        List<MDF_Program_Wish_List__c> wishlist;
        wishlist =[Select Id,Name,MDF_Program__c,MDF_Forecast__c,MDF_Program__r.Region__c,MDF_Program__r.Sub_Region__c,MDF_Program__r.Country__c,MDF_Program__r.Business_Segment__c,MDF_Program__r.Rate_Card_Price__c,MDF_Program__r.Fiscal_Quarter__c from MDF_Program_Wish_List__c where MDF_Forecast__c=:FCrecord.Id];
        return wishlist;
    }
    
}