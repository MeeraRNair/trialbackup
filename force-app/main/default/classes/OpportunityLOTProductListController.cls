/*
History:
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
   2.0     CR15591    FY19-DCS-0502     02-Apr-2018      Pallavi Mani  added Quote__c field as part of Quote number removal Story: 4795081 
   2.1     CR15591    FY19-DCS-0502     11-Apr-2018      Pallavi Mani  modified test method to fix Duplicate value error 
   2.2     CR15591    FY19-DCS-0502     11-Apr-2018      Pallavi Mani  modified test method to fix Duplicate value error  
*/

public class OpportunityLOTProductListController {
    
    public String opptyId {get; set;}
    public Integer contentType {get; set;}
    public boolean showAll {get; set;}
    
    public final Integer CONTENT_TYPE_BOTH_LOT_OCEAN = 0;
    public final Integer CONTENT_TYPE_LOT_ONLY = 1;
    public final Integer CONTENT_TYPE_OCEAN_ONLY = 2;
    public final Integer CONTENT_TYPE_EOL_ONLY = 3;
    
    public List<String> tableRowTextList;
    
    public OpportunityLOTProductListController(String oid, Integer ctype, boolean showAllFlg) {
        opptyId = oid;
        contentType = ctype;
        showAll = showAllFlg;
    }
    
    public OpportunityLOTProductListController() {
        
    }
    
    public List<String> getTableRowTextList() {
        
        Map<Id, Opportunity> opptyMap = LOTOceanUtilities.getOpptyMap(new Set<String>{opptyId});
        
        List<AggregateResult> aggregatedResultList = LOTOceanUtilities.getAggregatedResult(opptyMap.keySet());

        LOTOceanUtilities.setupData(opptyMap.values(), aggregatedResultList);
        
        tableRowTextList = new List<String>();
        
        String headerString = '';
        if (contentType == CONTENT_TYPE_EOL_ONLY) {
            headerString +='<th>Product Line Desc</th>'
                        + '<th>Brand Desc</th>'
                        + '<th>Product Quantity</th>'
                        + '<th>EOL Date</th>'                       
                        + '<th>Replacement Product Desc</th>';          
        }
        else {
            headerString += '<tr>' 
                        + '<th>Product Group</th>'
                        + '<th>Product</th>'
                        + '<th>Total Quantity</th>';
                        
        }       

        if(contentType == CONTENT_TYPE_LOT_ONLY || contentType == CONTENT_TYPE_BOTH_LOT_OCEAN) {
            headerString += '<th>Is LOT Eligible</th>';
        }       
        
        if(contentType == CONTENT_TYPE_OCEAN_ONLY || contentType == CONTENT_TYPE_BOTH_LOT_OCEAN) {
                headerString += '<th>Is OCEAN Eligible</th>'
                                + '<th>OCEAN Type</th>'
                                + '<th>Container Size</th>'
                                + '<th>Pallet Size</th>'
                                + '<th>Potential Cost Savings</th>'
                                + '<th>MAX Delivery Lead Time (Weeks)</th>';
        }
        
        headerString += '<th>Quote #</th>' // v2.0
        +'</tr>';
        tableRowTextList.add(headerString);
        
        for(AggregateResult ar : aggregatedResultList) {
            String productId = (String)ar.get('ProductId');
            
            Boolean isLOT;
            Decimal totalSaving;
            Decimal maxLeadTime;
            String replacePlatform;
            Date EOLDate;
            Decimal totalQty;
            
            if(contentType != CONTENT_TYPE_EOL_ONLY) {
                isLOT = opptyMap.get(opptyId).LOT_Large_Opportunity__c ;
                totalSaving = (Decimal)ar.get('totalSaving');
                maxLeadTime = (Decimal)ar.get('maxLeadTime');
            }
            
            replacePlatform = (String)ar.get('replacePlatform');
            
            //CR5530: Provision to maintain the separate EOLs and RTSs by region (populate value for EOLDate table data)
                                          
            if(opptyId != null) {
                if(opptyMap.get(opptyId).Primary_Product_Delivery_Address_Region__c == 'NORTH AMERICA') {
                    EOLDate = Date.valueOf(ar.get('EOL_NORTHAMERICADate'));
                } else if (opptyMap.get(opptyId).Primary_Product_Delivery_Address_Region__c == 'LATAM') {
                    EOLDate = Date.valueOf(ar.get('EOL_LATAMDate'));
                } else if (opptyMap.get(opptyId).Primary_Product_Delivery_Address_Region__c == 'EMEA' || opptyMap.get(opptyId).Primary_Product_Delivery_Address_Region__c == 'EC-EMEA') {
                    EOLDate = Date.valueOf(ar.get('EOL_EMEADate'));
                } else if (opptyMap.get(opptyId).Primary_Product_Delivery_Address_Region__c == 'APJ') {
                    EOLDate = Date.valueOf(ar.get('EOL_APJDate'));
                } else if (opptyMap.get(opptyId).Primary_Product_Delivery_Address_Region__c == 'Other') {
                    EOLDate = Date.valueOf(ar.get('EOL_OtherDate'));
                } else {
                    EOLDate = Date.valueOf(ar.get('EOL_GlobalDate'));
                }
            }                       
            
            totalQty = (Decimal)ar.get('totalQty');
            
            Product2 currentProd = LOTOceanUtilities.productMap.get(productId);
                    
            Decimal containerSize = currentProd.Container_Volume__c == null ? null : currentProd.Container_Volume__c.setScale(0);
            Decimal palletSize = currentProd.Pallet_Quantity__c == null ? null : currentProd.Pallet_Quantity__c.setScale(0);
            
            Boolean isOcean = (totalSaving != null);
            
            String OceanType;
            
            if(isOcean) {
                if(totalQty >= containerSize) {
                    oceanType = 'CONTAINER';
                } else if( totalQty < containerSize && totalQty >= palletSize) {
                    oceanType = 'CONSOLIDATED';
                }
            } else {
                oceanType = 'N/A';
            }           
            
            String contentString = '';          
                                        
            contentString += '<tr>'
                            + '<td>' + ar.get('ProductLineDesc') + '</td>'          
                            + '<td>' + ar.get('ProductName') + '</td>'
                            + '<td>' + totalQty.setScale(0) + '</td>';
            
            if(contentType == CONTENT_TYPE_LOT_ONLY || contentType == CONTENT_TYPE_BOTH_LOT_OCEAN) {
                contentString += '<td>' + (isLOT ? 'YES' : 'NO') + '</td>';
            }
            
            if(contentType == CONTENT_TYPE_OCEAN_ONLY || contentType == CONTENT_TYPE_BOTH_LOT_OCEAN) {
                contentString += '<td>' + (isOcean ? 'YES' : 'NO') + '</td>'
                                + '<td>' + oceanType + '</td>'
                                + '<td>' + (containerSize == null ? 'N/A' : containerSize + '') + '</td>'
                                + '<td>' + (palletSize == null ? 'N/A' : palletSize + '') + '</td>'                             
                                + '<td>' + (totalSaving == null ? 'N/A' : ''+totalSaving.setScale(2)) + '</td>'
                                + '<td>' + (maxLeadTime == null ? 'N/A' : ''+maxLeadTime.setScale(0)) + '</td>';            
            }
            
            if(contentType == CONTENT_TYPE_EOL_ONLY) {
                contentString += '<td>' + (EOLDate == null ? 'N/A' : EOLDate + '') + '</td>'
                            + '<td>' + (replacePlatform == null ? 'N/A' : replacePlatform + '') + '</td>';
            }           
            contentString += '<td>' + ar.get('qouteNumber') + '</td>' // v2.0 
                          +'</tr>';
            if(showAll || (contentType == CONTENT_TYPE_LOT_ONLY && isLOT) 
                     || (contentType == CONTENT_TYPE_OCEAN_ONLY && isOcean)
                     || (contentType == CONTENT_TYPE_BOTH_LOT_OCEAN && (isOcean || isLOT))) {
                tableRowTextList.add(contentString);
            }
        }

        return tableRowTextList;
        
    }
    }