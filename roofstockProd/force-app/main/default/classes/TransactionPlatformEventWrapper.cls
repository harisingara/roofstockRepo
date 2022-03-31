public class TransactionPlatformEventWrapper {
    public class TransactionContact {       
        public String contactNumber;
        public String type;
        public String email;
        public string mobile;
        public string bpmContactId;
        public string rsAccountId;
        public string roofstockUserId; 
        public string firstName;
        public string lastName ;
        public string companyName;        
    }
	public class Inspection {       
        public String inspectionId;
        public String diligenceDeadline;
        public String inspectionDueDate;
    }
    public class PropertyUnit {
        public String id;
        public String property_access_notes;
        public String property_access_method_type;
        public String occupancy;
        public String unitId;
    }
    public class transactionSettlement {
        public decimal emdAmount;
        public decimal optionFeeAmount;
    }
    public class transactionContractQcTask {
        public String status;
        public String description;
    }
    public class Property {
        public Boolean hoa; 
    }
}