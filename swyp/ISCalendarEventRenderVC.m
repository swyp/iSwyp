//
//  ISCalendarEventRenderVC.m
//  swyp
//
//  Created by Alexander List on 2/22/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "ISCalendarEventRenderVC.h"
#import <EventKitUI/EventKitUI.h>
#import <QuartzCore/QuartzCore.h>

@implementation ISCalendarEventRenderVC
@synthesize renderObject;
+(id) beginRenderWithObject:(EKEvent*)renderEKEvent retainedDelegate:(NSObject<ISRenderVCDelegate>*)delegate{
	ISCalendarEventRenderVC * renderer	=	[[ISCalendarEventRenderVC alloc] init];
	[renderer setDelegate:delegate];
	[renderer setRenderObject:renderEKEvent];
	[renderer startRendering];
	
	return renderer;
}

-(void) startRendering{
	if(!self.view) {
		[self didFinalizeRenderWithImage:nil thumbnail:nil];
		return;//loading view
	}
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .3 * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
		CGSize newViewSize		=	self.view.size; //loading view
		
		UITableView * eventTV	=	nil;
		if ([[self.view subviews] count] > 0){
			UITableView* testReadyTV	=	([[[self.view subviews] objectAtIndex:0] isKindOfClass:[UITableView class]])? [[self.view subviews] objectAtIndex:0]: nil;
			if (testReadyTV && [testReadyTV numberOfSections] > 0 && [testReadyTV numberOfRowsInSection:0] > 0){
				eventTV = testReadyTV;
			}
		}
		if (eventTV == nil){
			EXOLog(@"Event table not ready w. tv subviews; waiting.. %@",[[self.view subviews] description]);
			dispatch_async(dispatch_get_main_queue(), ^{
				[self startRendering];
			});
			return;
		}
		
		newViewSize				=	[eventTV contentSize];
		UIGraphicsBeginImageContextWithOptions(newViewSize,YES, 0);
		[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *image		= UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		UIImage * thumbnail	= [self constrainImage:image toSize:CGSizeMake(300, 300)];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self didFinalizeRenderWithImage:image thumbnail:thumbnail];
		});
	});
}

-(void)viewDidLoad{
	[super viewDidLoad];
	
	EKEventViewController * eventViewVC	=	[[EKEventViewController alloc] init];
	[eventViewVC.view setSize:CGSizeMake(320, 480)];
	[eventViewVC setEvent:[self renderObject]];
	
	self.view	=	eventViewVC.view;
}

@end
