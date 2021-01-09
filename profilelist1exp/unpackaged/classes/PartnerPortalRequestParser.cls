public class PartnerPortalRequestParser {

    public class PartnerPortalRequestinnerParser {
        public String updateFor;
        public String recordsList;
    }

    
    public static PartnerPortalRequestinnerParser parse(String json) {
        return (PartnerPortalRequestinnerParser) System.JSON.deserialize(json, PartnerPortalRequestinnerParser.class);
    }
}