global class TransactionSnapshotWrapper implements Comparable{
    public Transaction_Snapshot__c snapshot;
    public TransactionSnapshotWrapper(Transaction_Snapshot__c snap){
        snapshot = snap;
    }

    // Compare snapshots based on HomeCode__c, Sort_Order__C
    global Integer compareTo(Object compareTo){

        TransactionSnapshotWrapper compareToSnapshot = (TransactionSnapshotWrapper)compareTo;

        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (String.isBlank(snapshot.HomeCode__c)){
            if (snapshot.Sort_Order__C > compareToSnapshot.snapshot.Sort_Order__C){
                returnValue = 1;
            } else if (snapshot.Sort_Order__C < compareToSnapshot.snapshot.Sort_Order__C){
                returnValue = -1;
            }
        } else{
            if (snapshot.HomeCode__c > compareToSnapshot.snapshot.HomeCode__c){
                returnValue = 1;
            } else if (snapshot.HomeCode__c < compareToSnapshot.snapshot.HomeCode__c){
                returnValue = -1;
            }
        }
        return returnValue;
    }

    public static List<Transaction_Snapshot__c> sortTransactionSnapshots(List<Transaction_Snapshot__c> snapshotList){

        List<Transaction_Snapshot__c> sortedSnapshotList = new List<Transaction_Snapshot__c>();

        // Convert Transaction_Snapshot__c list to TransactionSnapshotWrapper list
        List<TransactionSnapshotWrapper> snapshotWrapperList = new List<TransactionSnapshotWrapper>();
        for (Transaction_Snapshot__c snapshotObj : snapshotList){
            snapshotWrapperList.add(new TransactionSnapshotWrapper(snapshotObj));
        }
        snapshotWrapperList.sort (); // Sort the list

        // Construct a new sorted Transaction_Snapshot__c list
        for (TransactionSnapshotWrapper snapshotWrapper : snapshotWrapperList){
            sortedSnapshotList.add(snapshotWrapper.snapshot);
        }
        return sortedSnapshotList;
    }

}