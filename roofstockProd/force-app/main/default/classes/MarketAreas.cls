//
//Generated by AdminBooster
//
public class MarketAreas{
	public cls_marketAreas[] marketAreas;
	 class cls_marketAreas {
		public Integer id;	//1001
		public String marketName;	//Orlando
		public String displayName;	//Orlando
		public String urlFriendlyName;	//orlando-central-florida
		public String logoUrl;	////roofstock-cdn.azureedge.net/markets/orlando/profile.png
		public boolean isActive;
		public String lookupZip;	//33860
	}
	public static MarketAreas parse(String json){
		return (MarketAreas) System.JSON.deserialize(json, MarketAreas.class);
	}

	
}