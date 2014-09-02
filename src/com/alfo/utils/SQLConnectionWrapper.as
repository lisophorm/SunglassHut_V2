package com.alfo.utils
{
import flash.data.SQLConnection;
import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.errors.SQLError;
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;
import flash.filesystem.File;
import flash.net.Responder;

public class SQLConnectionWrapper
{
    private static const SINGLETON_INSTANCE:SQLConnectionWrapper = new SQLConnectionWrapper(SingletonLock);

    public var connection:SQLConnection;

    private var selectRecord:SQLStatement;
    private var insertRecordQuery:SQLStatement;

    public static var errorLog:String="";
    public static var lastQuery:String="";


    public static function get instance():SQLConnectionWrapper
    {
        return SINGLETON_INSTANCE;
    }

    public function SQLConnectionWrapper(lock:Class)
    {
        // This ensures that only once instance of this class may be created and accessed
        if(lock != SingletonLock){
            throw new Error("Class Cannot Be Instantiated: Use SQLConnectionWrapper.instance");
        }

        createDatabase();
    }

    public function init():void {
        trace("HELLOOOWWW SQLLITE CLASS");
    }

    private function createDatabase():void
    {
        // This creates an SQLConnection object , which can be accessed publicly so that event listeners can be defined for it
        connection = new SQLConnection();
        connection.addEventListener( SQLEvent.OPEN, onSqlOpen );
        connection.addEventListener( SQLErrorEvent.ERROR, onSqlOpen );

        var databaseFile:File = File.applicationStorageDirectory.resolvePath("database.db");
        connection.openAsync(databaseFile);
    }

    private function onSqlOpen(result:SQLEvent):void {
        trace("sql database open!");
        var stat:SQLStatement = new SQLStatement();
        stat.sqlConnection = connection;
        stat.text = "CREATE TABLE IF NOT EXISTS userdata (id INTEGER PRIMARY KEY AUTOINCREMENT, created DATETIME, modified DATETIME, vars TEXT,bin BLOB)";
        stat.execute(-1, new Responder(handleSuccess,handleFailure));
    }

    private function handleSuccess(result:SQLResult):void
    {
        trace("database created!");
    }

    private function handleFailure(error:SQLError):void
    {
        trace("Epic Fail on database creation: " + error.message);
        errorLog+=new Date().toString();
        errorLog+=" - "+error.message;
        errorLog+=" - "+lastQuery;
    }

    public function insertRecord(vars:String):SQLStatement {
        if(!(insertRecordQuery is SQLStatement)) {
            insertRecordQuery = new SQLStatement();
            insertRecordQuery.sqlConnection = connection;
            insertRecordQuery.text= "INSERT INTO userdata (vars,created,modified) VALUES (:vars,datetime(),datetime())";

        }
        insertRecordQuery.parameters[":vars"]=vars;
        return insertRecordQuery;
    }

    public function getRecord(recordId:int):SQLStatement
    {
        // If selectRecord has not been instantiated, then create the instance with all the data that it needs
        // If it has been instantiated, then we can skip over this part and take advantage of the fact that it has now been cached
        if(!(selectRecord is SQLStatement)){
            selectRecord= new SQLStatement();
            selectRecord.sqlConnection = connection;
            selectRecord.text =
                    "SELECT record_id, description, is_active " +
                    "FROM record_tbl " +
                    "WHERE record_id = :recordId";
        }
        // This simply changes the one parameter that needs to be changed
        // Because recordId has already been declared as an int, this will be converted into an SQLite recognized integer
        selectRecord.parameters[":recordId"] = recordId;

        return selectRecord;
    }
}
}

class SingletonLock{}