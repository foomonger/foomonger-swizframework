package example.model {
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;

	public class OutputViewModel extends EventDispatcher {
		
		[Bindable]
		public var messages:ArrayCollection;
		
		public function OutputViewModel() {
			super();
			messages = new ArrayCollection();
		}
		
		[MediateSignal(type="ClickedSignal")]
		public function showMessage(message:String):void {
			messages.addItemAt(message, 0);
		}
		
	}
}