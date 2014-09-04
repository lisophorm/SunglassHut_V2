package com.alfo
{
import flash.display.Sprite;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

public class UserObject extends Sprite
	{
		
		private var _photo1:String;
		private var _photo2:String;
		private var _photo3:String;

		private static var _instance:UserObject=null;
		//public var urn:String;
		
		
		public static var userDataObj:Object;
		
		public var batchPath:String="specsavers_jpg_xml/";
		
		public var spoolerPath:String="specsavers_print/"
			
		public var tempPath:String="specsavers_temp_jpg/";
		
		
		public function UserObject()
		{
			trace("inizializza userObject");
		}
		
		public function get photo2():String
		{
			return userDataObj.photo2;
		}

		public function set photo2(value:String):void
		{
			userDataObj.photo2 = value;
		}

		public function get photo1():String
		{
            return userDataObj.photo1;
		}
		
		public function get hometown():String {
			return userDataObj.hometown;
		}
		
		public function set hometown(town:String):void {
			userDataObj.hometown=town;
		}
		
		public function set extraterms(value:Boolean):void
		{
			if(value) {
				userDataObj.extraterms = "1";
			} else {
				userDataObj.extraterms = "0";
			}
			
		}
		
		public function get extraterms():Boolean
		{
			if(userDataObj.extraterms=="1") {
				return true;
			} else {
				return false;
			}
		}

		public function set photo1(value:String):void
		{
			userDataObj.photo1 = value;
		}

		public function get photo3():String
		{
			return userDataObj.photo3;
		}

		public function set photo3(value:String):void
		{
            userDataObj.photo3 = value;
		}

		public function get current_location():String
		{
			return userDataObj.current_location;
		}
		
		public function set location(value:String):void
		{
			userDataObj.location = value;
		}
		
		public function get location():String
		{
			return userDataObj.location;
		}
		
		public function set current_location(value:String):void
		{
			userDataObj.current_location = value;
		}
		
		
		public static function getInstance():UserObject {
			if(_instance==null) {
				trace("******* singleton first instance");
				_instance=new UserObject();
				_instance.init();
			} else {
				trace("**************old instance");
				trace(userDataObj.toString());
				trace("first name:"+userDataObj.firstname);
			}
			return _instance;
		}
		
		public function init():void {
			trace("***** init userobject");
			userDataObj =new Object();
			var now:Date= new Date();
			userDataObj.creationdate=convertASDateToMySQLTimestamp(now);
			userDataObj.isConnected="1";
			userDataObj.isBatch="0";
			userDataObj.photo1="";
			userDataObj.photo2="";
			userDataObj.photo3="";
			userDataObj.extraterms = "1";
			trace("new userobject");
			var workDirectory:File = File.documentsDirectory.resolvePath(batchPath);
			trace("directory url:"+workDirectory.url);
			if (!workDirectory.exists) {
				trace("directory does not exists");
				//try {
				workDirectory.createDirectory();
				//} catch (e:Error) {
				trace("Failed creating working directory!");
				//}
			} else {
				trace("work dir exists");
			}
		}
		
		public function eject():void {
			trace("XML:");
			trace(userDataObj.toXMLString());
		}
		
		public function set urn(theURN:String):void {
			userDataObj.uuid=theURN;
		}
		public function get urn():String {
			return userDataObj.uuid;
		}
		public function set token(thetoken:String):void {
			userDataObj.token=thetoken;
		}
		public function get token():String {
			return userDataObj.token;
		}
		public function set firstname(thefirstname:String):void {
			userDataObj.firstName=thefirstname;
		}
		public function get firstname():String {
			return userDataObj.firstName;
		}
		public function set lastname(thelastname:String):void {
			userDataObj.lastName=thelastname;
		}
		public function set mobile(themobile:String):void {
			userDataObj.postcode=themobile;
		}
		public function set email(theemail:String):void {
			userDataObj.emailAddress=theemail;
		}
		public function set fb_id(thefb_id:String):void {
			userDataObj.fb_id=thefb_id;
		}
		public function set data_saved(thedata_saved:Boolean):void {
			userDataObj.data_saved=thedata_saved?"1":"0";
		}
		public function set facebook(thefacebook:Boolean):void {
			userDataObj.facebook=thefacebook?"1":"0";
		}
		public function set hasphoto(thehasphoto:Boolean):void {
			userDataObj.hasphoto=thehasphoto?"1":"0";
		}
		public function set isConnected(theconnection:Boolean):void {
			userDataObj.isConnected=theconnection?"1":"0";
		}

		public function get isConnected():Boolean {
			if(userDataObj.isConnected=="1") {
				return true;
			} else {
				return false;
			}
            return false;
		}



		public function set destFileName(thedestFileName:String):void {
			userDataObj.destFileName=thedestFileName;
		}
		public function get destFileName():String {
			return userDataObj.destFileName;
		}

        public function get JSONobject():String {
            trace("current jsonobject:"+JSON.stringify(userDataObj));
            return JSON.stringify(userDataObj);
        }
		
		public function saveXML():String {
			var f:File = File.documentsDirectory.resolvePath(batchPath+userDataObj.urn+".xml");
			trace("save xml");
			trace("file:"+userDataObj.urn);
			trace("path:"+f.url);
			var message:String;
			var s:FileStream = new FileStream();
			try
			{
				s.open(f,FileMode.WRITE);
				s.writeUTFBytes(userDataObj.toXMLString());
				message="OK";
			} catch(e:Error) {
				trace("error saving xml"+e.message);
				message= (e.message as String);
			} finally {
				s.close();
			}
			trace("saveXML result:"+message);
			return message;
		}
		
		private function convertASDateToMySQLTimestamp( d:Date ):String {
                var s:String = d.fullYear + '-';
                s += prependZero( d.month + 1 ) + '-';
                s += prependZero( d.date ) + ' ';

                s += prependZero( d.hours ) + ':';
                s += prependZero( d.minutes ) + ':';
                s += prependZero( d.seconds );

                return s;
		}
		
		private function prependZero( n:Number ):String {
			var s:String = ( n < 10 ) ? '0' + n : n.toString();
			return s;
		}
		
	}
}