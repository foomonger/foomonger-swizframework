LoggerProcessor injects a SwizLogger instance to the decorated property using the Bean source as the SwizLogger target. It's processor priority is 1 above the `[Inject]` priority so the logger instance will be availble at `[Inject]` and `[PostConstruct]`.

Usage:

  1. If using the source directly, add `Logger` to the list of metadata tags to keep when compiling. The `Logger` tag is included in the SWC as of v1.3.0.
  1. Add LoggerProcessor to the Swiz instance
  1. Decorate properties of type SwizLogger with `[Logger]`. E.g.
> > `[Logger]`
> > `public var logger:SwizLogger;`