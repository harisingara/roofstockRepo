//may 10
public class searchRentalListingController {
  private static boolean chkrecord = false;
  private static boolean checkInactive = false;
  @AuraEnabled(cacheable=true)
  public static list<Rental_Listing__c> getRentalListingList(
    Integer pagenumber,
    Integer numberOfRecords,
    Integer pageSize,
    string sMarketkey,
    double dbedkey,
    double dbathkey,
    string sStatuskey,
    string sAddresskey
  ) {
    string sTempAddressKey = '%' + sAddresskey + '%';

    list<Rental_Listing__c> lstRentalListing = new List<Rental_Listing__c>();
    string query = 'Select Id,Name,Market__c,Bedrooms__c,Bathrooms__c,Current_Rent__c,Status__c From Rental_Listing__c ';

    if ((sMarketkey != null && sMarketkey != '' && sMarketkey != 'None')) {
      query += 'WHERE Market__c =: sMarketkey ';
      if (dbedkey != null && dbedkey > 0.0) {
        query += ' and Bedrooms__c =: dbedkey';
      }
      if (dbathkey != null && dbathkey > 0.0) {
        query += ' and Bathrooms__c =: dbathkey';
      }
      if (sStatuskey != null && sStatuskey != '' && sStatuskey != 'None') {
        query += ' and Status__c = : sStatuskey';
      }
      if (sAddresskey != null && sAddresskey != '') {
        query += ' and Name LIKE : sTempAddressKey';
      }
    } else if ((dbedkey != null && dbedkey > 0.0)) {
      query += 'WHERE Bedrooms__c =: dbedkey ';

      if (dbathkey != null && dbathkey > 0.0) {
        query += ' and Bathrooms__c =: dbathkey';
      }
      if (sStatuskey != null && sStatuskey != '' && sStatuskey != 'None') {
        query += ' and Status__c = : sStatuskey';
      }
      if (sAddresskey != null && sAddresskey != '') {
        query += ' and Name LIKE : sTempAddressKey';
      }
    } else if (dbathkey != null && dbathkey > 0.0) {
      query += 'WHERE Bathrooms__c =: dbathkey ';

      if (sStatuskey != null && sStatuskey != '' && sStatuskey != 'None') {
        query += ' and Status__c = : sStatuskey';
      }
      if (sAddresskey != null && sAddresskey != '') {
        query += ' and Name LIKE : sTempAddressKey';
      }
    } else if (sStatuskey != null && sStatuskey != '' && sStatuskey != 'None') {
      query += 'WHERE Status__c = : sStatuskey ';
      if (sAddresskey != null && sAddresskey != '') {
        query += ' and Name LIKE : sTempAddressKey';
      }
    } else if (sAddresskey != null && sAddresskey != '') {
      query += 'WHERE Name LIKE : sTempAddressKey ';
    }
    query += ' limit ' + pageSize + ' offset ' + (pageSize * (pagenumber - 1));

    lstRentalListing = Database.query(query);
    if (lstRentalListing.size() == 0) {
      throw new AuraHandledException('No Record Found..');
    }
    return lstRentalListing;
  }

  @AuraEnabled(cacheable=true)
  public static Integer getRentalListingCount(
    string sMarketkey,
    double dbedkey,
    double dbathkey,
    string sStatuskey,
    string sAddresskey
  ) {
    string sTempAddressKey = '%' + sAddresskey + '%';

    list<Rental_Listing__c> lstRentalListing = new List<Rental_Listing__c>();
    string query = 'Select count() From Rental_Listing__c ';

    if ((sMarketkey != null && sMarketkey != '' && sMarketkey != 'None')) {
      query += 'WHERE Market__c =: sMarketkey ';
      if (dbedkey != null && dbedkey > 0.0) {
        query += ' and Bedrooms__c =: dbedkey';
      }
      if (dbathkey != null && dbathkey > 0.0) {
        query += ' and Bathrooms__c =: dbathkey';
      }
      if (sStatuskey != null && sStatuskey != '' && sStatuskey != 'None') {
        query += ' and Status__c = : sStatuskey';
      }
      if (sAddresskey != null && sAddresskey != '') {
        query += ' and Name LIKE : sTempAddressKey';
      }
    } else if ((dbedkey != null && dbedkey > 0.0)) {
      query += 'WHERE Bedrooms__c =: dbedkey ';

      if (dbathkey != null && dbathkey > 0.0) {
        query += ' and Bathrooms__c =: dbathkey';
      }
      if (sStatuskey != null && sStatuskey != '' && sStatuskey != 'None') {
        query += ' and Status__c = : sStatuskey';
      }
      if (sAddresskey != null && sAddresskey != '') {
        query += ' and Name LIKE : sTempAddressKey';
      }
    } else if (dbathkey != null && dbathkey > 0.0) {
      query += 'WHERE Bathrooms__c =: dbathkey ';

      if (sStatuskey != null && sStatuskey != '' && sStatuskey != 'None') {
        query += ' and Status__c = : sStatuskey';
      }
      if (sAddresskey != null && sAddresskey != '') {
        query += ' and Name LIKE : sTempAddressKey';
      }
    } else if (sStatuskey != null && sStatuskey != '' && sStatuskey != 'None') {
      query += 'WHERE Status__c = : sStatuskey ';
      if (sAddresskey != null && sAddresskey != '') {
        query += ' and Name LIKE : sTempAddressKey';
      }
    } else if (sAddresskey != null && sAddresskey != '') {
      query += 'WHERE Name LIKE : sTempAddressKey ';
    }

    return Database.countQuery(query);
  }

  @AuraEnabled(cacheable=true)
  public static boolean checkORURecordExist(
    list<Id> rentallistingid,
    string oppid
  ) {
    if ((oppid != null && oppid != '')) {
      list<OpportunityRentalUnit__c> lstORUnit = new List<OpportunityRentalUnit__c>();
      for (OpportunityRentalUnit__c ORUnit : [
        SELECT id, Name, Leasing__c, Opportunity__c
        FROM OpportunityRentalUnit__c
        WHERE Leasing__c IN :rentallistingid AND Opportunity__c = :oppid
      ]) {
        lstORUnit.add(ORUnit);
      }

      if (lstORUnit.size() > 0) {
        chkrecord = true;
      } else {
        chkrecord = false;
      }
    }
    return chkrecord;
  }

  @AuraEnabled(cacheable=true)
  public static boolean checkForInactiveStatus(list<Id> rentallistingid) {
    list<Rental_Listing__c> lstRentalListing = new List<Rental_Listing__c>();
    for (Rental_Listing__c rlisting : [
      SELECT id, Name, Status__c
      FROM Rental_Listing__c
      WHERE Status__c = :'Inactive' AND id IN :rentallistingid
    ]) {
      lstRentalListing.add(rlisting);
    }
    if (lstRentalListing.size() > 0) {
      checkInactive = true;
    } else {
      checkInactive = false;
    }
    return checkInactive;
  }
}