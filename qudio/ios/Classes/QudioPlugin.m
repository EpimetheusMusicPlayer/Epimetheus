#import "QudioPlugin.h"
#import <qudio/qudio-Swift.h>

@implementation QudioPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftQudioPlugin registerWithRegistrar:registrar];
}
@end
