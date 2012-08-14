#import "BundleItemMenuItem.h"
#import <OakFoundation/NSString Additions.h>
#import <ns/ns.h>

@interface BundleItemMenuItem ()
- (BundleItemMenuItem*)initWithName:(std::string const&)name
                      keyEquivalent:(std::string const&)keyEquiv
                         tabTrigger:(std::string const&)tabTrigger
                             action:(SEL)action
                      alignmentData:(BundleItemMenuItemAlignment&)alignment;
- (void)setAttributedTitleWithTitle:(NSAttributedString*)itemTitle equivLeft:(NSAttributedString*)equivLeft equivRight:(NSAttributedString*)equivRight alignmentData:(BundleItemMenuItemAlignment&)alignment;
@end

@implementation BundleItemMenuItem
+ (BundleItemMenuItem*)menuItemWithName:(std::string const&)name
                          keyEquivalent:(std::string const&)keyEquiv
                             tabTrigger:(std::string const&)tabTrigger
                                 action:(SEL)action
                          alignmentData:(BundleItemMenuItemAlignment&)alignment
{
	return [[[self alloc] initWithName:name
                        keyEquivalent:keyEquiv
                           tabTrigger:tabTrigger
                               action:action
                        alignmentData:alignment] autorelease];
}


- (BundleItemMenuItem*)initWithName:(std::string const&)name
                      keyEquivalent:(std::string const&)keyEquiv
                         tabTrigger:(std::string const&)tabTrigger
                             action:(SEL)action
                      alignmentData:(BundleItemMenuItemAlignment&)alignment
{
	if ((self = [super init]))
	{
		[self setAction:action];
		
		NSDictionary* fontAttrs = @{ NSFontAttributeName : [NSFont menuFontOfSize:14] /* passing 0 should return the default size, but it doesn’t */ };
		NSDictionary* smallFontAttrs = @{ NSFontAttributeName : [NSFont menuFontOfSize:11] };
		NSAttributedString* title = [[NSAttributedString alloc] initWithString:[NSString stringWithCxxString:name] attributes:fontAttrs];
		NSAttributedString* equivLeft = nil;
		NSAttributedString* equivRight = nil;
	
		if(tabTrigger != NULL_STR)
		{
			equivLeft = [[[NSAttributedString alloc] initWithString:[NSString stringWithCxxString:(" "+tabTrigger+"\u21E5 ")] attributes:smallFontAttrs] autorelease];
		}
		else if(keyEquiv != NULL_STR)
		{
			size_t keyStart = 0;
			std::string const glyphStr(ns::glyphs_for_event_string(keyEquiv, &keyStart));
		
			equivLeft = [[[NSAttributedString alloc] initWithString:[NSString stringWithCxxString:glyphStr.substr(0, keyStart)] attributes:fontAttrs] autorelease];
			equivRight = [[[NSAttributedString alloc] initWithString:[NSString stringWithCxxString:glyphStr.substr(keyStart)] attributes:fontAttrs] autorelease];
		}
	
		[self setAttributedTitleWithTitle:title equivLeft:equivLeft equivRight:equivRight alignmentData:alignment];
	}
	
	return self;
}

- (void)setAttributedTitleWithTitle:(NSAttributedString*)itemTitle equivLeft:(NSAttributedString*)equivLeft equivRight:(NSAttributedString*)equivRight alignmentData:(BundleItemMenuItemAlignment&)alignment
{
	NSMutableAttributedString* title = [[[NSMutableAttributedString alloc] initWithAttributedString:itemTitle] autorelease];
	[title beginEditing];
	
	CGFloat alignmentWidth = [itemTitle size].width;
	CGFloat rightWidth = [equivRight size].width;
	CGFloat leftWidth = [equivLeft size].width;
	
	if(equivLeft)
	{
		[title appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\t"] autorelease]];
		[title appendAttributedString:equivLeft];
		
		alignmentWidth += leftWidth + 20;
		
		if(equivRight)
		{
			[title appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\t"] autorelease]];
			[title appendAttributedString:equivRight];
			hasRightPart = YES;
		}
	}
	
	if(alignmentWidth > alignment.maxAlignmentWidth)
		alignment.maxAlignmentWidth = alignmentWidth;
	
	if(rightWidth > alignment.maxRightWidth)
		alignment.maxRightWidth = rightWidth;

	[title endEditing];
	[self setAttributedTitle:title];
}

- (void)updateAlignment:(BundleItemMenuItemAlignment&)alignment
{
	NSMutableParagraphStyle* pStyle = [[NSMutableParagraphStyle new] autorelease];
	if(hasRightPart)
	{
		[pStyle setTabStops:@[
			[[[NSTextTab alloc] initWithType:NSRightTabStopType location:alignment.maxAlignmentWidth] autorelease],
			[[[NSTextTab alloc] initWithType:NSLeftTabStopType location:alignment.maxAlignmentWidth + 0.01] autorelease]
		]];
	}
	else
	{
		[pStyle setTabStops:@[
			[[[NSTextTab alloc] initWithType:NSRightTabStopType location:alignment.maxAlignmentWidth + alignment.maxRightWidth] autorelease]
		]];
	}
	
	NSMutableAttributedString* title = [[[self attributedTitle] mutableCopy] autorelease];
	[title addAttribute:NSParagraphStyleAttributeName value:pStyle range:NSMakeRange(0, [title length])];
	
	[self setAttributedTitle:title];
}
@end
