global class CurrencyUtils {
	
	public static List<CurrencyType> currencyTypeList;
	
	public static Map<string,Double> getCurrencyConversionMap(){
		Map<string,Double> currencyConvMap = new Map<string,Double>();
		currencyTypeList = [Select c.SystemModstamp, c.LastModifiedDate, c.LastModifiedById, c.IsoCode, c.IsCorporate, c.IsActive, c.Id, c.DecimalPlaces, c.CreatedDate, c.CreatedById, c.ConversionRate From CurrencyType c];
		if(currencyTypeList != null){
			for(CurrencyType currType : currencyTypeList ){
				currencyConvMap.put(currType.IsoCode , currType.ConversionRate);
			}
		}
		
		return currencyConvMap;
	}
	
	public static Double getConvertedCurrencyInUSD (string isoCode , Double value){
		Double valueInUSD = 0;
		Map<string,Double> currencyConvMap = getCurrencyConversionMap();
		if(currencyConvMap.containsKey(isoCode)){
			valueInUSD = value/currencyConvMap.get(isoCode);
		}
		
		return valueInUSD;
	}
}