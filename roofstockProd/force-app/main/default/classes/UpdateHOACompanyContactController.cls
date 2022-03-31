/**
 * This class is used to get and set the vendor details on HOA Object as - HOA Company and HOA Company Contact.
 * This class is accesible via LWC page : updateHOACompanyContact
 */

public with sharing class UpdateHOACompanyContactController {
    
    @AuraEnabled
    public static List<Vendor__c> vendorRecords(String recordId){
        List<String> vCode = new List<String>();
        List<Vendor__c> vndr = new List<Vendor__c>();
        try {
            HOA__C hoaRecord = [SELECT id, HOA_Company1__c, HOA_Company_Contact1__c FROM HOA__C where Id = :recordId];  
            
            vCode.add(hoaRecord.HOA_Company1__c);
            vCode.add(hoaRecord.HOA_Company_Contact1__c);
            
            vndr =  [SELECT id,Name,Email__c,Phone__c,HOA_Company_Account__c,Type__c,Remittance_Address__c FROM Vendor__c where Id IN :vCode and Service_Type__c = 'HOA'];
            if(!vndr.isEmpty()){
                return vndr;
            }
            return vndr;
        } catch (Exception e) {
            return vndr;
        }
    }

    @AuraEnabled
    public static Boolean saveHOAVendorInfo( String updatedVendorInput, String recordId){
        HOAVendorwrapper deserializeResults;
        List<String> vendorName = new List<String>();
        Map<String,String> mapVendorAndType = new Map<String,String>();
        Map<String,Id> mapVendorAndCode = new Map<String,Id>();
        Map<String,String> mapVendorTypeAndId = new Map<String,String>();
        Map<String,String> vendorEmailNameMap = new Map<String,String>();
        Map<String,Id> mapEmailAndId = new Map<String,Id>();
        Map<Id,String> mapUpdateAddress =  new Map<Id,String>();
        Map<Id,String> mapUpdatePhone =  new Map<Id,String>();
        Map<Id,String> updateHoaCompanyAccount =  new Map<Id,String>();
        String sameName = '';
        try {
            system.debug('Input Value::'+updatedVendorInput);
            Type resultType = Type.forName('UpdateHOACompanyContactController.HOAVendorwrapper');
            deserializeResults =       (HOAVendorwrapper)JSON.deserialize(updatedVendorInput, resultType);
            System.debug(' deserialized results = ' + deserializeResults);
            if(deserializeResults.companyName != null && deserializeResults.companyName != '') {
                vendorName.add(deserializeResults.companyName.toLowercase());
            }
            if(deserializeResults.name != null && deserializeResults.name != '') {
                vendorName.add(deserializeResults.name.toLowercase());
            }
            if(deserializeResults.email != null && deserializeResults.email != '') {
                vendorEmailNameMap.put(deserializeResults.name.toLowercase(), deserializeResults.Email.toLowercase());
            }
            if (deserializeResults.name.toLowercase() == deserializeResults.companyName.toLowercase()) {
                sameName = deserializeResults.name.toLowercase();
            }

            if(!vendorName.isEmpty()) {
                
                for(Vendor__c ven:  [SELECT id,Type__c,Vendor_Code__c, Name, Email__c, Remittance_Address__c, Phone__c, HOA_Company_Account__c
                                       FROM Vendor__c 
                                      WHERE Name In :vendorName and Service_Type__c = 'HOA']) {
                                        system.debug('vendors is:: '+ven);
                                        mapVendorAndCode.put(ven.Name.toLowercase(),ven.Id);
                                        if(ven.Email__c != null && deserializeResults.Email != null && ven.Email__c.toLowercase() == deserializeResults.Email.toLowercase()){
                                            mapEmailAndId.put(ven.Email__c.toLowercase(),Ven.Id);
                                        }
                                        if( ven.Email__c != null && deserializeResults.Email != null && ven.Email__c.toLowercase() == deserializeResults.Email.toLowercase() && 
                                            deserializeResults.remittanceAddress != null && 
                                            ((ven.Remittance_Address__c != null && ven.Remittance_Address__c.toLowerCase() != deserializeResults.remittanceAddress.toLowerCase()) || 
                                              ven.Remittance_Address__c == null ) && ven.Type__c == 'HOA Company Contact') {
                                                  mapUpdateAddress.put(ven.Id,deserializeResults.remittanceAddress);
                                        }  
                                        if( ven.Email__c != null && deserializeResults.Email != null && ven.Email__c.toLowercase() == deserializeResults.Email.toLowercase() &&
                                            deserializeResults.phone != null && ven.Phone__c != deserializeResults.phone && ven.Type__c == 'HOA Company Contact') {
                                            mapUpdatePhone.put(ven.Id,deserializeResults.phone);
                                        }
                                        if(ven.HOA_Company_Account__c != deserializeResults.rsAccountId && ven.Type__c == 'HOA Company') {
                                            updateHoaCompanyAccount.put(ven.id,deserializeResults.rsAccountId);
                                        }           
                                        mapVendorTypeAndId.put(ven.Type__c, ven.Id);
                                  }
            }
            List<Vendor__c> updateHoaVendor = new List<Vendor__c>();
            system.debug('map of address:: '+mapUpdateAddress);
            system.debug('map of phone:: '+mapUpdatePhone);
            for(Id id : mapUpdateAddress.keyset()){
                Vendor__c updateVen =  new Vendor__c();
                updateVen.Id = id;
                updateVen.Remittance_Address__c = mapUpdateAddress.get(id);
                updateVen.Phone__C = mapUpdatePhone.get(id);
                updateHoaVendor.add(updateVen);
            }
            if(mapUpdateAddress.isEmpty()) {
                for(Id id : mapUpdatePhone.keyset()){
                    Vendor__c updateVen =  new Vendor__c();
                    updateVen.Id = id;
                    updateVen.Phone__C = mapUpdatePhone.get(id);
                    updateHoaVendor.add(updateVen);
                }
            }
            
            for(Id id : updateHoaCompanyAccount.keyset()) {
                Vendor__c updateVen =  new Vendor__c();
                updateVen.Id = id;
                updateVen.HOA_Company_Account__c = updateHoaCompanyAccount.get(id);
                updateHoaVendor.add(updateVen);
            }
            system.debug('value for hoa vendor:: '+updateHoaVendor);
            if(!updateHoaVendor.isEmpty()) {
                Update updateHoaVendor;
            }

            List<Vendor__c> insertHoaContact = new List<Vendor__c>();
            string emailID = vendorEmailNameMap.get(sameName);
            if(deserializeResults.name.toLowercase() == deserializeResults.companyName.toLowercase()) {
                // new logic to differentiate
                if((!mapVendorAndCode.containsKey(sameName) || !mapEmailAndId.containsKey(emailId)) && sameName == deserializeResults.name.toLowercase()) {
                    insertHoaContact.add(new Vendor__c(Name= deserializeResults.name,Remittance_Address__c=deserializeResults.remittanceAddress,
                                                        Email__c = deserializeResults.email, Phone__c= deserializeResults.phone,
                                                        Type__c = 'HOA Company Contact', Service_Type__c = 'HOA'));
    
                }
                if(!mapVendorAndCode.containsKey(sameName) && sameName == deserializeResults.companyName.toLowercase() ) {
                    insertHoaContact.add(new Vendor__c(Name= deserializeResults.companyName, HOA_Company_Account__c=deserializeResults.rsAccountId, 
                                                       Type__c = 'HOA Company',Service_Type__c = 'HOA'));
                }

            } else{
                // below logic
                for(String vName : vendorName) {
                    string email = vendorEmailNameMap.get(vName);
                    if((!mapVendorAndCode.containsKey(vName) || !mapEmailAndId.containsKey(email) ) && vName == deserializeResults.name.toLowercase()) {
                        insertHoaContact.add(new Vendor__c(Name= deserializeResults.name,Remittance_Address__c=deserializeResults.remittanceAddress,
                                                           Email__c = deserializeResults.email, Phone__c= deserializeResults.phone,
                                                           Type__c = 'HOA Company Contact',Service_Type__c = 'HOA'));
        
                    }
                    if(!mapVendorAndCode.containsKey(vName) && vName == deserializeResults.companyName.toLowercase() ) {
                        insertHoaContact.add(new Vendor__c(Name= deserializeResults.companyName, HOA_Company_Account__c=deserializeResults.rsAccountId,
                                                           Type__c = 'HOA Company',Service_Type__c = 'HOA'));
                    }
                }
            }
            
            

            if (null <> insertHoaContact) {
                Database.SaveResult[] result = Database.insert(insertHoaContact, false);
                system.debug('BPM contact ::'+result);
            }

            for (Vendor__c cnct : insertHoaContact) {
                mapVendorAndCode.put(cnct.name.toLowerCase(), cnct.Id);
                mapVendorTypeAndId.put(cnct.Type__c, cnct.Id);
                if(cnct.Type__c == 'HOA Company Contact') {
                    mapEmailAndId.put(cnct.Email__c.toLowercase(),cnct.Id);
                }
                
            }

            
            HOA__c newHoa = new HOA__c();
            newHoa.id = recordId;
            newHoa.HOA_Company_Contact1__c = (deserializeResults.name.toLowercase() == deserializeResults.companyName.toLowercase())? (deserializeResults.email != null && deserializeResults.email != '') ? mapEmailAndId.get(deserializeResults.email.toLowercase()) : mapVendorTypeAndId.get('HOA Company Contact') :  (deserializeResults.email != null && deserializeResults.email != '') ? mapEmailAndId.get(deserializeResults.email.toLowercase()) : mapVendorAndCode.get(deserializeResults.name.toLowercase());
            // newHoa.HOA_Company1__c = (deserializeResults.name.toLowercase() == deserializeResults.companyName.toLowercase())? mapVendorTypeAndId.get('HOA Company') : mapVendorAndCode.get(deserializeResults.companyName.toLowercase());
            newHoa.HOA_Company1__c = mapVendorTypeAndId.get('HOA Company');
            newHoa.HOA_Property_Manager_Remittance_Address__c = deserializeResults.remittanceAddress;
            update newHoa;

            return true;
        
        } catch (Exception e) {
            
            return false;
        }
    }

    public class HOAVendorwrapper {
        @AuraEnabled public String companyName;
        @AuraEnabled public String rsAccountId;
        @AuraEnabled public String name;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public String remittanceAddress;
    }
}