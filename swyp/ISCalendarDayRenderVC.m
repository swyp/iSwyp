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
@synthesize renderDayMAEvents = renderObject;

+(id) beginRenderWithObject:(NSObject*)renderObject retainedDelegate:(NSObject<ISRenderVCDelegate>*)delegate{
	ISCalendarDayRenderVC * renderer	=	[[ISCalendarDayRenderVC alloc] init];
	[renderer setDelegate:delegate];
	[renderer setRenderObject:renderObject];
	[renderer startRendering];
	
	return renderer;
}

-(void) viewDidLoad{
	[super viewDidLoad];
	
	MADayView * dayView	=	[[MADayView alloc] initWithFrame:CGRectMake(0, 0, 200, 1200)];
	[dayView setDataSource:self];
	self.view	=	dayView;
}


#pragma mark -
#pragma mark MADayViewDataSource
- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)date{
	
	return self.renderDayMAEvents;

}
@end
