package example.model {
	
	import example.enum.LocaleEnum;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceBundle;
	
	public class SomeOtherModel {

		[Inject]
		public var resourceManager:IResourceManager;
	
		// Embedding locally for simplicity. You can embed Class resources at compile time.
		[Embed(source="assets/en_US/background.png")]
		private var background_enUS:Class;
		[Embed(source="assets/pigLatin/background.png")]
		private var background_pigLatin:Class;
	
		public function SomeOtherModel() {
		}
		
		[PostConstruct]
		public function init():void {
			// Adding bundles at runtime. 
			// You could also do this by loading static XML or with services.
			var bundleEnUS:ResourceBundle = new ResourceBundle(LocaleEnum.EN_US, "example");
			bundleEnUS.content["title"] = "Hello World!";
			bundleEnUS.content["subtitle"] = "Here's Johnny!";
			bundleEnUS.content["background"] = background_enUS;
			resourceManager.addResourceBundle(bundleEnUS);

			var bundlePigLatin:ResourceBundle = new ResourceBundle(LocaleEnum.PIG_LATIN, "example");
			bundlePigLatin.content["title"] = "Ellohay Orldway!";
			bundlePigLatin.content["subtitle"] = "Ere'shay Ohnnyjay!";
			bundlePigLatin.content["background"] = background_pigLatin;
			resourceManager.addResourceBundle(bundlePigLatin);
			
			// Call update() to trigger binding changes.
			resourceManager.update();
		}

	}
}