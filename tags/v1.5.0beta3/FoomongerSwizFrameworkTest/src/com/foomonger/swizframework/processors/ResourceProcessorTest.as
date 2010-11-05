package com.foomonger.swizframework.processors {
	
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.utils.describeType;
	
	import flexunit.framework.TestCase;
	
	import mx.resources.IResourceBundle;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceBundle;
	import mx.resources.ResourceManager;
	
	import org.swizframework.core.Bean;
	import org.swizframework.core.BeanProvider;
	import org.swizframework.core.IBeanProvider;
	import org.swizframework.core.ISwiz;
	import org.swizframework.core.Swiz;
	import org.swizframework.core.SwizConfig;
	import org.swizframework.factories.MetadataHostFactory;
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.MetadataArg;
	import org.swizframework.reflection.TypeDescriptor;
	import org.swizframework.utils.logging.MockSwizLogger;
	
	public class ResourceProcessorTest extends TestCase {
		
		private static const HOST_NAME:String = "title";
		private static const KEY:String = "title";
		private static const BUNDLE:String = "test";
		private static const EN_US:String = "en_US";
		private static const PIG_LATIN:String = "pigLatin";
		private static const HELLO_WORLD_EN_US:String = "Hello World!";
		private static const HELLO_WORLD_PIG_LATIN:String = "Ellohay Orldway!";
		
		private var swiz:ISwiz;
		private var processor:ResourceProcessor;
		private var beanProvider:IBeanProvider;
		private var decoratedBean:Bean;
		private var decoratedBeanSource:Object;
		private var propertyHostNode:XML;
		private var resourceManager:IResourceManager;
		private var resourceBundle:IResourceBundle;
		private var resourceBundle2:IResourceBundle;
		
		public function ResourceProcessorTest(methodName:String=null) {
			super(methodName);
			resourceManager = ResourceManager.getInstance();
			resourceBundle = new ResourceBundle(EN_US, BUNDLE);
			resourceBundle.content[KEY] = HELLO_WORLD_EN_US;
			resourceBundle2 = new ResourceBundle(PIG_LATIN, BUNDLE);
			resourceBundle2.content[KEY] = HELLO_WORLD_PIG_LATIN;
			propertyHostNode = <variable name={HOST_NAME} type="String"/>;

		}
		
		override public function setUp():void {
			resourceManager.addResourceBundle(resourceBundle);
			resourceManager.addResourceBundle(resourceBundle2);
			decoratedBeanSource = new Object();
			decoratedBean = new Bean(decoratedBeanSource, "beanSource", new TypeDescriptor().fromXML(describeType(decoratedBeanSource), ApplicationDomain.currentDomain));
			beanProvider = new BeanProvider();
			beanProvider.addBean(decoratedBean);
			processor = new ResourceProcessor();
			swiz = new Swiz(new EventDispatcher(), new SwizConfig(), null, [beanProvider], [processor]);			
			swiz.init();
			processor.init(swiz);
		}
		
		public function test_setUp_tearDown():void {
			var keyArg:MetadataArg = new MetadataArg("key", KEY);
			var bundleArg:MetadataArg = new MetadataArg("bundle", BUNDLE);
			var metadataTag:IMetadataTag = createMetadataTag([keyArg, bundleArg], propertyHostNode);
			// Null to start
			assertNull(decoratedBeanSource[HOST_NAME]);
			// Set up
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			// Set up should set the inital value
			assertEquals(HELLO_WORLD_EN_US, decoratedBeanSource[HOST_NAME]);
			// Change localeChain to trigger binding change
			resourceManager.localeChain = [PIG_LATIN];
			// Test binding update value
			assertEquals(HELLO_WORLD_PIG_LATIN, decoratedBeanSource[HOST_NAME]);
			// Tear down
			processor.tearDownMetadataTag(metadataTag, decoratedBean);
			// Value should be the same
			assertEquals(HELLO_WORLD_PIG_LATIN, decoratedBeanSource[HOST_NAME]);
			// Change localeChain to trigger binding change
			resourceManager.localeChain = [EN_US];
			// Value should not change because binding is removed
			assertEquals(HELLO_WORLD_PIG_LATIN, decoratedBeanSource[HOST_NAME]);
		}
		
		public function test_setUp_propertiesError():void {
			var metadataTag:IMetadataTag = createMetadataTag([], propertyHostNode);
			var logger:MockSwizLogger = new MockSwizLogger("mock");
			logger.mock.method("error").withAnyArgs.once;
			processor.logger = logger;
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			logger.mock.verify();
		}
				
		private function createMetadataTag(args:Array, hostNode:XML):IMetadataTag {
			var metadataTag:IMetadataTag = new BaseMetadataTag();
			metadataTag.args = args;
			metadataTag.host = MetadataHostFactory.getMetadataHost(hostNode, ApplicationDomain.currentDomain);
			return metadataTag;
		}
	}
}
