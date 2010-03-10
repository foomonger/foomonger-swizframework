package example.model {
	
	import example.signals.ClickedSignal;

	public class InputViewModel {
		
		[Inject]
		public var clicked:ClickedSignal;
		
		public function InputViewModel() {
			super();
		}
		
		public function click(message:String):void {
			clicked.dispatch(message);
		}
		
	}
}