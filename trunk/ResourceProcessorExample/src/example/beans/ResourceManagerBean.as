package example.beans {
	
	import mx.resources.ResourceManager;
	
	import org.swizframework.core.Bean;
	import org.swizframework.reflection.TypeCache;

	/**
	 * ResourceManagerBean is a quick and dirty way to expose the ResourceManager
	 * singleton as a Bean.
	 * as a Bean.
	 */
	public class ResourceManagerBean extends Bean {
		
		public function ResourceManagerBean() {
			super(ResourceManager.getInstance(), 
					"resourceManager", 
					TypeCache.getTypeDescriptor(ResourceManager.getInstance()), 
					null);
		}
		
	}
}