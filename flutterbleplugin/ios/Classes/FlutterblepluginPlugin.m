#import "FlutterblepluginPlugin.h"
#if __has_include(<flutterbleplugin/flutterbleplugin-Swift.h>)
#import <flutterbleplugin/flutterbleplugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutterbleplugin-Swift.h"
#endif

@implementation FlutterblepluginPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterblepluginPlugin registerWithRegistrar:registrar];
}
@end
