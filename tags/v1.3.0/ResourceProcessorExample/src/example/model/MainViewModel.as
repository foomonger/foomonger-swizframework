package example.model {
	
	import example.enum.LocaleEnum;
	
	import flash.events.EventDispatcher;
	
	import mx.resources.IResourceManager;
	
	public class MainViewModel extends EventDispatcher {
		
		[Resource(key="title", bundle="example")]
		[Bindable]
		public var title:String;
		
		[Resource(key="background", bundle="example")]
		[Bindable]
		public var background:Class;
		
		// Note that we're only injecting IResourceManager so that we can change locales.
		[Inject]
		public var resourceManager:IResourceManager;
		
		public function MainViewModel () {
			super();
		}
		
		public function useEnUS():void {
			resourceManager.localeChain = [LocaleEnum.EN_US];
		}
		
		public function usePigLatin():void {
			resourceManager.localeChain = [LocaleEnum.PIG_LATIN];
		}
		
	}
}