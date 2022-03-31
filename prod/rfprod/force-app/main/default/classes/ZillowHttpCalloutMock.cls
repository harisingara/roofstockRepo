@isTest
public class ZillowHttpCalloutMock implements HttpCalloutMock {
    public static final Decimal ZESTIMATE = 383409177;
    public static final Decimal RENT_ZESTIMATE = 1773942;
    public static final String ZILLOW_PROPERTY_URL = 'http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/';
    public static final String BAD_REQUEST = 'Bad Request';
    public static final String ERROR_CODE_RESPONSE = '400';
    public static final String PROPERTY_NAME = '1600 pennsylvania avenue';
    public static final String ZIP = '20006';
    public static final String ZPID = '84074482';
    public static final String ZWS_ID_PARAM = 'zws-id=';
    public static final String SUCCESS_MESSAGE = 'Request successfully processed';
    public static final String SUCCESS_CODE = '0';
    public static final String ERROR_MESSAGE_GET_DEEP_SEARCH_RESULTS = 'Error: no exact match found for input address';
    public static final String ERROR_MESSAGE_GET_UPDATED_PROPERTY_DETAILS = 'Error: invalid zpid parameter';
    public static final String ERROR_CODE_GET_DEEP_SEARCH_RESULTS = '508';
    public static final String ERROR_CODE_GET_UPDATED_PROPERTY_DETAILS = '500';
    public static final String imageUrls = String.join(
        new List<String>{
            'http://photos2.zillowstatic.com/p_d/ISx3sl6cgbsxb7.jpg',
            'http://photos3.zillowstatic.com/p_d/ISx3lmu2w8qher.jpg',
            'http://photos3.zillowstatic.com/p_d/ISx1tcpcltboo3.jpg',
            'http://photos2.zillowstatic.com/p_d/ISx1tcowtkf8v7.jpg',
            'http://photos2.zillowstatic.com/p_d/IS110vnts3nsyw3.jpg'
        },',');

    public HttpResponse respond(HttpRequest req) {
        String actualEndpoint = req.getEndpoint();
        Set<String> expectedParamsAndValues = new Set<String>{
            ZillowUpdateContExt.ADDRESS_PARAM + EncodingUtil.urlEncode(PROPERTY_NAME, 'UTF-8'),
            ZillowUpdateContExt.CITY_STATE_ZIP_PARAM + EncodingUtil.urlEncode(ZIP, 'UTF-8'),
            ZWS_ID_PARAM + EncodingUtil.urlEncode(ZillowUpdateContExt.ZWS_ID, 'UTF-8'),
            ZillowUpdateContExt.RENT_ZESTIMATE_PARAM + EncodingUtil.urlEncode('true', 'UTF-8')
        };

        List<String> expectedBaseUrlAndParams = ZillowUpdateContExt.GET_DEEP_SEARCH_RESULTS_URL.split('\\?');
        List<String> actualBaseUrlAndParams = actualEndpoint.split('\\?');
        Set<String> actualParamsAndValues = new Set<String>(actualBaseUrlAndParams[1].split('&'));

        System.assertEquals(expectedBaseUrlAndParams[0], actualBaseUrlAndParams[0], 'the endpoint should have the correct base url');
        System.assertEquals(expectedParamsAndValues, actualParamsAndValues, 'The endpoint should have the correct params and values');
        System.assertEquals('GET', req.getMethod(), 'The method should be set correctly');

        HttpResponse res = new HttpResponse();
        String body = '<?xml version="1.0" encoding="UTF-8"?><SearchResults:searchresults ' +
                      'xsi:schemaLocation="http://www.zillow.com/static/xsd/SearchResults.xsd ' +
                      'http://www.zillowstatic.com/vstatic/ca33129/static/xsd/SearchResults.xsd" ' +
                      'xmlns:SearchResults="http://www.zillow.com/static/xsd/SearchResults.xsd" ' +
                      'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><request><address>1600 pennsylvania avenue</address><citystatezip>20006</citystatezip>' +
                      '</request><message><text>Request successfully processed</text><code>0</code></message><response><results><result><zpid>84074482</zpid>' +
                      '<links><homedetails>http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/</homedetails>' +
                      '<graphsanddata>http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/#charts-and-data</graphsanddata>' +
                      '<mapthishome>http://www.zillow.com/homes/84074482_zpid/</mapthishome><comparables>http://www.zillow.com/homes/comps/84074482_zpid/</comparables>' +
                      '</links><address><street>1600 Pennsylvania Ave NW</street><zipcode>20006</zipcode><city>Washington</city><state>DC</state><latitude>38.89768</latitude>' +
                      '<longitude>-77.03651</longitude></address><FIPScounty>11001</FIPScounty><useCode>SingleFamily</useCode><yearBuilt>1792</yearBuilt><lotSizeSqFt>784080</lotSizeSqFt>' +
                      '<finishedSqFt>55000</finishedSqFt><bathrooms>35.0</bathrooms><bedrooms>16</bedrooms><totalRooms>132</totalRooms><zestimate><amount currency="USD">383409177</amount>' +
                      '<last-updated>04/05/2015</last-updated><oneWeekChange deprecated="true" /><valueChange duration="30" currency="USD">-1418455</valueChange><valuationRange>' +
                      '<low currency="USD">364238719</low><high currency="USD">402579635</high></valuationRange><percentile>0</percentile></zestimate>' +
                      '<rentzestimate><amount currency="USD">1773942</amount><last-updated>03/30/2015</last-updated><oneWeekChange deprecated="true"/>' +
                      '<valueChange duration="30" currency="USD">-8105</valueChange><valuationRange><low currency="USD">1082105</low><high currency="USD">3547884</high></valuationRange></rentzestimate>' +
                      '<localRealEstate><region name="Downtown" id="273489" type="neighborhood"><zindexValue>457,900</zindexValue><links>' +
                      '<overview>http://www.zillow.com/local-info/DC-Washington/Downtown/r_273489/</overview><forSaleByOwner>http://www.zillow.com/downtown-washington-dc/fsbo/</forSaleByOwner>' +
                      '<forSale>http://www.zillow.com/downtown-washington-dc/</forSale></links></region></localRealEstate></result></results></response></SearchResults:searchresults>' +
                      '<!-- H:004  T:36ms  S:1289  R:Mon Apr 06 15:13:39 PDT 2015  B:4.0.14071-release_20150326172601-monkey.169e44a-CANDIDATE-b02fcfe-20150331.215139.169e44a3df6a78fa3c7aaf603f10471630160215.20150331175758297-origin/release/20150326172601-monkey -->';
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }

    public class GetDeepSearchResults_NoEndpointAssertions implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            String body = '<?xml version="1.0" encoding="UTF-8"?><SearchResults:searchresults ' +
                          'xsi:schemaLocation="http://www.zillow.com/static/xsd/SearchResults.xsd ' +
                          'http://www.zillowstatic.com/vstatic/ca33129/static/xsd/SearchResults.xsd" ' +
                          'xmlns:SearchResults="http://www.zillow.com/static/xsd/SearchResults.xsd" ' +
                          'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><request><address>1600 pennsylvania avenue</address><citystatezip>20006</citystatezip>' +
                          '</request><message><text>Request successfully processed</text><code>0</code></message><response><results><result><zpid>84074482</zpid>' +
                          '<links><homedetails>http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/</homedetails>' +
                          '<graphsanddata>http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/#charts-and-data</graphsanddata>' +
                          '<mapthishome>http://www.zillow.com/homes/84074482_zpid/</mapthishome><comparables>http://www.zillow.com/homes/comps/84074482_zpid/</comparables>' +
                          '</links><address><street>1600 Pennsylvania Ave NW</street><zipcode>20006</zipcode><city>Washington</city><state>DC</state><latitude>38.89768</latitude>' +
                          '<longitude>-77.03651</longitude></address><FIPScounty>11001</FIPScounty><useCode>SingleFamily</useCode><yearBuilt>1792</yearBuilt><lotSizeSqFt>784080</lotSizeSqFt>' +
                          '<finishedSqFt>55000</finishedSqFt><bathrooms>35.0</bathrooms><bedrooms>16</bedrooms><totalRooms>132</totalRooms><zestimate><amount currency="USD">383409177</amount>' +
                          '<last-updated>04/05/2015</last-updated><oneWeekChange deprecated="true" /><valueChange duration="30" currency="USD">-1418455</valueChange><valuationRange>' +
                          '<low currency="USD">364238719</low><high currency="USD">402579635</high></valuationRange><percentile>0</percentile></zestimate>' +
                          '<rentzestimate><amount currency="USD">1773942</amount><last-updated>03/30/2015</last-updated><oneWeekChange deprecated="true"/>' +
                          '<valueChange duration="30" currency="USD">-8105</valueChange><valuationRange><low currency="USD">1082105</low><high currency="USD">3547884</high></valuationRange></rentzestimate>' +
                          '<localRealEstate><region name="Downtown" id="273489" type="neighborhood"><zindexValue>457,900</zindexValue><links>' +
                          '<overview>http://www.zillow.com/local-info/DC-Washington/Downtown/r_273489/</overview><forSaleByOwner>http://www.zillow.com/downtown-washington-dc/fsbo/</forSaleByOwner>' +
                          '<forSale>http://www.zillow.com/downtown-washington-dc/</forSale></links></region></localRealEstate></result></results></response></SearchResults:searchresults>' +
                          '<!-- H:004  T:36ms  S:1289  R:Mon Apr 06 15:13:39 PDT 2015  B:4.0.14071-release_20150326172601-monkey.169e44a-CANDIDATE-b02fcfe-20150331.215139.169e44a3df6a78fa3c7aaf603f10471630160215.20150331175758297-origin/release/20150326172601-monkey -->';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }

    public class GetUpdatedPropertyDetails implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String actualEndpoint = req.getEndpoint();
            Set<String> expectedParamsAndValues = new Set<String>{
                ZWS_ID_PARAM + EncodingUtil.urlEncode(ZillowUpdateContExt.ZWS_ID, 'UTF-8'),
                ZillowUpdateContExt.ZPID_PARAM + EncodingUtil.urlEncode(ZPID, 'UTF-8')
            };

            List<String> expectedBaseUrlAndParams = ZillowUpdateContExt.GET_UPDATED_PROPERTY_DETAILS_URL.split('\\?');
            List<String> actualBaseUrlAndParams = actualEndpoint.split('\\?');
            Set<String> actualParamsAndValues = new Set<String>(actualBaseUrlAndParams[1].split('&'));

            System.assertEquals(expectedBaseUrlAndParams[0], actualBaseUrlAndParams[0], 'the endpoint should have the correct base url');
            System.assertEquals(expectedParamsAndValues, actualParamsAndValues, 'The endpoint should have the correct params and values');
            System.assertEquals('GET', req.getMethod(), 'The method should be set correctly');

            HttpResponse res = new HttpResponse();
            String body = '<?xml version="1.0" encoding="utf-8"?><UpdatedPropertyDetails:updatedPropertyDetails ' +
                          'xmlns:UpdatedPropertyDetails="http://www.zillow.com/static/xsd/UpdatedPropertyDetails.xsd" ' +
                          'xsi:schemaLocation="http://www.zillow.com/static/xsd/UpdatedPropertyDetails.xsd ' +
                          'http://www.zillowstatic.com/vstatic/ca33129/static/xsd/UpdatedPropertyDetails.xsd" ' +
                          'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><request><zpid>84074482</zpid></request>' +
                          '<message><text>Request successfully processed</text><code>0</code></message><response><zpid>84074482</zpid>' +
                          '<pageViewCount><currentMonth>813</currentMonth><total>314266</total></pageViewCount><address>' +
                          '<street>1600 Pennsylvania Ave NW</street><zipcode>20006</zipcode><city>Washington</city><state>DC</state>' +
                          '<latitude>38.89768</latitude><longitude>-77.03651</longitude></address><links>' +
                          '<homeDetails>http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/' +
                          '</homeDetails><photoGallery>http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/#image=lightbox%3Dtrue</photoGallery>' +
                          '<homeInfo>http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/</homeInfo>' +
                          '</links><images><count>51</count><image><url>http://photos2.zillowstatic.com/p_d/ISx3sl6cgbsxb7.jpg</url>' +
                          '<url>http://photos3.zillowstatic.com/p_d/ISx3lmu2w8qher.jpg</url><url>http://photos3.zillowstatic.com/p_d/ISx1tcpcltboo3.jpg</url>' +
                          '<url>http://photos2.zillowstatic.com/p_d/ISx1tcowtkf8v7.jpg</url><url>http://photos2.zillowstatic.com/p_d/IS110vnts3nsyw3.jpg</url></image>' +
                          '</images><editedFacts><useCode>SingleFamily</useCode><bedrooms>16</bedrooms><bathrooms>35.0</bathrooms><finishedSqFt>55000</finishedSqFt>' +
                          '<lotSizeSqFt>784080</lotSizeSqFt><yearBuilt>1792</yearBuilt><yearUpdated>1949</yearUpdated><numFloors>6</numFloors><numRooms>132</numRooms>' +
                          '<basement>Finished</basement><roof>Other</roof><view>City</view>' +
                          '<appliances>Dishwasher, Dryer, Freezer, Garbage disposal, Microwave, Range / Oven, Refrigerator, Washer</appliances>' +
                          '<floorCovering>Carpet, Concrete, Hardwood</floorCovering>' +
                          '<rooms>Breakfast nook, Dining room, Family room, Laundry room, Library, Master bath, Mud room, Office, Pantry, Recreation room, Workshop, Solarium / Atrium, Sun room, Walk-in closet</rooms>' +
                          '<architecture>Georgian</architecture></editedFacts>' +
                          '<homeDescription>Built in 1792, this magnificent 132-room mansion is the rarest of homes in the U.S. ' +
                          'since it is not only the residence of the U.S. president and his family, but it also has two wings with offices for the president, ' +
                          'the First Lady, top staff and aides. Designed by Irish architect James Hoban, it was built during the Federalist period ' +
                          '(late 1780-1830), but is considered Georgian in the Palladian style with neoclassical influences. After the cornerstone was laid on ' +
                          'October 13, 1792, it was built by slaves, free African-American laborers, immigrants, and salaried Europeans. ' +
                          'Second President John Adams and his wife, Abigail, took occupancy on November 1, 1800. Made from sandstone, brick and wood, ' +
                          'the White House was composed only of the "Residence" and was completed for a cost of $232,371.83. There are three parts to the White House: ' +
                          'The Residence (where the First Family resides), the West Wing (Oval Office and top executive offices) and the East Wing ' +
                          '(First Lady and offices for her staff). The Residence contains 6 levels: the sub-basement (storage, laundry); basement ' +
                          '(Diplomatic Reception room, Map Room, kitchen, curator\'s office, dentist\'s office, one-lane bowling alley); first floor ' +
                          '(the "State Floor" contains the Red Room, Blue Room, Green Room, East Room, State Dining Room, and Family Dining Room); ' +
                          'second floor (the "Family Residence" contains the master bedroom, Lincoln Bedroom, Queens\' Bedroom, Yellow Oval Room, Truman Balcony), ' +
                          'and the third floor (rec, music, and sun rooms). The West Wing contains the president\'s office, the Oval Office and the Situation Room. ' +
                          'There are three levels: the basement (Situation Room, Secret Service Offices, Press Corps Offices); the first floor ' +
                          '(Oval Office, Vice President\'s Office, Chief of Staff Office, Roosevelt Room, Press Briefing Room), and the second floor ' +
                          '(offices of the president\'s staff). The East Wing houses the First Lady\'s office and those of her staff. ' +
                          'It is also where the underground bunker is located.</homeDescription></response></UpdatedPropertyDetails:updatedPropertyDetails>' +
                          '<!-- H:002  T:43ms  S:912  R:Mon Apr 06 15:16:30 PDT 2015  ' +
                          'B:4.0.14071-release_20150326172601-monkey.169e44a-CANDIDATE-b02fcfe-20150331.215139.169e44a3df6a78fa3c7aaf603f10471630160215.20150331175758297-origin/release/20150326172601-monkey -->';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }

    public class GetUpdatedPropertyDetails_NoEndpointAssertions implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            String body = '<?xml version="1.0" encoding="utf-8"?><UpdatedPropertyDetails:updatedPropertyDetails ' +
                          'xmlns:UpdatedPropertyDetails="http://www.zillow.com/static/xsd/UpdatedPropertyDetails.xsd" ' +
                          'xsi:schemaLocation="http://www.zillow.com/static/xsd/UpdatedPropertyDetails.xsd ' +
                          'http://www.zillowstatic.com/vstatic/ca33129/static/xsd/UpdatedPropertyDetails.xsd" ' +
                          'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><request><zpid>84074482</zpid></request>' +
                          '<message><text>Request successfully processed</text><code>0</code></message><response><zpid>84074482</zpid>' +
                          '<pageViewCount><currentMonth>813</currentMonth><total>314266</total></pageViewCount><address>' +
                          '<street>1600 Pennsylvania Ave NW</street><zipcode>20006</zipcode><city>Washington</city><state>DC</state>' +
                          '<latitude>38.89768</latitude><longitude>-77.03651</longitude></address><links>' +
                          '<homeDetails>http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/' +
                          '</homeDetails><photoGallery>http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/#image=lightbox%3Dtrue</photoGallery>' +
                          '<homeInfo>http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/</homeInfo>' +
                          '</links><images><count>51</count><image><url>http://photos2.zillowstatic.com/p_d/ISx3sl6cgbsxb7.jpg</url>' +
                          '<url>http://photos3.zillowstatic.com/p_d/ISx3lmu2w8qher.jpg</url><url>http://photos3.zillowstatic.com/p_d/ISx1tcpcltboo3.jpg</url>' +
                          '<url>http://photos2.zillowstatic.com/p_d/ISx1tcowtkf8v7.jpg</url><url>http://photos2.zillowstatic.com/p_d/IS110vnts3nsyw3.jpg</url></image>' +
                          '</images><editedFacts><useCode>SingleFamily</useCode><bedrooms>16</bedrooms><bathrooms>35.0</bathrooms><finishedSqFt>55000</finishedSqFt>' +
                          '<lotSizeSqFt>784080</lotSizeSqFt><yearBuilt>1792</yearBuilt><yearUpdated>1949</yearUpdated><numFloors>6</numFloors><numRooms>132</numRooms>' +
                          '<basement>Finished</basement><roof>Other</roof><view>City</view>' +
                          '<appliances>Dishwasher, Dryer, Freezer, Garbage disposal, Microwave, Range / Oven, Refrigerator, Washer</appliances>' +
                          '<floorCovering>Carpet, Concrete, Hardwood</floorCovering>' +
                          '<rooms>Breakfast nook, Dining room, Family room, Laundry room, Library, Master bath, Mud room, Office, Pantry, Recreation room, Workshop, Solarium / Atrium, Sun room, Walk-in closet</rooms>' +
                          '<architecture>Georgian</architecture></editedFacts>' +
                          '<homeDescription>Built in 1792, this magnificent 132-room mansion is the rarest of homes in the U.S. ' +
                          'since it is not only the residence of the U.S. president and his family, but it also has two wings with offices for the president, ' +
                          'the First Lady, top staff and aides. Designed by Irish architect James Hoban, it was built during the Federalist period ' +
                          '(late 1780-1830), but is considered Georgian in the Palladian style with neoclassical influences. After the cornerstone was laid on ' +
                          'October 13, 1792, it was built by slaves, free African-American laborers, immigrants, and salaried Europeans. ' +
                          'Second President John Adams and his wife, Abigail, took occupancy on November 1, 1800. Made from sandstone, brick and wood, ' +
                          'the White House was composed only of the "Residence" and was completed for a cost of $232,371.83. There are three parts to the White House: ' +
                          'The Residence (where the First Family resides), the West Wing (Oval Office and top executive offices) and the East Wing ' +
                          '(First Lady and offices for her staff). The Residence contains 6 levels: the sub-basement (storage, laundry); basement ' +
                          '(Diplomatic Reception room, Map Room, kitchen, curator\'s office, dentist\'s office, one-lane bowling alley); first floor ' +
                          '(the "State Floor" contains the Red Room, Blue Room, Green Room, East Room, State Dining Room, and Family Dining Room); ' +
                          'second floor (the "Family Residence" contains the master bedroom, Lincoln Bedroom, Queens\' Bedroom, Yellow Oval Room, Truman Balcony), ' +
                          'and the third floor (rec, music, and sun rooms). The West Wing contains the president\'s office, the Oval Office and the Situation Room. ' +
                          'There are three levels: the basement (Situation Room, Secret Service Offices, Press Corps Offices); the first floor ' +
                          '(Oval Office, Vice President\'s Office, Chief of Staff Office, Roosevelt Room, Press Briefing Room), and the second floor ' +
                          '(offices of the president\'s staff). The East Wing houses the First Lady\'s office and those of her staff. ' +
                          'It is also where the underground bunker is located.</homeDescription></response></UpdatedPropertyDetails:updatedPropertyDetails>' +
                          '<!-- H:002  T:43ms  S:912  R:Mon Apr 06 15:16:30 PDT 2015  ' +
                          'B:4.0.14071-release_20150326172601-monkey.169e44a-CANDIDATE-b02fcfe-20150331.215139.169e44a3df6a78fa3c7aaf603f10471630160215.20150331175758297-origin/release/20150326172601-monkey -->';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }

    public class ErrorPropertyNotFound_GetDeepSearchResults implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String actualEndpoint = req.getEndpoint();
            Set<String> expectedParamsAndValues = new Set<String>{
                ZillowUpdateContExt.ADDRESS_PARAM + EncodingUtil.urlEncode(PROPERTY_NAME, 'UTF-8'),
                ZillowUpdateContExt.CITY_STATE_ZIP_PARAM + EncodingUtil.urlEncode(ZIP, 'UTF-8'),
                ZWS_ID_PARAM + EncodingUtil.urlEncode(ZillowUpdateContExt.ZWS_ID, 'UTF-8'),
                ZillowUpdateContExt.RENT_ZESTIMATE_PARAM + EncodingUtil.urlEncode('true', 'UTF-8')
            };

            List<String> expectedBaseUrlAndParams = ZillowUpdateContExt.GET_DEEP_SEARCH_RESULTS_URL.split('\\?');
            List<String> actualBaseUrlAndParams = actualEndpoint.split('\\?');
            Set<String> actualParamsAndValues = new Set<String>(actualBaseUrlAndParams[1].split('&'));

            System.assertEquals(expectedBaseUrlAndParams[0], actualBaseUrlAndParams[0], 'the endpoint should have the correct base url');
            System.assertEquals(expectedParamsAndValues, actualParamsAndValues, 'The endpoint should have the correct params and values');
            System.assertEquals('GET', req.getMethod(), 'The method should be set correctly');

            HttpResponse res = new HttpResponse();
            String body = '<?xml version="1.0" encoding="utf-8"?><SearchResults:searchresults ' +
                          'xsi:schemaLocation="http://www.zillow.com/static/xsd/SearchResults.xsd ' +
                          'http://www.zillowstatic.com/vstatic/ca33129/static/xsd/SearchResults.xsd" ' +
                          'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SearchResults="http://www.zillow.com/static/xsd/SearchResults.xsd">' +
                          '<request><address>2114 Bigelow Ave</address><citystatezip>94122</citystatezip></request>' +
                          '<message><text>Error: no exact match found for input address</text><code>508</code></message>' +
                          '</SearchResults:searchresults><!-- H:001  T:63ms  S:150  R:Tue Apr 07 11:59:19 PDT 2015  ' +
                          'B:4.0.14071-release_20150326172601-monkey.169e44a-CANDIDATE-b02fcfe-20150331.215139.169e44a3df6a78fa3c7aaf603f10471630160215.20150331175758297-origin/release/20150326172601-monkey -->';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }

    public class MissingNode_GetDeepSearchResults implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String actualEndpoint = req.getEndpoint();
            Set<String> expectedParamsAndValues = new Set<String>{
                ZillowUpdateContExt.ADDRESS_PARAM + EncodingUtil.urlEncode(PROPERTY_NAME, 'UTF-8'),
                ZillowUpdateContExt.CITY_STATE_ZIP_PARAM + EncodingUtil.urlEncode(ZIP, 'UTF-8'),
                ZWS_ID_PARAM + EncodingUtil.urlEncode(ZillowUpdateContExt.ZWS_ID, 'UTF-8'),
                ZillowUpdateContExt.RENT_ZESTIMATE_PARAM + EncodingUtil.urlEncode('true', 'UTF-8')
            };

            List<String> expectedBaseUrlAndParams = ZillowUpdateContExt.GET_DEEP_SEARCH_RESULTS_URL.split('\\?');
            List<String> actualBaseUrlAndParams = actualEndpoint.split('\\?');
            Set<String> actualParamsAndValues = new Set<String>(actualBaseUrlAndParams[1].split('&'));

            System.assertEquals(expectedBaseUrlAndParams[0], actualBaseUrlAndParams[0], 'the endpoint should have the correct base url');
            System.assertEquals(expectedParamsAndValues, actualParamsAndValues, 'The endpoint should have the correct params and values');
            System.assertEquals('GET', req.getMethod(), 'The method should be set correctly');

            HttpResponse res = new HttpResponse();
            String body = '<?xml version="1.0" encoding="UTF-8"?><SearchResults:searchresults ' +
                      'xsi:schemaLocation="http://www.zillow.com/static/xsd/SearchResults.xsd ' +
                      'http://www.zillowstatic.com/vstatic/ca33129/static/xsd/SearchResults.xsd" ' +
                      'xmlns:SearchResults="http://www.zillow.com/static/xsd/SearchResults.xsd" ' +
                      'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><request><address>1600 pennsylvania avenue</address><citystatezip>20006</citystatezip>' +
                      '</request><message><text>Request successfully processed</text><code>0</code></message><response><results><result><zpid>84074482</zpid>' +
                      '<links><homedetails>http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/</homedetails>' +
                      '<graphsanddata>http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/#charts-and-data</graphsanddata>' +
                      '<mapthishome>http://www.zillow.com/homes/84074482_zpid/</mapthishome><comparables>http://www.zillow.com/homes/comps/84074482_zpid/</comparables>' +
                      '</links><address><street>1600 Pennsylvania Ave NW</street><zipcode>20006</zipcode><city>Washington</city><state>DC</state><latitude>38.89768</latitude>' +
                      '<longitude>-77.03651</longitude></address><FIPScounty>11001</FIPScounty><useCode>SingleFamily</useCode><yearBuilt>1792</yearBuilt><lotSizeSqFt>784080</lotSizeSqFt>' +
                      '<finishedSqFt>55000</finishedSqFt><bathrooms>35.0</bathrooms><bedrooms>16</bedrooms><totalRooms>132</totalRooms><zestimate><amount currency="USD">383409177</amount>' +
                      '<last-updated>04/05/2015</last-updated><oneWeekChange deprecated="true" /><valueChange duration="30" currency="USD">-1418455</valueChange><valuationRange>' +
                      '<low currency="USD">364238719</low><high currency="USD">402579635</high></valuationRange><percentile>0</percentile></zestimate>' +
                      '<rentzestimate><last-updated>03/30/2015</last-updated><oneWeekChange deprecated="true"/>' +
                      '<valueChange duration="30" currency="USD">-8105</valueChange><valuationRange><low currency="USD">1082105</low><high currency="USD">3547884</high></valuationRange></rentzestimate>' +
                      '<localRealEstate><region name="Downtown" id="273489" type="neighborhood"><zindexValue>457,900</zindexValue><links>' +
                      '<overview>http://www.zillow.com/local-info/DC-Washington/Downtown/r_273489/</overview><forSaleByOwner>http://www.zillow.com/downtown-washington-dc/fsbo/</forSaleByOwner>' +
                      '<forSale>http://www.zillow.com/downtown-washington-dc/</forSale></links></region></localRealEstate></result></results></response></SearchResults:searchresults>' +
                      '<!-- H:004  T:36ms  S:1289  R:Mon Apr 06 15:13:39 PDT 2015  B:4.0.14071-release_20150326172601-monkey.169e44a-CANDIDATE-b02fcfe-20150331.215139.169e44a3df6a78fa3c7aaf603f10471630160215.20150331175758297-origin/release/20150326172601-monkey -->';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }

    public class MissingNode_GetUpdatedPropertyDetails implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String actualEndpoint = req.getEndpoint();
            Set<String> expectedParamsAndValues = new Set<String>{
                ZWS_ID_PARAM + EncodingUtil.urlEncode(ZillowUpdateContExt.ZWS_ID, 'UTF-8'),
                ZillowUpdateContExt.ZPID_PARAM + EncodingUtil.urlEncode(ZPID, 'UTF-8')
            };

            List<String> expectedBaseUrlAndParams = ZillowUpdateContExt.GET_UPDATED_PROPERTY_DETAILS_URL.split('\\?');
            List<String> actualBaseUrlAndParams = actualEndpoint.split('\\?');
            Set<String> actualParamsAndValues = new Set<String>(actualBaseUrlAndParams[1].split('&'));

            System.assertEquals(expectedBaseUrlAndParams[0], actualBaseUrlAndParams[0], 'the endpoint should have the correct base url');
            System.assertEquals(expectedParamsAndValues, actualParamsAndValues, 'The endpoint should have the correct params and values');
            System.assertEquals('GET', req.getMethod(), 'The method should be set correctly');

            HttpResponse res = new HttpResponse();
            String body = '<?xml version="1.0" encoding="utf-8"?><UpdatedPropertyDetails:updatedPropertyDetails ' +
                          'xmlns:UpdatedPropertyDetails="http://www.zillow.com/static/xsd/UpdatedPropertyDetails.xsd" ' +
                          'xsi:schemaLocation="http://www.zillow.com/static/xsd/UpdatedPropertyDetails.xsd ' +
                          'http://www.zillowstatic.com/vstatic/ca33129/static/xsd/UpdatedPropertyDetails.xsd" ' +
                          'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><request><zpid>84074482</zpid></request>' +
                          '<message><text>Request successfully processed</text><code>0</code></message><response><zpid>84074482</zpid>' +
                          '<pageViewCount><currentMonth>813</currentMonth><total>314266</total></pageViewCount><address>' +
                          '<street>1600 Pennsylvania Ave NW</street><zipcode>20006</zipcode><city>Washington</city><state>DC</state>' +
                          '<latitude>38.89768</latitude><longitude>-77.03651</longitude></address><links>' +
                          '<homeDetails>http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/' +
                          '</homeDetails><photoGallery>http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/#image=lightbox%3Dtrue</photoGallery>' +
                          '<homeInfo>http://www.zillow.com/homedetails/1600-Pennsylvania-Ave-NW-Washington-DC-20006/84074482_zpid/</homeInfo>' +
                          '</links><images><count>51</count></images><editedFacts><useCode>SingleFamily</useCode><bedrooms>16</bedrooms><bathrooms>35.0</bathrooms><finishedSqFt>55000</finishedSqFt>' +
                          '<lotSizeSqFt>784080</lotSizeSqFt><yearBuilt>1792</yearBuilt><yearUpdated>1949</yearUpdated><numFloors>6</numFloors><numRooms>132</numRooms>' +
                          '<basement>Finished</basement><roof>Other</roof><view>City</view>' +
                          '<appliances>Dishwasher, Dryer, Freezer, Garbage disposal, Microwave, Range / Oven, Refrigerator, Washer</appliances>' +
                          '<floorCovering>Carpet, Concrete, Hardwood</floorCovering>' +
                          '<rooms>Breakfast nook, Dining room, Family room, Laundry room, Library, Master bath, Mud room, Office, Pantry, Recreation room, Workshop, Solarium / Atrium, Sun room, Walk-in closet</rooms>' +
                          '<architecture>Georgian</architecture></editedFacts>' +
                          '<homeDescription>Built in 1792, this magnificent 132-room mansion is the rarest of homes in the U.S. ' +
                          'since it is not only the residence of the U.S. president and his family, but it also has two wings with offices for the president, ' +
                          'the First Lady, top staff and aides. Designed by Irish architect James Hoban, it was built during the Federalist period ' +
                          '(late 1780-1830), but is considered Georgian in the Palladian style with neoclassical influences. After the cornerstone was laid on ' +
                          'October 13, 1792, it was built by slaves, free African-American laborers, immigrants, and salaried Europeans. ' +
                          'Second President John Adams and his wife, Abigail, took occupancy on November 1, 1800. Made from sandstone, brick and wood, ' +
                          'the White House was composed only of the "Residence" and was completed for a cost of $232,371.83. There are three parts to the White House: ' +
                          'The Residence (where the First Family resides), the West Wing (Oval Office and top executive offices) and the East Wing ' +
                          '(First Lady and offices for her staff). The Residence contains 6 levels: the sub-basement (storage, laundry); basement ' +
                          '(Diplomatic Reception room, Map Room, kitchen, curator\'s office, dentist\'s office, one-lane bowling alley); first floor ' +
                          '(the "State Floor" contains the Red Room, Blue Room, Green Room, East Room, State Dining Room, and Family Dining Room); ' +
                          'second floor (the "Family Residence" contains the master bedroom, Lincoln Bedroom, Queens\' Bedroom, Yellow Oval Room, Truman Balcony), ' +
                          'and the third floor (rec, music, and sun rooms). The West Wing contains the president\'s office, the Oval Office and the Situation Room. ' +
                          'There are three levels: the basement (Situation Room, Secret Service Offices, Press Corps Offices); the first floor ' +
                          '(Oval Office, Vice President\'s Office, Chief of Staff Office, Roosevelt Room, Press Briefing Room), and the second floor ' +
                          '(offices of the president\'s staff). The East Wing houses the First Lady\'s office and those of her staff. ' +
                          'It is also where the underground bunker is located.</homeDescription></response></UpdatedPropertyDetails:updatedPropertyDetails>' +
                          '<!-- H:002  T:43ms  S:912  R:Mon Apr 06 15:16:30 PDT 2015  ' +
                          'B:4.0.14071-release_20150326172601-monkey.169e44a-CANDIDATE-b02fcfe-20150331.215139.169e44a3df6a78fa3c7aaf603f10471630160215.20150331175758297-origin/release/20150326172601-monkey -->';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }

    public class ErrorPropertyNotFound_GetUpdatedPropertyDetails implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String actualEndpoint = req.getEndpoint();
            Set<String> expectedParamsAndValues = new Set<String>{
                ZWS_ID_PARAM + EncodingUtil.urlEncode(ZillowUpdateContExt.ZWS_ID, 'UTF-8'),
                ZillowUpdateContExt.ZPID_PARAM + EncodingUtil.urlEncode(ZPID, 'UTF-8')
            };

            List<String> expectedBaseUrlAndParams = ZillowUpdateContExt.GET_UPDATED_PROPERTY_DETAILS_URL.split('\\?');
            List<String> actualBaseUrlAndParams = actualEndpoint.split('\\?');
            Set<String> actualParamsAndValues = new Set<String>(actualBaseUrlAndParams[1].split('&'));

            System.assertEquals(expectedBaseUrlAndParams[0], actualBaseUrlAndParams[0], 'the endpoint should have the correct base url');
            System.assertEquals(expectedParamsAndValues, actualParamsAndValues, 'The endpoint should have the correct params and values');
            System.assertEquals('GET', req.getMethod(), 'The method should be set correctly');

            HttpResponse res = new HttpResponse();
            String body = '<?xml version="1.0" encoding="utf-8"?><UpdatedPropertyDetails:updatedPropertyDetails ' +
                          'xmlns:UpdatedPropertyDetails="http://www.zillow.com/static/xsd/UpdatedPropertyDetails.xsd" ' +
                          'xsi:schemaLocation="http://www.zillow.com/static/xsd/UpdatedPropertyDetails.xsd ' +
                          'http://www.zillowstatic.com/vstatic/ca33129/static/xsd/UpdatedPropertyDetails.xsd" ' +
                          'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><request><zpid>487494250</zpid></request>' +
                          '<message><text>Error: invalid zpid parameter</text><code>500</code></message></UpdatedPropertyDetails:updatedPropertyDetails>' +
                          '<!-- H:003  T:4ms  S:115  R:Tue Apr 07 13:14:46 PDT 2015  ' +
                          'B:4.0.14071-release_20150326172601-monkey.169e44a-CANDIDATE-b02fcfe-20150331.215139.169e44a3df6a78fa3c7aaf603f10471630160215.20150331175758297-origin/release/20150326172601-monkey -->';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }

    public class ErrorCodeGreaterThan399 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus(BAD_REQUEST);
            res.setStatusCode(Integer.valueOf(ERROR_CODE_RESPONSE));
            return res;
        }
    }
}