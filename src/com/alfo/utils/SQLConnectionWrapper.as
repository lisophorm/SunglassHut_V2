package com.alfo.utils {
import flash.data.SQLConnection;
import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.errors.SQLError;
import flash.events.EventDispatcher;
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;
import flash.filesystem.File;
import flash.net.Responder;

public class SQLConnectionWrapper extends EventDispatcher {
    // TODO bubble error event to the navigator

    private static const SINGLETON_INSTANCE:SQLConnectionWrapper = new SQLConnectionWrapper(SingletonLock);

    public var connection:SQLConnection;

    public static var errorLog:String = "";
    public static var lastQuery:String = "";


    public static function get instance():SQLConnectionWrapper {
        return SINGLETON_INSTANCE;
    }

    public function SQLConnectionWrapper(lock:Class) {
        trace("SQLconnectionWrapper main class");
        // This ensures that only once instance of this class may be created and accessed
        if (lock != SingletonLock) {
            throw new Error("Class Cannot Be Instantiated: Use SQLConnectionWrapper.instance");
        }
        createDatabase();

    }


    private function createDatabase():void {
        trace("****** create database");
        // This creates an SQLConnection object , which can be accessed publicly so that event listeners can be defined for it
        connection = new SQLConnection();
        connection.addEventListener(SQLEvent.OPEN, onSqlOpen);
        dispatchEvent(new UploaderErrorEvent(UploaderErrorEvent.ERROR, "my message", "my bubble", true));

        var databaseFile:File = File.documentsDirectory.resolvePath("ddatabase.db");
        trace("database file:" + databaseFile.nativePath);
        connection.openAsync(databaseFile);
    }

    private function onSqlOpen(result:SQLEvent):void {
        trace("sql database open!");
        var stat:SQLStatement = new SQLStatement();
        stat.sqlConnection = connection;
        stat.text = "CREATE TABLE IF NOT EXISTS userdata (id INTEGER PRIMARY KEY AUTOINCREMENT, created DATETIME, modified DATETIME, local INTEGER DEFAULT 0, vars TEXT, status TEXT,url TEXT,filename TEXT,lastresult TEXT)";
        stat.execute(-1, new Responder(handleSuccess, handleFailure));
    }

    private function onSqlError(result:SQLErrorEvent) {

    }

    private function handleSuccess(result:SQLResult):void {
        trace("database created!");
    }

    private function handleFailure(error:SQLError):void {
        trace("Epic Fail on database creation: " + error.message);
        errorLog += new Date().toString();
        errorLog += " - " + error.message;
        errorLog += " - " + lastQuery;

    }

    public function totalRecords(tblName:String):SQLStatement {
        var totalRecordQuery:SQLStatement = new SQLStatement();
        totalRecordQuery.sqlConnection = connection;
        totalRecordQuery.text = "SELECT count(*) as totalrows,status,local from " + tblName + " group by status,local";
        return totalRecordQuery;
    }

    public function updateRecord(status:String, lastresult:String, id:String):SQLStatement {

    var updateRecordQuery:SQLStatement = new SQLStatement();
    updateRecordQuery.sqlConnection = connection;
    updateRecordQuery.text = "UPDATE userdata SET modified=datetime(),status=:status,lastresult=:lastresult WHERE id=:id";
    updateRecordQuery.parameters[":status"] = status;
    updateRecordQuery.parameters[":lastresult"] = lastresult;
    updateRecordQuery.parameters[":id"] = id;
    return updateRecordQuery;
}

    public function requeueError(status:String, lastresult:String, id:String):SQLStatement {

        var updateRecordQuery:SQLStatement = new SQLStatement();
        updateRecordQuery.sqlConnection = connection;
        updateRecordQuery.text = "UPDATE userdata SET modified=datetime(),status='QUEUED' WHERE status!='Succsess'";
        return updateRecordQuery;
    }

    public function requeueAll(status:String, lastresult:String, id:String):SQLStatement {

        var updateRecordQuery:SQLStatement = new SQLStatement();
        updateRecordQuery.sqlConnection = connection;
        updateRecordQuery.text = "UPDATE userdata SET modified=datetime(),status='QUEUED'";
        return updateRecordQuery;
    }

    public function insertRecord(vars:String, url:String, filename:String,isLocal:Boolean=false):SQLStatement {
        var locale:String=isLocal?"1":"0";
        var insertRecordQuery:SQLStatement = new SQLStatement();
        insertRecordQuery.sqlConnection = connection;
        insertRecordQuery.text = "INSERT INTO userdata (vars,status,url,filename,local,created,modified) VALUES (:vars,:status,:url,:filename,:local,datetime(),datetime())";


        insertRecordQuery.parameters[":vars"] = vars;
        insertRecordQuery.parameters[":status"] = 'QUEUED';
        insertRecordQuery.parameters[":url"] = url;
        insertRecordQuery.parameters[":local"] = locale;
        insertRecordQuery.parameters[":filename"] = filename;
        return insertRecordQuery;
    }

    public function getNextRecord():SQLStatement {
        // If selectRecord has not been instantiated, then create the instance with all the data that it needs
        // If it has been instantiated, then we can skip over this part and take advantage of the fact that it has now been cached

        var selectRecord:SQLStatement = new SQLStatement();
        selectRecord.sqlConnection = connection;
        selectRecord.text =
                "SELECT * FROM userdata WHERE status='QUEUED' ORDER BY modified";

        // This simply changes the one parameter that needs to be changed
        // Because recordId has already been declared as an int, this will be converted into an SQLite recognized integer


        return selectRecord;
    }

    public function getAllRecords():SQLStatement {
        // If selectRecord has not been instantiated, then create the instance with all the data that it needs
        // If it has been instantiated, then we can skip over this part and take advantage of the fact that it has now been cached

        var getAllRecords:SQLStatement = new SQLStatement();
        getAllRecords.sqlConnection = connection;
        getAllRecords.text =
                "SELECT * FROM userdata ORDER BY modified";

        // This simply changes the one parameter that needs to be changed
        // Because recordId has already been declared as an int, this will be converted into an SQLite recognized integer


        return getAllRecords;
    }
}
}

class SingletonLock {
}