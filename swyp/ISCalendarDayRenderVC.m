//
//  ISCalendarDayRenderVC.m
//  swyp
//
//  Created by Alexander List on 2/20/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "ISCalendarDayRenderVC.h"
#import <EventKit/EventKit.h>
#import "MAEvent.h"

@implementation ISCalendarDayRenderVC
@synthesize renderObject;

+(id) beginRenderWithObject:(NSArray*)renderMAEvents retainedDelegate:(NSObject<ISRenderVCDelegate>*)delegate{
	ISCalendarDayRenderVC * renderer	=	[[ISCalendarDayRenderVC alloc] init];
	[renderer setDelegate:delegate];
	[renderer setRenderObject:renderMAEvents];
	[renderer startRendering];
	
	return renderer;
}

-(void) viewDidLoad{
	[super viewDidLoad];
	
	MADayView * dayView	=	[[MADayView alloc] initWithFrame:CGRectMake(0, 0, 300, 1000)];
	[dayView setDataSource:self];
	self.view	=	dayView;
}


#pragma mark -
#pragma mark MADayViewDataSource
- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)date{
	
	return self.renderObject;

}
@end
