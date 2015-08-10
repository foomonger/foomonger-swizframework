Example [SWF](http://www.foomonger.com/swizframework/ResourceProcessorExample/ResourceProcessorExample.swf) and [Source](http://www.foomonger.com/swizframework/ResourceProcessorExample/srcview/).

ResourceProcessor binds a resource from the ResourceManager singleton to the decorated property. It uses the IResource.getObject() method when binding so you can decorate properties of types supported by ResourceManager.

Usage:

  1. If using the source directly, add `Resource` to the list of metadata tags to keep when compiling. The `Resource` tag is included in the SWC as of v1.2.0.
  1. Add ResourceProcessor to the Swiz instance
  1. Decorate methods with `[Resource]`. You must define `key` and `bundle` properties. E.g.
> > `[Resource(key="title", bundle="main")]`


> This intentionally mirrors the `@Resource` directive.