public class CC_ProductDetails {
	public String Id;
	public Integer Attempt;
	public String Action;
	public List<Data> Data;

	public class Data {
		public String type_code;
		public String type_desc;
		public String group_code;
		public String group_desc;
		public String lob_code;
		public String lob_desc;
		public String category;
		public String category_desc;
		public String product_line;
		public String product_line_desc;
		public String product_type;
		public String product_type_desc;
		public String family_parent;
		public String family_parent_desc;
		public String portfolio;
		public String portfolio_desc;
		public String family;
		public String family_desc;
		public String offering_group;
		public String offering_group_desc;
		public String base_code;
		public String base_code_desc;
		public String product_offering_code;
		public String product_offering_code_desc;
		public String item_class;
		public String item_class_desc;
        public Data(String typecode, String typedesc,String groupcode, String groupdesc,String lobcode,String lobdesc, String categor, String categorydesc, String productline, String product_linedesc, String producttype, String producttype_desc, String familyparent, String family_parentdesc, String portfoli, String portfoliodesc, String famil, String familydesc, String offeringgroup, String offering_groupdesc, String basecode, String base_codedesc, String product_offeringcode, String  product_offering_codedesc, String itemclass, String item_classdesc ){
			System.debug('Inside Constructor');
            System.debug(typedesc);
			type_code = typecode;
			type_desc = typedesc;
			group_code = groupcode;
			group_desc = groupdesc;
			lob_code = lobcode;
			lob_desc = lobdesc;
			category = categor;
			category_desc = categorydesc;
			product_line = productline;
			product_line_desc = product_linedesc;
			product_type = producttype;
			product_type_desc = producttype_desc;
			family_parent = familyparent;
			family_parent_desc = family_parentdesc;
			portfolio = portfolio;
			portfolio_desc = portfoliodesc;
			family = famil;
			family_desc = familydesc;
			offering_group = offeringgroup;
			offering_group_desc = offering_groupdesc;
			base_code = basecode;
			base_code_desc = base_codedesc;
			product_offering_code = product_offeringcode;
			product_offering_code_desc = product_offering_codedesc;
			item_class = itemclass;
			item_class_desc = item_classdesc;
            
        }
        public Data(){
            
        }
	}
}