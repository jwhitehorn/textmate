#import "Document.h"
#import <oak/CocoaSTL.h>
#import <oak/oak.h>
#import <oak/debug.h>
#import <Find/Find.h>
#import <io/path.h>
#import <OakFoundation/OakFoundation.h>
#import <OakFoundation/NSString Additions.h>
#import <BundleEditor/BundleEditor.h>
#import <OakAppKit/OakAppKit.h>
#import <OakAppKit/OakPasteboard.h>
#import <OakFilterList/OakFilterList.h>
#import <OakFilterList/BundleItemChooser.h>
#import <OakTextView/OakDocumentView.h>
#import <Preferences/Preferences.h>
#import <text/types.h>
#import <document/collection.h>
#import <ns/ns.h>

@implementation Document

+ (void) showBrowser:(NSString *)path{
   NSString *source = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:@"Default.tm_properties"];     
   NSString *destination = [NSString stringWithFormat:@"%@/.tm_properties", path];  
         
   if ( [[NSFileManager defaultManager] isReadableFileAtPath:source] && ![[NSFileManager defaultManager] isReadableFileAtPath:destination])
       [[NSFileManager defaultManager] copyItemAtPath:source toPath:destination error:nil];

	document::show_browser(to_s(path));
}

@end