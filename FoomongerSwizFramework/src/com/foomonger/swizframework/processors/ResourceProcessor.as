/*
Copyright 2010 Samuel Ahn

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package com.foomonger.swizframework.processors {

	import flash.utils.Dictionary;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectProxy;
	
	import org.swizframework.core.Bean;
	import org.swizframework.processors.BaseMetadataProcessor;
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.MetadataArg;
	import org.swizframework.utils.logging.SwizLogger;

	/**
	 * ResourceProcessor binds a resource to the decorated property. Define a key
	 * and bundle just like the @Resource directive.
	 */ 
	public class ResourceProcessor extends BaseMetadataProcessor {

		protected static const RESOURCE:String = "Resource";
		
		internal var logger:SwizLogger = SwizLogger.getLogger(this);
		
		protected var resourceManager:IResourceManager = ResourceManager.getInstance();
		
		internal var sites:Dictionary;
		
		public function ResourceProcessor() {
			super([RESOURCE]);
			sites = new Dictionary(true);
		}
 
		override public function setUpMetadataTag(metadataTag:IMetadataTag, bean:Bean):void {
			// Get properties
			var bundleArg:MetadataArg = metadataTag.getArg("bundle");
			var keyArg:MetadataArg = metadataTag.getArg("key");
			var bundle:String = bundleArg ? bundleArg.value : "";
			var key:String = keyArg ? keyArg.value : "";
			if ((bundle.length == 0) || (key.length == 0)) {
				logger.error("[ResourceProcessor] bundle and key properties required for tag {0}", (metadataTag as BaseMetadataTag).asTag);
				return;
			} 
			// Create chain object.
			// Only using IResource.getObject(). It is not probable that a developer would create 
			// a custom IResource implementation whose getObject() method is not similar to ResourceManagerImpl.
			var chain:Object = {
				name:"getObject",
				getter: function(host:Object):* {
							var value:* = host.getObject(bundle, key);
							return value;
						}
			};
			
			// Bind property
			var watcher:ChangeWatcher;
			var site:Object;
			var prop:String;
			
			if (bean.source[metadataTag.host.name] is ObjectProxy) {
				site = bean.source[metadataTag.host.name];
				prop = key;
			} else {
				site = bean.source;
				prop = metadataTag.host.name;
			}
			
			watcher = BindingUtils.bindProperty(site, prop, resourceManager, chain);
			
			if (watcher) {
				// Save the watcher for unbinding
				addWatcher(site, prop, watcher);
			} else {
				logger.error("[ResourceProcessor] Unable to create binding for tag {0}", (metadataTag as BaseMetadataTag).asTag);
			}
		}
						
		override public function tearDownMetadataTag(metadataTag:IMetadataTag, bean:Bean):void {
			var watcher:ChangeWatcher;
			var site:Object;
			var prop:String;
			
			if (bean.source[metadataTag.host.name] is ObjectProxy) {
				site = bean.source[metadataTag.host.name];
				var keyArg:MetadataArg = metadataTag.getArg("key");
				var key:String = keyArg ? keyArg.value : "";
				prop = key;
			} else {
				site = bean.source;
				prop = metadataTag.host.name;
			}
			
			watcher = getWatcher(site, prop);
			if (watcher) {
				watcher.unwatch();
				removeWatcher(site, prop);
			}
		}
		
		protected function addWatcher(site:Object, prop:String, watcher:ChangeWatcher):void {
			if (sites[site] == null) {
				sites[site] = {};
			}
			var hosts:Object = sites[site] as Object;
			hosts[prop] = watcher;
		}
		
		protected function getWatcher(site:Object, prop:String):ChangeWatcher {
			var watcher:ChangeWatcher;
			var hosts:Object = sites[site] as Object;
			if (hosts) {
				watcher = hosts[prop] as ChangeWatcher;
			}
			return watcher;
		}
		
		protected function removeWatcher(source:*, hostName:String):void {
			var hosts:Object = sites[source] as Object;
			if (hosts == null) {
				return;
			}
			// Delete host name record
			hosts[hostName] = null;
			delete hosts[hostName];
			// Check if no more hosts for this source
			var count:int = 0;
			for (var o:Object in hosts) {
				if (count++ > 0) {
					break;
				}
			}
			// If no more then delete source record
			if (count == 0) {
				sites[source] = null;
				delete sites[source];
			}
		}
	}
}