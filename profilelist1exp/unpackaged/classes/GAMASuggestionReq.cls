/*
 * @Author      : Prasanthi Mandava
 * Created Date : 1/4/2019
 * Purpose      : To create request body to send to affinity for the creation of Partner Account, 
 *                whenever send DST Suggestion link was clicked in Lead detail page
 * 
 */
Public class GAMASuggestionReq {
    Public String toDateInString{get;set;}
    public GAMASuggestionReq(){
        toDateInString = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss');
    }
    /*Address Information Class*/ 
    public class AddressInformation {
        public String addressLine1 {get;set;} 
        public String addressLine2 {get;set;} 
        public Integer addressType {get;set;}
        public String city {get;set;}
        public String companyName {get;set;}
        public String countryCode {get;set;}
        public String postalCode {get;set;}
        public String state {get;set;}
        public AddressInformation(String aL1,String aL2,Integer addressType,String city,
                                  String companyName,String countryCode,String postalCode,String state) {
            this.addressLine1 = aL1;
            this.addressLine2= aL2;
            this.addressType = addressType;
            this.city = city;
            this.companyName = companyName;
            this.countryCode = countryCode;
            this.postalCode = postalCode;
            this.state = state;
         }
    }
    /*Master Group information class*/
    public class MasterGroupInformation{
        public Long masterGroupId{get;set;}
        public String masterGroupName{get;set;}
        public String masterGroupLocalName{get;set;}
        public String partnerMasterGroupingID{get;set;}
        public Integer numberOfBranchSubsidiaries{get;set;}
        public Integer guDunsNumber{get;set;}
        public String webSite{get;set;}
        public List<AddressInformation> addressInformation {get;set;}               
        public  MasterGroupInformation(Lead leadRec){
            if(leadRec.Master_Group_Affinity_ID__c!=Null){
                this.masterGroupId = Long.valueOf((leadRec.Master_Group_Affinity_ID__c).replace(',',''));
            }else{
                     //this.masterGroupId = 0;
                    List<AddressInformation> addressInformationLocal = new List<AddressInformation>();
                    this.masterGroupName = leadRec.Mg_Name__c;
                    this.masterGroupLocalName = leadRec.Mg_Local_Name__c;
                    if(leadRec.Number_of_Branches_Subsidiaries__c!=null){
                        this.numberOfBranchSubsidiaries = Integer.ValueOf(leadRec.Number_of_Branches_Subsidiaries__c);
                    }
                    if(leadRec.GU_Duns_number__c!=Null){
                        this.guDunsNumber = Integer.ValueOf(leadRec.GU_Duns_number__c);
                    }
                    this.webSite = leadRec.Mg_Website__c;
                    AddressInformation ai = new AddressInformation(leadRec.Mg_Address_Line_1__c,leadRec.Mg_Address_Line_2__c,0,
                                                                   leadRec.Mg_City__c,leadRec.Mg_Name__c,leadRec.Mg_Country_Code__c,leadRec.Mg_Postal_Code__c,
                                                                   leadRec.Mg_State__c);                
                   
                   //New logic Added
                    AddressInformation aiLocal = new AddressInformation(leadRec.Mg_Local_Address_Line_1__c,leadRec.Mg_Local_Address_Line_2__c,2,
                                                           leadRec.Mg_Local_City__c,leadRec.Mg_Local_Name__c,leadRec.Mg_Country_Code__c, //leadRec.Mg_Local_Country_Name__c,
                                                           leadRec.Mg_Local_Postal_Code__c,leadRec.Mg_Local_State__c);
           
            
            if(aiLocal.companyName == null && aiLocal.addressLine1== null
                                  && aiLocal.City== null && aiLocal.postalCode== null && aiLocal.state== null ){
                    addressInformationLocal.add(ai);                  
                 //this.addressInformation    = new List<AddressInformation>{ai};                   
                
            }else{
                if(aiLocal.addressLine1 == null && aiLocal.City == null && aiLocal.postalCode == null && aiLocal.state == null){
                    addressInformationLocal.add(ai);
                  //addressInformationLocal.add(aiLocal);
                }
                else{
                     addressInformationLocal.add(ai);
                  addressInformationLocal.add(aiLocal);
                }
                
               //this.addressInformation      = new List<AddressInformation>{ai,aiLocal}; 
            }
            this.addressInformation = addressInformationLocal;                     
                                         
                    
                }
            }
     }
    /*Track Information class*/
    public class TrackInformation{
        public Integer trackId{get;set;}
        public TrackInformation(Lead leadRec){
            if(leadRec.Track_Affinity_ID__c!=null){
                this.trackId =Integer.valueOf(leadRec.Track_Affinity_ID__c);
            }
         }
    }
    /*Partner Track Information class*/
    public class PartnerTrackInformation{
        public Long masterGroupId{get;set;}
        public Long partnerTrackId{get;set;}
        public String distributorAuthorizedCountries{get;set;}
        public String disableRounding{get;set;}
        public String distributionAllCountryPrice{get;set;}
        public String distributionIncumbentPartner{get;set;}
        public String enabledForServices{get;set;}
        public String partnerProfiledAccountUCID{get;set;}
        public String partnerProfiledAccountFlag{get;set;}
        public String partnerProgramTier{get;set;}
        public String purchasePath{get;set;}
        public String specialityProductPurchasePath{get;set;}
        public Integer primarySalesMotionAPID{get;set;}
        public String relationshipType{get;set;}
        public String reportingSegmentation{get;set;}
        public String specialDistributionPricing{get;set;}
        public String specialPartnerRecommendedPricing{get;set;}
        public String dellEmcTermsAndConditionsAggrement{get;set;}
        public String dellEmcTermsAndConditionsAggreedOnDate{get;set;}
        public String vceApprovedVendor{get;set;}
        public String offBoardingReason{get;set;}
        public String partnerRegistrationNumber{get;set;}
        public Integer trackId{get;set;}
        public String partnerTrack{get;set;}
        public String partnerTrackAccountLocalName{get;set;}
        public String partnerGroupingID{get;set;}
        public Long multiTrackParentID{get;set;}
        public String mupCompanyProfileID{get;set;}
        
        public PartnerTrackInformation(Lead leadRec){
            /*if(leadRec.Master_Group_Affinity_ID__c!=Null)
                this.MasterGroupId = Long.valueOf((leadRec.Master_Group_Affinity_ID__c).replace(',',''));*/
            if(leadRec.Partner_Track_Affinity_ID__c!=Null){
                this.partnerTrackId = Long.ValueOf(leadRec.Partner_Track_Affinity_ID__c);
            }else{
                //this.PartnerTrackId = 0;
                this.distributorAuthorizedCountries = leadRec.Distributor_Authorized_Countries__c;
               if(leadRec.Disable_Rounding__c == true){
                    this.disableRounding ='Y';
                }else{
                    this.disableRounding= 'N';
                }
                if(leadRec.Distribution_All_Country_Price__c == true){
                     this.distributionAllCountryPrice = 'Y';
                }else{
                     this.distributionAllCountryPrice = 'N';
                }
                if(leadRec.Distribution_Incumbent_Partner__c == true){
                    this.distributionIncumbentPartner = 'Y';
                }else{
                     this.distributionIncumbentPartner = 'N';
                }
                if(leadRec.Enabled_for_Services__c == true){
                    this.enabledForServices= 'Y';
                }else{
                    this.enabledForServices= 'N';
                }
                if(leadRec.Partner_Profiled_Account_Flag__c == true){
                   this.partnerProfiledAccountFlag = 'Y';
                }
                  else{
                   this.partnerProfiledAccountFlag = 'N';
                }
               // this.partnerProfiledAccountUCID = leadRec.PPA_UCID__c;
                this.partnerProgramTier = leadRec.Partner_Program_Tier__c;
                this.purchasePath = leadRec.Purchase_Path__c;
                this.specialityProductPurchasePath = leadRec.Partner_Storage_Purchasing_Path__c;
                if(LeadRec.Primary_Sales_Motion_Affinity_ID__c!=Null){
                     this.primarySalesMotionAPID = Integer.ValueOf(leadRec.Primary_Sales_Motion_Affinity_ID__c);
                }
                this.relationshipType = leadRec.Relationship_Type__c;
                this.reportingSegmentation = leadRec.Reporting_Segmentation__c;
                if(leadRec.SPL_Distribution_Pricing__c == true){
                    this.specialDistributionPricing = 'Y';
                }else{
                    this.specialDistributionPricing = 'N';
                }
                if(leadRec.SPL_Partner_Recommend_Pricing__c == true){
                    this.specialPartnerRecommendedPricing = 'Y';
                }else{
                    this.specialPartnerRecommendedPricing = 'N';
                }
                this.DellEmcTermsAndConditionsAggrement = 'N';
                this.DellEmcTermsAndConditionsAggreedOnDate = null;
                if(leadRec.VCE_Approved_Partner__c == true){
                    this.vceApprovedVendor= 'Y';
                } else{
                    this.vceApprovedVendor= 'N';
                }
                if(leadRec.Partner_Request__c!=Null){
                    this.partnerRegistrationNumber = leadRec.Partner_Request__r.name;
                }
                if(leadRec.Track_Affinity_ID__c!=Null){
                    this.trackId = Integer.ValueOf(leadRec.Track_Affinity_ID__c);
                }
                this.partnerTrack = leadRec.Partner_Track__c;
                this.partnerTrackAccountLocalName = leadRec.Partner_Track_Account_Local_Name__c;
                if(LeadRec.Multi_Track_Parent_ID__c!=Null){
                    this.multiTrackParentID = Long.valueOf(leadRec.Multi_Track_Parent_ID__c);
                }
                this.mupCompanyProfileID = leadRec.MUP_Company_Profile_ID__c;
            }
        }   
    }
    /*Basic Information class*/
    public class BasicInformation {
        public String accountCategory {get;set;} 
        public String accountName {get;set;} 
        public String accountStatus{get;set;}
        public Integer accountType{get;set;}
        public string countryCode{get;set;}
        public String currency1{get;set;}
        public Integer dmuFlag{get;set;}
        public String functionalCategoryCode{get;set;}
        public Integer gcpFlag{get;set;}
        public Integer globalAccountSubType{get;set;}
        public Integer hierarchyType{get;set;}
        public String marketingClassCode{get;set;}
        public String ndaAgreement{get;set;}
        public String parentAccountID{get;set;}
        public String programType{get;set;}
        public String retailFlag{get;set;}
        public String sicCode{get;set;}
        public String salesModelCode{get;set;}
        public Integer sourceSystemCode{get;set;}
        public String submarketCode{get;set;}
        public String rtm{get;set;}
        public String segmentation{get;set;}
        public Integer channelCompEligibleFlg{get;set;}
        public String salesMotion{get;set;}
        public String accountClassification{get;set;}
        public String partnerQuotingAccount{get;set;}
        public String partnerQuotAccountName{get;set;}
        public String partnerQuotAccntSapUCID{get;set;}
        public String quotingAutoBookEnabled{get;set;}
        public String quotingEpoaFlag{get;set;}
        public String quotingFobIncoterms{get;set;}
        public String quotingFreightTerms{get;set;}
        public String quotingPaymentTerms{get;set;}
        public String globalAlliance{get;set;}
        public String globalAllianceTower{get;set;}
        public String overlayType{get;set;}
        public String resellerTaxID{get;set;}
        public String cfiProjectNumber{get;set;}
        public String companyFoundedDate{get;set;}
        public String finGeo{get;set;}
        public String fiscalYearEnd{get;set;}
        public String legacyID{get;set;}
        public String localAccountName{get;set;}
        public Integer locationNumber{get;set;}
        public String nationalID{get;set;}
        public Integer noOfEmployee{get;set;}
        public String premierPageUrl{get;set;}
        public Integer stdQuoteNumbers{get;set;}
        public String webSiteUrl{get;set;}
        public BasicInformation(Lead leadRec) {
            String legacyId = 'SFDC_' + leadRec.id;
            system.debug('Legacy Id'+legacyId);
            this.accountCategory = leadRec.Account_Category__c;
            this.accountName = leadRec.company;
            this.accountStatus = 'Active';
            //##hard coded value Requesting integer - Previous val is Account 
            this.accountType = 1;
            if(leadRec.Organization_Country__r!=null){
                this.countryCode = leadRec.Organization_Country__r.Code__c;
                this.currency1 = leadRec.Organization_Country__r.User_Currency_Iso_Code__c;
            }
            if(leadRec.DMU_Flag__c){
                this.dmuFlag = 1;
            }
            else{
                this.dmuFlag = 0;
            }
            this.functionalCategoryCode = leadRec.Function_Category_Code__c;
            if(leadRec.NDA_Flag__c){
                this.gcpFlag = 1;
            }
            else{
                this.gcpFlag = 0;
            }
            //##hard coded value
            this.globalAccountSubType = 0;
            //##hard coded value
            this.hierarchyType = 0;
            this.marketingClassCode = leadRec.Marketing_Class_Code__c;
            if(leadRec.NDA_Flag__c == true){
                this.ndaAgreement = 'Y';
            }
            else{
                this.ndaAgreement = 'N';
            }
            //##hard coded value
            this.parentAccountID = null;
            this.programType = leadRec.Program_Type__c;
            if(leadRec.Retail_Flag__c == true){
                this.retailFlag = 'Y';
            }  
            else{
                this.retailFlag = 'N';
            }
            this.sicCode = leadRec.CaseRTMigrate__SICCode__c;
            this.salesModelCode = leadRec.Sales_Model_Code__c;
            //##hard coded value
            this.sourceSystemCode = null;
            this.submarketCode = leadRec.Sub_Market_Code__c;
            this.rtm = leadRec.RTM__c;
            this.segmentation = leadRec.Segmentation__c;
            //##hard coded value
            this.channelCompEligibleFlg = 0;
            this.salesMotion = leadRec.Selling_Motion__c;
            if(leadRec.Partner_Quoting_Account__c){
                this.partnerQuotingAccount = 'Y';
            }
            else{
                 this.partnerQuotingAccount = 'N';
            }
            this.partnerQuotAccountName = leadRec.Partner_Quoting_Account_Name__c;
            this.partnerQuotAccntSapUCID = leadRec.Partner_Quoting_Account_SAP_UCID__c;
            if(leadRec.Quoting_Auto_book_Enabled__c){
                this.quotingAutoBookEnabled = 'Y';
            }
            else{
                this.quotingAutoBookEnabled = 'N';
            }
            if(leadRec.Quoting_EPOA_Flag__c){
                this.quotingEpoaFlag = 'Y';
            }
            else{
                this.quotingEpoaFlag = 'N';
            }
            this.quotingFobIncoterms = leadRec.Quoting_FOB_Incoterms__c;
            this.quotingFreightTerms = leadRec.Quoting_Freight_Terms__c;
            this.quotingPaymentTerms = leadRec.Quoting_Payment_Terms__c;
            //this.GlobalAllianceTower = leadRec.Global_Alliance_Tower__c;
          //  this.resellerTaxID = leadRec.National_ID__c;
            this.cfiProjectNumber = leadRec.CFI_Project_Numbers__c;
            if(leadRec.Date_Founded__c!=Null){
                this.companyFoundedDate = AccountSuggestionIntegrationCIL.convertDateTimeToString(leadRec.Date_Founded__c); 
            }
            this.finGeo = leadRec.FIN_GEO__c;
            if(leadRec.Fiscal_Year_End__c!=Null){
                this.fiscalYearEnd = AccountSuggestionIntegrationCIL.convertDateTimeToString(leadRec.Fiscal_Year_End__c);
            }
            this.legacyID = legacyId;
            this.localAccountName = leadRec.CompanyLocal;
            if(leadRec.Location_Number__c!=Null){
                this.locationNumber = Integer.ValueOf(leadRec.Location_Number__c);
            }
            this.nationalID = leadRec.National_ID__c;
            this.noOfEmployee = leadRec.NumberOfEmployees;
            this.premierPageUrl = leadRec.Premier_Page_URL__c;
            if(leadRec.Std_Quote_Numbers__c!=Null){
                this.stdQuoteNumbers = Integer.ValueOf(leadRec.Std_Quote_Numbers__c);
            }
            this.webSiteUrl = leadRec.Website;
        }
    }
    /*Sales Rep Info Class*/
    public class SalesRepInformation{
        public Integer action{get;set;} 
        public String assignmentType{get;set;}
        public String resourceRoleEndDate{get;set;}
        public String resourceRoleStartDate{get;set;}
        public String existingStartDate{get;set;}
        public Boolean resourceEndDateAltered{get;set;}
        public String badgeNumber{get;set;}
        public String roleID{get;set;}
        public String salesRepName{get;set;}
        public Integer ownerForAccount{get;set;}
        public Integer primaryAssignee{get;set;}
        
        public SalesRepInformation(Lead leadRec){
            String toDateInString = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss'); 
            //##hard coded value
            this.action=5;
            //##hard coded value
            this.assignmentType = 'Direct';
            //##hard coded value
            this.resourceRoleEndDate = null;
            //##hard coded value
            this.resourceRoleStartDate = String.ValueOf(toDateInString);
            //##hard coded value
            this.existingStartDate = String.ValueOf(toDateInString);
            //##hard coded value
            this.resourceEndDateAltered = false;
            if(leadRec.Account_Owner__c!=Null){
                this.badgeNumber = leadRec.Account_Owner__r.Badge_Number__c;
            }
            //String userRole = StringUtils.substringAfter(leadRec.Account_Owner__r.UserRole.name, '_');
            //##Previously No Role Id - UserRoleId of leadRec.Account_Owner__r
            this.roleID = '10181';
            if(leadRec.Account_Owner__r!=Null){
                this.salesRepName = leadRec.Account_Owner__r.FirstName + ' ' + leadRec.Account_Owner__r.LastName;
            }
            //##hard coded value
            this.ownerForAccount = 1;
            //##hard coded value
            this.primaryAssignee = 1;
        }
    }
    /*Territory Info Class*/
    public class TerritoryInformation{
        public Integer action{get;set;}
        public String assignmentEndDate{get;set;}
        public String assignmentStartDate{get;set;}
        public String existingStartDate{get;set;}
        public Boolean groupEndDateAltered{get;set;}
        public Integer groupID{get;set;}
        public String groupName{get;set;}
        public String groupDescription{get;set;}
        
        public TerritoryInformation(Lead leadRec){
            String toDateInString = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss'); 
            String territoryGroupId;
            String territoryGroupName;
            String strRegionDesc;
            String territoryGroupDesc;
             if (leadRec.Territory_Assignment__r!=Null && leadRec.Territory_Assignment__r.Group_ID__c == null) {
                Sales_Channel_Group__c salesChannelObj = [select name, Group_ID__c, region_desc__c from Sales_Channel_Group__c 
                                                          where id = : leadRec.Territory_Assignment__c];
                 if(salesChannelObj!=null){
                     territoryGroupId = salesChannelObj.Group_ID__c;
                     territoryGroupName = salesChannelObj.Name;
                     territoryGroupDesc = salesChannelObj.region_desc__c;
                 }
             }else{
                 territoryGroupId = leadRec.Territory_Assignment__r.Group_ID__c;
                 territoryGroupName = leadRec.Territory_Assignment__r.Name;
                 territoryGroupDesc = leadRec.Territory_Assignment__r.Region_Desc__c;
             }
            //##hard coded value.What value need to take here, previously string
            this.action = 9;
            this.assignmentEndDate = null;
            this.assignmentStartDate = toDateInString;
            this.existingStartDate = null;
            this.groupEndDateAltered = false;
            if(territoryGroupId!=Null){
                this.groupID = Integer.ValueOf(territoryGroupId);
            }
            this.groupName = territoryGroupName;
            this.groupDescription = territoryGroupDesc;
       }    
    }
    /*UDA Info class*/
    public class UDAInformation{
        public Integer action{get;set;}
        public Integer udaID{get;set;}
        public String udaValue{get;set;}    
        
        public UDAInformation(Integer action,Integer udaID,String udaValue){
            this.action = action;
            this.udaID = udaID;
            this.udaValue = udaValue;
        }   
    }
    /*CustomerInformation class*/
    public class CustomerInformation{
        public Integer buID{get;set;}
        public String customerNumber{get;set;}
        public Boolean isOmega{get;set;}
        public CustomerInformation(Integer buID,String customerNumber,Boolean isOmega){
            this.buID = buID;
            this.customerNumber = customerNumber;
            this.isOmega = isOmega;
        }
    }
    /*ExternalEntityInformation class*/
    public class ExternalEntityInformation{
        public String referenceNumber{get;set;}
        public String entityType{get;set;}
        public String action{get;set;}
        public ExternalEntityInformation(String referenceNumber,String entityType,String action){
            this.referenceNumber = referenceNumber;
            this.entityType = entityType;
            this.action = action;
        }
    }
    /*LinkNumberInformation class*/
    public class LinkNumberInformation{
        public String linkNumber{get;set;}
        public String startDate{get;set;}
        public String buID{get;set;}
        public String endDate{get;set;}
        public LinkNumberInformation(String linkNumber,String startDate,String buID,String endDate){
            this.linkNumber = linkNumber;
            this.startDate = startDate;
            this.buID = buID;
            this.endDate = endDate;
        }
    }
    /*Selling Motion Info Class*/
    public class SellingMotion {
        public String applicationName {get;set;}
        public List<AddressInformation> addressInformation {get;set;}        
        public BasicInformation basicInformation {get;set;} 
        public List<SalesRepInformation> salesRepInformation{get;set;}
        public List<TerritoryInformation> territoryInformation{get;set;}
        public List<UDAInformation> udaInformation{get;set;}
        public List<ExternalEntityInformation> externalEntityInformation{get;set;}
        public List<LinkNumberInformation> linkNumberInformation{get;set;}
        public List<CustomerInformation> customerInformation{get;set;}
        public Integer requireMatchedAccountInformation{get;set;}
        
        public SellingMotion(Lead leadRec,Boolean isDupCheckRequired){
            this.applicationName = 'SFDC';
            this.basicInformation = new BasicInformation(leadRec);
            system.debug('Basic Info'+this.BasicInformation);
            
            SalesRepInformation si = new SalesRepInformation(leadRec);
            this.salesRepInformation =new List<SalesRepInformation>{si};
            system.debug('Sales Rep Info'+this.SalesRepInformation);
            
            TerritoryInformation ti = new TerritoryInformation(leadRec);
            this.territoryInformation =new List<TerritoryInformation>{ti};
            system.debug('Territory Info'+this.TerritoryInformation);
            
            AddressInformation ai = new AddressInformation(leadRec.Postal_Address_1__c,leadRec.Postal_Address_2__c,0,
                                                           leadRec.Postal_City__c,leadRec.Company,leadRec.SM_country_code__c,
                                                           leadRec.Postal_PostalCode__c,leadRec.Postal_State__c);
            
            AddressInformation aiLocal = new AddressInformation(leadRec.Legal_Local_Address_1__c,leadRec.Legal_Local_Address_2__c,2,
                                                           leadRec.Legal_Local_City__c,leadRec.Legal_Local_Company_Name__c,leadRec.SM_country_code__c, //leadRec.Legal_Local_Country__c,
                                                           leadRec.Legal_Local_Postal_Code__c,leadRec.Legal_Local_Postal_State__c);
           
            
            if(aiLocal.companyName == null && aiLocal.addressLine1== null
                                  && aiLocal.addressLine2== null && aiLocal.postalCode== null && aiLocal.state== null ){
                                      
                 this.addressInformation    = new List<AddressInformation>{ai};                   
                
            }else
            {
               this.addressInformation      = new List<AddressInformation>{ai,aiLocal}; 
            }
            
                
            system.debug('Address Info'+this.AddressInformation);
            UDAInformation ui1 = new UDAInformation(0,86,leadRec.Partner_Program_Track__c);
            UDAInformation ui2 = new UDAInformation(0,87,leadRec.Selling_Motion__c);
            UDAInformation ui3 = new UDAInformation(0,88,leadRec.Purchase_Path__c);
            UDAInformation ui4 = new UDAInformation(0,89,leadRec.Partner_Program_Tier__c);
            UDAInformation ui5 = new UDAInformation(0,169,leadRec.Account_Category__c);
            this.udaInformation = new List<UDAInformation>{ui1,ui2,ui3,ui4,ui5};
              
           If(leadRec.Universal_Customer_ID_UCID__c != null) {   
            ExternalEntityInformation EI1 = new ExternalEntityInformation(string.valueof(leadRec.Universal_Customer_ID_UCID__c),'ACQ_EMC','I');
            this.externalEntityInformation = new List<ExternalEntityInformation>{EI1};
            }else{
             this.externalEntityInformation = new List<ExternalEntityInformation>(); 
            }
            
            //LinkNumberInformation LI = new LinkNumberInformation('10223642','01/03/2019','11','01/03/2020');
            this.linkNumberInformation = new List<LinkNumberInformation>();
            
            //CustomerInformation CI1 = new CustomerInformation(707,'8546597',false);  
            //CustomerInformation CI2 = new CustomerInformation(707,'8546849',false);  
            this.customerInformation = new List<CustomerInformation>();
            if(isDupCheckRequired){
                this.RequireMatchedAccountInformation = 1;
            }
            else{
                this.RequireMatchedAccountInformation = 0;
            }
       }
    } 
    /*Suggestion Information class*/
    public class SuggestionInformation{
        public String accountType{get;set;}
        public String badgeNumber{get;set;}
        public String createdByModule{get;set;}
        public String effectiveDate{get;set;}
        public Integer effectiveTypeId{get;set;}
        public Integer rrID{get;set;}
        public String region{get;set;}
        public String relatedSuggestionIDs{get;set;}
        public String suggestionComments{get;set;}
        public Integer suggestionReason{get;set;}
        public Integer suggestionStatus{get;set;}
        public String emailID{get;set;}
        
        public SuggestionInformation(Lead leadRec){
            String toDateInString = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss');
            String regionVal;
            if(leadRec.Organization_Country__r.Region__c!=Null){
               regionVal = AccountSuggestionIntegrationCIL.mapregion.get(leadRec.Organization_Country__r.Region__c); 
            }
            User currentUser = [SELECT Id, Badge_Number__c, FirstName, LastName, Email,HR_Location_Country_Desc__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1][0];
             //##Hard coded
            this.accountType = 'Account';
            this.badgeNumber = currentUser.Badge_Number__c;
            //##Hard coded
            this.createdByModule = 'SFDC';
            //##Hard coded
            this.effectiveDate = toDateInString;
            //##Hard coded
            this.effectiveTypeId = 1;
            //##What value need to pass
            this.rrID = 0;
            this.region = regionVal;
            //##Hard Coded
            this.relatedSuggestionIDs = '';
            this.suggestionComments = leadRec.Questions_Comments__c;
            //## Error : Could not insert row into iddcrm.ds_suggestion_denorm" if we pass string
            //this.SuggestionReason = leadRec.Suggestion_Reason__c;
            this.suggestionReason = 1;
            //##Hard code Previous - Approved
            this.suggestionStatus = 4;
            this.emailID = currentUser.Email;
        }
    }
    //Method to generate request
    public String generateReq(Lead leadRec,Boolean isDupCheckReq){
        system.debug('Entered into generateReq method Lead Rec is'+leadRec);
        MasterGroupInformation mg = new MasterGroupInformation(leadRec);
        system.debug('MG Info'+mg);
        TrackInformation trackInfo = new TrackInformation(leadRec);
        system.debug('TrackInfo'+TrackInfo);
        PartnerTrackInformation pt = new PartnerTrackInformation(leadRec);
        system.debug('PT'+pt);
        SellingMotion sm = new SellingMotion(leadRec,isDupCheckReq);
        system.debug('SM'+sm);
        SuggestionInformation sugInfo = new SuggestionInformation(leadRec);
        system.debug('SugInfo'+sugInfo);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('MasterGroupInformation');      
        gen.writeObject(mg);
        gen.writeFieldName('TrackInformation');      
        gen.writeObject(trackInfo);
        gen.writeFieldName('PartnerTrackInformation');      
        gen.writeObject(pt);
        gen.writeFieldName('SellingMotion');      
        gen.writeObject(sm);
        gen.writeFieldName('SuggestionInformation');      
        gen.writeObject(sugInfo);  
        gen.writeEndObject();
        String req = gen.getAsString();
        //Here Currency is reserved identifier , but we need to pass this as request parameter,
        //so here string replacement functionality was used
        req = req.replace('Currency1', 'Currency');
        system.debug('**********' +req);
        return req;
    }    
}