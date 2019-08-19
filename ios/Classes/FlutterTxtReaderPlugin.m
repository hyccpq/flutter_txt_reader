#import "FlutterTxtReaderPlugin.h"
#import <flutter_txt_reader/flutter_txt_reader-Swift.h>

@implementation FlutterTxtReaderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterTxtReaderPlugin registerWithRegistrar:registrar];
}
@end
