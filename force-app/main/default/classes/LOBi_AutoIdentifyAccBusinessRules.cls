/*
 * Revision CR Number   Release No      Date            Modified By               Description
 * -------- ---------   ----------      -----------     -----------------         -----------
 * 1.0       CR#14155   FY18-0602       19-Apr-2017     Venkateswarlu Chirala     LoBi Business rules
 *                                                                             ** Test Class for this class is: LOBi_SchDispatcher_Batch_RulesTest  
 * 
 *     
 */
 
 Public class LOBi_AutoIdentifyAccBusinessRules {
    
     /** 
     * @author Venkateswarlu Chirala
     * @date  19-Apr-2017
     * @description Check the Enduser Account Revenue criteria meets. for ISG < $10K last 8 quarter and CSG < $10K in last 4 quarters
     *     
     *@param Parameters used in logic
     */
     public static Map<String, Object> endUserAccRevenueRuleCheck(Map<ID, Set<String>> autoEligAccIncumMap, Set<String> last8QuartersSet, Set<String> last4QuartsSet, Map<ID, Account> accMap,
                                                                      Set<String> Tiers_1a_5, Set <String> Tiers_2a_2b_5) {
        
        Map<ID, Set<String>> revSucMapAccID_IncmFlags    =  new Map<ID, Set <String>>();
        Map<ID, Set<String>> revFailMapAccID_IncmFlags   =  new Map<ID, Set <String>>();
        Map<ID, Double> totalISGRevenue                  =  new Map<ID, Double>();
        Map<String, Object> returnDataSet                =  new Map<String, Object>();
        
        List<AggregateResult> ISGRevAggRes = [SELECT Account__c accID, sum(Storage_QTR_Rev__c) str, sum(Networking_QTR_Rev__c) nw, sum(Server_QTR_Rev__c) ser FROM Revenue__c
                                                        WHERE ( Fiscal_Year__c != NULL ) AND ( Fiscal_Quarter__c != NULL) AND (FiscalYearQuarter__c != NULL )AND (Account__c != NULL) 
                                                        AND (Account__c IN: autoEligAccIncumMap.keySet()) AND(FiscalYearQuarter__c IN: last8QuartersSet) GROUP BY Account__c ];

        List<AggregateResult> CSGRevAggRes = [SELECT Account__c accID, sum(Client_QTR_Rev__c) cl FROM Revenue__c WHERE (FiscalYearQuarter__c != NULL )AND (Account__c != NULL) 
                                                      AND ( Fiscal_Year__c != NULL ) AND ( Fiscal_Quarter__c != NULL) AND (Account__c IN: autoEligAccIncumMap.keySet()) 
                                                      AND(FiscalYearQuarter__c IN: last4QuartsSet) GROUP BY Account__c];
        System.debug('=========>>ISGRevAggResult' + ISGRevAggRes);
        System.debug('=========>>ISGRevAggResult' + CSGRevAggRes);

        if (ISGRevAggRes.size() > 0) {
            for (AggregateResult ag: ISGRevAggRes) {
              if(String.isNotBlank(String.valueOf(ag.get('accID')))){
                Set<String> sucessFlag = new Set<String>();
                Set<String> failFlag = new Set<String>();
                ID acntID = ID.valueOf(String.valueOf(ag.get('accID')));

                Boolean storage = (autoEligAccIncumMap.containsKey(acntID) && autoEligAccIncumMap.get(acntID).contains('Storage') && Tiers_1a_5.contains((accMap.get(acntID).Rating).toUpperCase().trim()) && (ag.get('str') != NULL && Double.valueOf(ag.get('str')) < 10000)) ? sucessFlag.add('Storage') : failFlag.add('Storage');
                Boolean NW = (autoEligAccIncumMap.containsKey(acntID) && autoEligAccIncumMap.get(acntID).contains('Networking') && Tiers_1a_5.contains((accMap.get(acntID).Rating).toUpperCase().trim()) && (ag.get('nw') != NULL && Double.valueOf(ag.get('nw')) < 10000)) ? sucessFlag.add('Networking') : failFlag.add('Networking');
                Boolean server = (autoEligAccIncumMap.containsKey(acntID) && autoEligAccIncumMap.get(acntID).contains('Server') && Tiers_1a_5.contains((accMap.get(acntID).Rating).toUpperCase().trim()) && (ag.get('ser') != NULL && Double.valueOf(ag.get('ser')) < 10000)) ? sucessFlag.add('Server') : failFlag.add('Server');
                Double totalISG = (ag.get('str') != NULL ? Double.valueOf(ag.get('str')) : 0) + (ag.get('nw') != NULL ? Double.valueOf(ag.get('nw')) : 0) + (ag.get('ser') != NULL ? Double.valueOf(ag.get('ser')) : 0);
                totalISGRevenue.put(acntID, totalISG);

                if (!sucessFlag.isEmpty()) revSucMapAccID_IncmFlags.put(acntID, sucessFlag);
                if (!failFlag.isEmpty()) revFailMapAccID_IncmFlags.put(acntID, failFlag);
            }
          }  
        }

        if (CSGRevAggRes.size() > 0) {
            for (AggregateResult ag: CSGRevAggRes) {
              if(String.isNotBlank(String.valueOf(ag.get('accID')))){   
                Id acID = ID.valueOf(String.valueOf(ag.get('accID')));
                if (autoEligAccIncumMap.containsKey(acID) && autoEligAccIncumMap.get(acID).contains('Client') && Tiers_2a_2b_5.contains((accMap.get(acID).Rating).toUpperCase().trim()) && (ag.get('cl') != NULL && Double.valueOf(ag.get('cl')) < 10000)){
                    if( revSucMapAccID_IncmFlags.containsKey(acID))
                       revSucMapAccID_IncmFlags.get(acID).add('Client');
                      else  revSucMapAccID_IncmFlags.put(acID,new set<String>{'Client'});
                }else revFailMapAccID_IncmFlags.put(acID, new set < String > {'Client'});
            }
          }
        }
        
        System.debug('---------->>>Rule1::RevSucessIncumFlags ' + revSucMapAccID_IncmFlags);
        System.debug('---------->>>Rule1::RevFaieldIncumFlags ' + revFailMapAccID_IncmFlags);
        System.debug('---------->>>Rule1::TotaltotalISGRevenue ' + totalISGRevenue);
     
        returnDataSet.put('RevSucess', revSucMapAccID_IncmFlags);
        returnDataSet.put('RevFailed', revFailMapAccID_IncmFlags);
        returnDataSet.put('ISGTotalRev', totalISGRevenue);

        return returnDataSet;
    }

 
     /** 
     * @author Venkateswarlu Chirala
     * @date  19-Apr-2017
     * @description Check on End User Account Partner opportunity criteria meets, won in last quarter & Medaled partner
     *     
     *@param Parameters used in logic
     */
    public static Map<ID, Set<ID>> endUserAccPartOppRuleCheck(Map<ID, Set<String>> revSucMapAccID_IncmFlags, Set<String> partnerRelSet, Date lastQuarterStDate, Date lastQuarterEndDate) {
        Map<ID, Set<ID>> oppSucMapAccID_OppSet = new Map<ID, Set<ID>>();

        List<Opportunity> listOpp = [SELECT ID, Name, AccountID, PartnerAccountID FROM opportunity
                                      WHERE (AccountID != NULL) AND (PartnerAccountID != NULL) AND (PartnerAccount.Partner_Relationship__c != NULL)
                                      AND (StageName != NULL) AND (Stage_Changed_On__c != NULL) AND (Deal_Reg_Oppty__c!= NULL)
                                      AND (AccountID IN: revSucMapAccID_IncmFlags.keySet()) AND (PartnerAccount.Partner_Relationship__c IN: partnerRelSet)
                                      AND (StageName = 'Win - 100%') AND (Deal_Reg_Oppty__c= 'Yes')
                                      AND (Stage_Changed_On__c > =: lastQuarterStDate AND Stage_Changed_On__c <=: lastQuarterEndDate) order by AccountID ];

        if(listOpp.size()> 0){
             for (Opportunity opp: listOpp) {
               if(opp.ID != NULL && opp.AccountID != NULL){
                if (oppSucMapAccID_OppSet.containsKey(opp.AccountID)) 
                    oppSucMapAccID_OppSet.get(opp.AccountID).add(opp.ID);
                else oppSucMapAccID_OppSet.put(Opp.AccountID, new set<ID>{Opp.ID});
             }
           } 
       }
        System.debug('-------------->> Rule2:: oppSucMapAccID_OppSet  ' + oppSucMapAccID_OppSet);
        return oppSucMapAccID_OppSet;        
    }// End of Rule 2


   /** 
     * @author Venkateswarlu Chirala
     * @date  19-Apr-2017
     * @description Check the Opporutntiy products Total Price criteria meets  the min (50/20k) rev requirement based of Tiering
     *     
     *@param Parameters used in logic
     */
    public static Map<String, Object> partOppProductsRevRuleCheck(Map<ID, Set<ID>> oppSucMapAccID_OppSet, Map<ID, Account> accMap, Set<String> ISG_1a_2a, Set <String> ISG_1b_2b_3_5, Set<String> CSG_2a, Set<String> CSG_2b_3_5,
                                                                     Map <ID, Set<String>> revSucMapAccID_IncmFlags, Map<String, LOBi_Business_Rules__mdt> lobiCustMeta) {

        Map<String, Object > returnDataSet              =   new Map<String, Object>();
        Map<ID, Set<String>> succMap_OppProdRev         =   new Map<ID, Set<String>>();
        Map<String, Double> revOppProdsMap_AccIncm_totl =   new Map<String, Double>();
        Set<String> clinetProdSet                       =   new Set<String>();
        Set<String> nwProdSet                           =   new Set<String>();
        Set<String> serverProdSet                       =   new Set<String>();
        Set<String> storageProdSet                      =   new Set<String>();
        Set<ID> oppIDs                                  =   new Set<ID>();

        if(lobiCustMeta.containsKey('Client_Incum') )
          for(String cl:((lobiCustMeta.get('Client_Incum').Eligible_Product_codes__c).normalizeSpace()).split(';'))
                clinetProdSet.add((cl.toUpperCase()).trim());
                
        if(lobiCustMeta.containsKey('Networking_Incum') )
          for(String nw:((lobiCustMeta.get('Networking_Incum').Eligible_Product_codes__c).normalizeSpace()).split(';'))
                nwProdSet.add((nw.toUpperCase()).trim());
        
        if(lobiCustMeta.containsKey('Server_Incum') )
          for(String sr:((lobiCustMeta.get('Server_Incum').Eligible_Product_codes__c).normalizeSpace()).split(';'))
                serverProdSet.add((sr.toUpperCase()).trim());
        
        if(lobiCustMeta.containsKey('Storage_Incum') )
          for(String st:((lobiCustMeta.get('Storage_Incum').Eligible_Product_codes__c).normalizeSpace()).split(';'))
                storageProdSet.add((st.toUpperCase()).trim());
                
        for(ID acID:oppSucMapAccID_OppSet.keySet()) 
           oppIDs.addAll(oppSucMapAccID_OppSet.get(acID));
      
        List<AggregateResult> oppProdReveAggResult = [SELECT Opportunity.AccountID accID, product2.ProductCode prodCode, sum(TotalPrice) totalRev FROM OpportunityLineItem
                                                      WHERE (OpportunityID != NULL) AND (Opportunity.AccountID != NULL )AND (product2ID != NULL) AND (product2.ProductCode != NULL) 
                                                      AND(Opportunity.AccountID IN: oppSucMapAccID_OppSet.keySet()) AND (OpportunityID IN: oppIDs) 
                                                      AND ((product2.ProductCode IN: clinetProdSet) OR (product2.ProductCode IN: nwProdSet ) OR (product2.ProductCode IN: serverProdSet) OR (product2.ProductCode IN: storageProdSet))
                                                      GROUP BY Opportunity.AccountID, product2.ProductCode ];
                                                            
        if(oppProdReveAggResult.size()> 0){
         for (AggregateResult ag: oppProdReveAggResult) {
            
            if(ag.get('totalRev') != NULL && String.isNotBlank(String.valueOf(ag.get('accID')))&& String.isNotBlank(String.valueOf(ag.get('prodCode')))){ 
                String accID_IncFlag = ID.valueOf(String.valueOf(ag.get('accID')));
                if (!clinetProdSet.isEmpty() && clinetProdSet.contains((String.valueOf(ag.get('prodCode'))).normalizeSpace().toUpperCase().trim())) {
                    // == 'Workstations' || String.valueOf(ag.get('prodCode')) == 'Notebooks' || String.valueOf(ag.get('prodCode')) == 'Commercial' || String.valueOf(ag.get('prodCode')) == 'NON PC') 
                    if (revOppProdsMap_AccIncm_totl.containsKey(accID_IncFlag + '/' + 'Client'))
                        revOppProdsMap_AccIncm_totl.put(accID_IncFlag + '/' + 'Client', revOppProdsMap_AccIncm_totl.get(accID_IncFlag + '/' + 'Client') + Double.valueOf(ag.get('totalRev')));
                    else revOppProdsMap_AccIncm_totl.put(accID_IncFlag + '/' + 'Client', Double.valueOf(ag.get('totalRev')));
                }
    
                    else if (!storageProdSet.isEmpty() && storageProdSet.contains((String.valueOf(ag.get('prodCode'))).normalizeSpace().toUpperCase().trim())) { 
                        //== 'Storage Systems' || String.valueOf(ag.get('prodCode')) == 'Storage') 
                        if (revOppProdsMap_AccIncm_totl.containsKey(accID_IncFlag + '/' + 'Storage'))
                            revOppProdsMap_AccIncm_totl.put(accID_IncFlag + '/' + 'Storage', revOppProdsMap_AccIncm_totl.get(accID_IncFlag + '/' + 'Storage') + Double.valueOf(ag.get('totalRev')));
                        else revOppProdsMap_AccIncm_totl.put(accID_IncFlag + '/' + 'Storage', Double.valueOf(ag.get('totalRev')));
                    }
    
                        else if (!nwProdSet.isEmpty() && nwProdSet.contains((String.valueOf(ag.get('prodCode'))).normalizeSpace().toUpperCase().trim())) { 
                            // == 'Networking Products' || String.valueOf(ag.get('prodCode')) == 'Networking') 
                            if (revOppProdsMap_AccIncm_totl.containsKey(accID_IncFlag + '/' + 'Networking'))
                                revOppProdsMap_AccIncm_totl.put(accID_IncFlag + '/' + 'Networking', revOppProdsMap_AccIncm_totl.get(accID_IncFlag + '/' + 'Networking') + Double.valueOf(ag.get('totalRev')));
                            else revOppProdsMap_AccIncm_totl.put(accID_IncFlag + '/' + 'Networking', Double.valueOf(ag.get('totalRev')));
                        }
    
                           else  if (!serverProdSet.isEmpty() && serverProdSet.contains((String.valueOf(ag.get('prodCode'))).normalizeSpace().toUpperCase().trim())) { 
                                // == 'Enterprise Systems' || String.valueOf(ag.get('prodCode')) == 'PowerEdge Servers') 
                                if (revOppProdsMap_AccIncm_totl.containsKey(accID_IncFlag + '/' + 'Server'))
                                    revOppProdsMap_AccIncm_totl.put(accID_IncFlag + '/' + 'Server', revOppProdsMap_AccIncm_totl.get(accID_IncFlag + '/' + 'Server') + Double.valueOf(ag.get('totalRev')));
                                else revOppProdsMap_AccIncm_totl.put(accID_IncFlag + '/' + 'Server', Double.valueOf(ag.get('totalRev')));
                            }
               } // End of totalRev check
          }
        }
        
      System.debug('-----OppProducts Revenue---->>' + revOppProdsMap_AccIncm_totl);
        
       if(revOppProdsMap_AccIncm_totl.size()>0){
        for (String acc_IncFlag: revOppProdsMap_AccIncm_totl.keySet()) {
            ID accID = acc_IncFlag.substringBefore('/');
            String incFlag = acc_IncFlag.substringAfter('/');  
            if (String.isNotBlank(accID)&& String.isNotBlank(incFlag)&& revSucMapAccID_IncmFlags.containsKey(accID) && revSucMapAccID_IncmFlags.get(accID).contains(incFlag)) {
                Set<String> prodSucFlag=new Set<String>();  
                if (incFlag == 'Storage' || incFlag == 'Networking' || incFlag == 'Server'){ 
                    Boolean isgA= (ISG_1a_2a.contains((accMap.get(accID).Rating).toUpperCase().trim()) && revOppProdsMap_AccIncm_totl.get(acc_IncFlag) >= 50000 ) ? prodSucFlag.add(incFlag):FALSE;
                    Boolean isgB= (ISG_1b_2b_3_5.contains(accMap.get(accID).Rating.toUpperCase().trim()) && revOppProdsMap_AccIncm_totl.get(acc_IncFlag) >= 20000 ) ? prodSucFlag.add(incFlag):FALSE;                
                 } else if(incFlag == 'Client'){
                    Boolean csgA= (CSG_2a.contains((accMap.get(accID).Rating).toUpperCase().trim()) && revOppProdsMap_AccIncm_totl.get(acc_IncFlag) >= 75000 ) ? prodSucFlag.add(incFlag):FALSE;
                    Boolean csgB= (CSG_2b_3_5.contains(accMap.get(accID).Rating.toUpperCase().trim()) && revOppProdsMap_AccIncm_totl.get(acc_IncFlag) >= 20000 ) ? prodSucFlag.add(incFlag):FALSE;                           
                }
                
                if(!prodSucFlag.isEmpty()) {
                    if(succMap_OppProdRev.containsKey(accID)) succMap_OppProdRev.get(accID).addAll(prodSucFlag);
                    else succMap_OppProdRev.put(accID, prodSucFlag); 
                    }
               }
          }
       }
        System.debug('------OppProducts Revenue Sucess Map ---->' + succMap_OppProdRev);
      
        returnDataSet.put('succOppProdRev', succMap_OppProdRev);       
        return returnDataSet;
    }

    /** 
     * @author Venkateswarlu Chirala
     * @date  19-Apr-2017
     * @description account reach LOB incumbency on at least one ISG LoB (Server or Networking or Storage),
     *              we need to check if the overall ISG Revenue is <10k and then the account will earn complete ISG incumbency
     *     
     *@param Parameters used in logic
     */
    public static List<Account> finalNewLogoRuleCheck(Map<ID, Set<String>> autoEligAccIncumMap, Map <ID, Double> totalISGRevenue, Map<ID, Set<String>> succMap_OppProdRev) {
        List <Account> accUpdateList = new List<Account>();

        for (ID accID: succMap_OppProdRev.keySet()) {
          if(accID != NULL && succMap_OppProdRev.get(accID).size()> 0){
            Account acc = new Account(ID = accID);
            for (String flag: succMap_OppProdRev.get(accID)) {
                            
                if (flag == 'Server') {
                    acc.Server__c = True;
                    if (totalISGRevenue.containsKey(accID) && totalISGRevenue.get(accID) < 10000) {
                        if (autoEligAccIncumMap.get(accID).contains('Storage')) acc.Storage__c = True;
                        if (autoEligAccIncumMap.get(accID).contains('Networking')) acc.Networking__c = True;
                    }
                }

                else if (flag == 'Storage') {
                    acc.Storage__c = True;
                    if (totalISGRevenue.containsKey(accID) && totalISGRevenue.get(accID) < 10000) {
                        if (autoEligAccIncumMap.get(accID).contains('Server')) acc.Server__c = True;
                        if (autoEligAccIncumMap.get(accID).contains('Networking')) acc.Networking__c = True;
                    }
                }

                else if (flag == 'Networking') {
                    acc.Networking__c = True;
                    if (totalISGRevenue.containsKey(accID) && totalISGRevenue.get(accID) < 10000) {
                        if (autoEligAccIncumMap.get(accID).contains('Server')) acc.Server__c = True;
                        if (autoEligAccIncumMap.get(accID).contains('Storage')) acc.Storage__c = True;
                    }
                }

                else if (flag == 'Client') acc.CSG__c = True;              
            } 
            accUpdateList.add(acc);
         }
      } 
        System.debug('---------->>FinalaccUpdateList------>>' + accUpdateList);
        return accUpdateList;
    }
}