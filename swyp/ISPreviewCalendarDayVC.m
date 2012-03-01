//
//  ISPreviewCalendarDayVC.m
//  swyp
//
//  Created by Alexander List on 2/26/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "ISPreviewCalendarDayVC.h"

@implementation ISPreviewCalendarDayVC
@synthesize dayView, displayedEvents,localStore;

-(void) viewDidLoad{
	[super viewDidLoad];
	
	dayView		=	[[MADayView alloc] init];
	[dayView setDataSource:self];
	[dayView setDelegate:self];
	[dayView setAutoScrollToFirstEvent:TRUE];
	self.view	=	dayView;
}

-(id)	loadContentFromHistoryItem:		(ISSwypHistoryItem*)item{
	NSDictionary * dataDictionary	=	[item itemDataDictionaryRep];
	NSArray * eventsToAdd			=	[dataDictionary objectForKey:@"events"];
	
	NSMutableArray * maEvents	=	[NSMutableArray arrayWithCapacity:[eventsToAdd count]];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	for (NSDictionary * event in eventsToAdd){
		MAEvent *nextMAEvent = [[MAEvent alloc] init];
		nextMAEvent.backgroundColor = [UIColor colorWithSwypEncodedColorString:[event objectForKey:@"backgroundColor"]];
		nextMAEvent.textColor = [UIColor whiteColor];
		nextMAEvent.allDay	=	[[event objectForKey:@"isAllDay"] boolValue];
		nextMAEvent.start	=	[dateFormatter dateFromString:[event objectForKey:@"startDate"]];
		nextMAEvent.end		=	[dateFormatter dateFromString:[event objectForKey:@"endDate"]];
		nextMAEvent.title	=	[event objectForKey:@"title"];
		[maEvents addObject:nextMAEvent];
		
		nextMAEvent	=	nil;
	}
	
	self.displayedEvents	=	maEvents;
	[dayView reloadData];
	
	return self;
}


#pragma mark MADayView protocols 
- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)date{	
	return self.displayedEvents;
}
- (void)dayView:(MADayView *)dayView eventTapped:(MAEvent *)event{
	
	EKEventEditViewController * eventViewVC	=	[[EKEventEditViewController alloc] init];
	[eventViewVC.view setSize:CGSizeMake(320, 480)];
	[eventViewVC setEditViewDelegate:self];
	
	if (localStore ==nil){
		localStore		=	[[EKEventStore alloc] init];
	}
	[eventViewVC setEventStore:localStore];
	EKEvent * newEvent	=	[EKEvent eventWithEventStore:localStore];
	[newEvent setTitle:[event title]];
	[newEvent setStartDate:[event start]];
	[newEvent setEndDate:[event end]];
	[eventViewVC setEvent:newEvent];
	
	if (deviceIsPad){
		[eventViewVC setModalPresentationStyle:UIModalPresentationFormSheet];
	}
	
	[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentModalViewController:eventViewVC animated:TRUE];
}


#pragma mark EKEventEditViewDelegate
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action{

	[controller dismissModalViewControllerAnimated:TRUE];
}

@end
