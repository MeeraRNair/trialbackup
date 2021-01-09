public class CMAP_TriggerHelper {
    Public Static Lead populateComments(Lead newLead,Map<id,Lead> chldMap){
        newLead.Street = chldMap.get(newLead.Channel_Lead__c).Street;
        String chCustComment = chldMap.get(newLead.Channel_Lead__c).Questions_Comments__c;
        String chmarketingComment = chldMap.get(newLead.Channel_Lead__c).Marketing_Comments__c;
        String chsalesComment = chldMap.get(newLead.Channel_Lead__c).Sales_Comments__c;
        
        if(chCustComment != null) {
            String qComments;
            qComments = (newLead.Questions_Comments__c != null) ? (chCustComment + ', ' + newLead.Questions_Comments__c) : chCustComment;
            newLead.Questions_Comments__c = (qComments.length()> 31990) ? (qComments.substring(0, 31990) + '...') : qComments;
        }
        
        if(chmarketingComment != null) {
            String leadMktComments = newLead.Marketing_Comments__c;
            String mcomments;
            mcomments = (leadMktComments != null) ? (chmarketingComment + ', ' + leadMktComments) : chmarketingComment;
            newLead.Marketing_Comments__c = (mcomments.length()> 31990) ? (mcomments.substring(0, 31990) + '...') : mcomments;
        }
        if(chmarketingComment != null || chsalesComment != null) {
            String scomments;
            String mcomments = newLead.Marketing_Comments__c;
            String smcomments;
            if(chsalesComment != null) {
                scomments = (newLead.Sales_Comments__c != null) ? (chsalesComment + ', ' + newLead.Sales_Comments__c) : chsalesComment;
            } 
            else {
                scomments = (newLead.Sales_Comments__c != null) ? (newLead.Sales_Comments__c) : '';
            }
            // newLead.Sales_Comments__c = (scomments.length()> 31990)?(scomments.substring(0,31990)+'...'):scomments;
            if(scomments != null) {
                smcomments = (mcomments != null) ? (scomments + ', ' + mcomments) : scomments;
            } 
            else {
                smcomments = (mcomments != null) ? (mcomments) : '';
            }
            newLead.Sales_Comments__c = (smcomments.length()> 31990) ? (smcomments.substring(0, 31990) + '...') : smcomments;
        }
        
        return newLead;
        
    }
    
}