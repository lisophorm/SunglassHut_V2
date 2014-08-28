package events
{
import flash.events.Event;

public class UploadResultEvent extends Event
	{
		
		public static var SUCCESS:String="upload_success";
		public static var ERROR:String="upload_error";
		
		public var message:String="";
		public var status:String="";
		
		public function UploadResultEvent(type:String, status:String="", message:String="",bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}