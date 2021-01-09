/*****************************************************************************************
* Name          : ProtectedDealInsertCtrl
* Description   : Code to insert opportunity of protected deal record type
* -------------------------------------------------------------------------
* Revision  Name     Date        Description
* 1.0       Hanan    25.09.2010  CR 3446 insert opportunity of protected deal record type
* 2.0       Meghana  20.12.2013  CR 8973 - Remove use of field Verifiable_Outcome__c
* 3.0       Hari A   12.12.2018  STORY 5907651 Removed reference for the fields protected_partner_account__c
* 4.0       Emily    08.01.2019  CR 16970 - Comment protected_account__c, virtualization__c      
******************************************************************************************/
public class ProtectedDealInsertCtrl{
        
        Boolean displayErrorMsg=false;
        Boolean displayProtectedDealName=false;        
        Double INSERT_LIST_SIZE_LIMIT=100;
        
        String opportunityId;
        String protectedDealName;        
        
        Opportunity opportunityObject;
        Opportunity protectedDealOpportunityObject=new Opportunity();            
        OpportunityLineItem opportunityLineItemInsertObject;
                
        List<Opportunity> protectedDealOpportunity;

        //constructor
        public ProtectedDealInsertCtrl(ApexPages.StandardController controller){        
            protectedDealOpportunity=new List<Opportunity>();
            opportunityId=controller.getId();
            opportunityObject=(Opportunity)controller.getRecord();
            opportunityObject=[Select Type, Total_of_End_of_User_Employees__c, Total_Expected_Dell_Revenue__c, StageName, Source_System__c, 
                            Solution_Type__c, Solution_Scope__c, Solution_Name__c, RecordTypeId, Proposal_Due_Date__c, Primary_Competitor__c, 
                            Payment_Type__c,Partner_Won_Lost_Comment__c, Partner_Type__c, Partner_Sales_Rep_Name__c, Partner_Sales_Rep_Email__c, 
                            Partner_Reason_Won_Lost__c,Partner_Opportunity_Stage__c, Partner_Competitor_Lost_To__c, PartnerAccountId, 
                            Parent_Opportunity__c,OwnerId, Name,Justification_Statement__c, Is_the_Customer_Part_of_a_Larger_Group__c, Id, 
                            Fiscal_Book_Date__c,Engagement_Type__c,End_User_Website_URL_Address__c, End_User_Title__c, End_User_Registration_Tax_Code__c, 
                            End_User_Phone__c, End_User_Mobile__c,End_User_Mailing_Zip_Postal_Code__c, End_User_Mailing_Street__c, End_User_Mailing_State_Province_Region__c,
                            End_User_Mailing_Country__c,End_User_Mailing_City__c, End_User_Last_Name__c, End_User_First_Name__c, End_User_Fax__c, End_User_Email__c, 
                            End_User_Account_Name__c,End_User_Account_Industry__c, End_User_Account_ID__c, End_User_Account_Department__c, Distributor_ID__c, 
                            Dell_Systems_and_Services__c, Deal_Registration_Status__c, Deal_Reg_Oppty__c, Deal_Expiration_Timeframe__c, Deal_Expiration_Date__c, 
                            CurrencyIsoCode, CloseDate, AccountId,OS_Type__c,Primary_Product_Delivery_Address_Region__c,
                            Primary_Product_Delivery_Address_Country__c,//Verifiable_Outcome__c , ...CR 8973
                            PartnerAccount.Is_GTM_Partner__c,PartnerAccount.Partner_Relationship__c,
                            Submission_Status_2__c,Submission_Status_3__c From Opportunity where id=:opportunityObject.id limit 1];
            
            try{                                                            
                protectedDealOpportunity=[Select name,Parent_Opportunity__c from opportunity where 
                                        Parent_Opportunity__c=:opportunityId limit 1]; 
            }catch(Exception e){
            }           
        
        }


        public  void createProtectedDeal(){
            Integer chunkSize = 200;
            Integer queryRowLimit = Limits.getLimitQueryRows();
             
            Double unitPriceDbl=0;
            Double quantityDbl=1; 
            Double MrgnDbl=0;
            Double lobRegRecordCntOfDirectAccount=0;
            Database.SaveResult[] results;
            
            Opportunity OpportunityInsertObject;
            
            List<OpportunityLineItem>  OpportunityLineItemListOfParent=new List<OpportunityLineItem>();
            List<OpportunityLineItem>  OpportunityLineItemListOfChild=new List<OpportunityLineItem>();
            
            RecordType opptyrectype=[Select Name,Id From RecordType where Name='Protected Deal' Limit 1];
            
            queryRowLimit = queryRowLimit - Math.Mod(queryRowLimit, chunkSize); 

            if(protectedDealOpportunity.size()==0){
                /* In the if loop  check whether the opportunity already has a protected deal.If not create one provided opportunity satisfies all  
                the conditions. If it has a protected deal display message to user.
                */            

                System.debug('###stagename'+opportunityObject.stagename);
                System.debug('###Deal_Reg_Oppty'+opportunityObject.Deal_Reg_Oppty__c);
                System.debug('###is gtm partner'+opportunityObject.PartnerAccount.Is_GTM_Partner__c);
                System.debug('###Partner_Relationship'+opportunityObject.PartnerAccount.Partner_Relationship__c);              

                if(opportunityObject.stagename=='Win - 100%' && opportunityObject.Deal_Reg_Oppty__c=='Yes' && 
                opportunityObject.PartnerAccount.Is_GTM_Partner__c==false && opportunityObject.PartnerAccount.Partner_Relationship__c=='Certified'){     

                    //checking whether products of opportunity has family='enterprise'
                     if(!Test.isRunningTest()){
                    lobRegRecordCntOfDirectAccount=[Select count() from LOB_Registration__c ];
                    }
                    if(lobRegRecordCntOfDirectAccount==0){
                        for(OpportunityLineItem  oli:[Select  Id,PricebookEntry.Product2.Family,opportunityId,UnitPrice,quantity,pricebookentryid ,Mrgn__c
                        from OpportunityLineItem  where opportunityId =:opportunityObject.id and PricebookEntry.Product2.Family='Enterprise']){     
                          
                            OpportunityLineItemListOfParent.add(oli);                    
                        }   
                    }                  
                                    
                }else{
                    displayErrorMsg=true;
                    displayProtectedDealName=false;
                }              

                

                if(OpportunityLineItemListOfParent.size()>0){
                // protected deal opportunity object with values copied from parent opportunity
                    OpportunityInsertObject=new Opportunity(
                        Type=opportunityObject.Type,Total_of_End_of_User_Employees__c=opportunityObject.Total_of_End_of_User_Employees__c,
                        Total_Expected_Dell_Revenue__c=opportunityObject.Total_Expected_Dell_Revenue__c, StageName='Plan - 1%', 
                        Source_System__c=opportunityObject.Source_System__c,Solution_Type__c=opportunityObject.Solution_Type__c,
                        Solution_Scope__c=opportunityObject.Solution_Scope__c, Solution_Name__c=opportunityObject.Solution_Name__c, 
                        RecordTypeId=opptyrectype.id, Proposal_Due_Date__c=opportunityObject.Proposal_Due_Date__c,
                        Primary_Competitor__c=opportunityObject.Primary_Competitor__c,Payment_Type__c=opportunityObject.Payment_Type__c,
                        Partner_Won_Lost_Comment__c=opportunityObject.Partner_Won_Lost_Comment__c, Partner_Type__c=opportunityObject.Partner_Type__c,
                        Partner_Sales_Rep_Name__c=opportunityObject.Partner_Sales_Rep_Name__c,
                        Partner_Sales_Rep_Email__c=opportunityObject.Partner_Sales_Rep_Email__c, Partner_Reason_Won_Lost__c=opportunityObject.Partner_Reason_Won_Lost__c, 
                        Partner_Opportunity_Stage__c=opportunityObject.Partner_Opportunity_Stage__c, Partner_Competitor_Lost_To__c=opportunityObject.Partner_Competitor_Lost_To__c,
                        Parent_Opportunity__c=opportunityObject.id, OwnerId=opportunityObject.OwnerId, Name=opportunityObject.Name,
                        Justification_Statement__c=opportunityObject.Justification_Statement__c, Is_the_Customer_Part_of_a_Larger_Group__c=opportunityObject.Is_the_Customer_Part_of_a_Larger_Group__c, 
                        Engagement_Type__c=opportunityObject.Engagement_Type__c, 
                        End_User_Website_URL_Address__c=opportunityObject.End_User_Website_URL_Address__c, End_User_Title__c=opportunityObject.End_User_Title__c,
                        End_User_Registration_Tax_Code__c=opportunityObject.End_User_Registration_Tax_Code__c, 
                        End_User_Phone__c=opportunityObject.End_User_Phone__c, End_User_Mobile__c=opportunityObject.End_User_Mobile__c, 
                        End_User_Mailing_Zip_Postal_Code__c=opportunityObject.End_User_Mailing_Zip_Postal_Code__c, End_User_Mailing_Street__c=opportunityObject.End_User_Mailing_Street__c,
                        End_User_Mailing_State_Province_Region__c=opportunityObject.End_User_Mailing_State_Province_Region__c, End_User_Mailing_Country__c=opportunityObject.End_User_Mailing_Country__c, 
                        End_User_Mailing_City__c=opportunityObject.End_User_Mailing_City__c, End_User_Last_Name__c=opportunityObject.End_User_Last_Name__c, 
                        End_User_First_Name__c=opportunityObject.End_User_First_Name__c, 
                        End_User_Fax__c=opportunityObject.End_User_Fax__c, End_User_Email__c=opportunityObject.End_User_Email__c, 
                        End_User_Account_Name__c=opportunityObject.End_User_Account_Name__c,
                        End_User_Account_Industry__c=opportunityObject.End_User_Account_Industry__c, End_User_Account_ID__c=opportunityObject.End_User_Account_ID__c, 
                        End_User_Account_Department__c=opportunityObject.End_User_Account_Department__c, 
                        Distributor_ID__c=opportunityObject.Distributor_ID__c,
                        Dell_Systems_and_Services__c=opportunityObject.Dell_Systems_and_Services__c, Deal_Registration_Status__c='New', 
                        Deal_Expiration_Timeframe__c='180', Deal_Expiration_Date__c=System.Today()+180, 
                        CurrencyIsoCode=opportunityObject.CurrencyIsoCode, CloseDate=System.Today(), 
                        AccountId=opportunityObject.AccountId,OS_Type__c=opportunityObject.OS_Type__c, 
                        //4.0 Virtualization__c=opportunityObject.Virtualization__c,
                        Primary_Product_Delivery_Address_Region__c=opportunityObject.Primary_Product_Delivery_Address_Region__c,
                        Primary_Product_Delivery_Address_Country__c=opportunityObject.Primary_Product_Delivery_Address_Country__c,
                        //Verifiable_Outcome__c=opportunityObject.Verifiable_Outcome__c, ...CR 8973
                        How_many_shipments__c=1,
                        Submission_Status_2__c='Protected deal will be open for 180 days, please submit it to avail a special discount.'+ 
                            'Protected deals will expire within 180 days of creation',
                        Submission_Status_3__c='Protected deal will be open for 180 days, please submit it to avail a special discount.'+ 
                            'Protected deals will expire within 180 days of creation',
                        //4.0 Protected_Account__c=opportunityObject.AccountId,
                        Deal_Created_Date_Time__c=System.Today()
                    );
                    insert OpportunityInsertObject;               
                    protectedDealOpportunityObject=OpportunityInsertObject;
                       
                    // products being added to protected deal opportunity with family='enterprise'
                    for(OpportunityLineItem oliObject:OpportunityLineItemListOfParent){
                        opportunityLineItemInsertObject=new OpportunityLineItem(opportunityid=OpportunityInsertObject.Id,
                            UnitPrice=unitPriceDbl,
                            quantity=quantityDbl, 
                            Mrgn__c=MrgnDbl,
                            pricebookentryid=oliObject.pricebookentryid,
                            Service_Support_US__c='Not applicable'
                        );
                        
                        OpportunityLineItemListOfChild.add(opportunityLineItemInsertObject);
                        
                        if(OpportunityLineItemListOfChild.size()==INSERT_LIST_SIZE_LIMIT){ 
                            results=Database.insert(OpportunityLineItemListOfChild, false); 
                            OpportunityLineItemListOfChild.clear();
                        }
                        
                    }
                    if(OpportunityLineItemListOfChild.size()>0 && OpportunityLineItemListOfChild.size()<INSERT_LIST_SIZE_LIMIT){
                        results=Database.insert(OpportunityLineItemListOfChild, false);               
                        //protectedDealName= OpportunityInsertObject.name;
                        displayProtectedDealName=true;                      
                    }                   
                    
                }else{
                    displayErrorMsg=true;
                    displayProtectedDealName=false;
                } 
            
            }else{
                displayErrorMsg=true;
                displayProtectedDealName=false;
            }

        }

        public Opportunity getProtectedDeal(){          
            return protectedDealOpportunityObject;
        }

        public Boolean getErrorMessage(){
            return displayErrorMsg;
        }

        public Boolean getDisplayProtectedDealName(){
            return displayProtectedDealName;
        }

        public PageReference backButton(){
            return new PageReference('/'+opportunityId);
        }

    }