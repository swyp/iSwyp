//
//  ISCalendarVC.m
//  swyp
//
//  Created by Ethan Sherbondy on 2/3/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "ISCalendarVC.h"
#import <QuartzCore/QuartzCore.h>
#import "ISCalendarDayRenderVC.h"
#import "ISCalendarEventRenderVC.h"
#import "MAEvent.h"

static double iPadCalendarHeight	=	408;

@implementation ISCalendarVC
@synthesize calendarDataSource = _calendarDataSource, kalVC = _kalVC;
@synthesize swypPendingEvents = _swypPendingEvents;
@synthesize exportingCalImage;

+(UITabBarItem*)tabBarItem{
	return [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Calendar", @"Your calendar events on the tab bar.") image:[UIImage imageNamed:@"calendar"] tag:1];
}

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.swypPendingEvents	= [NSMutableArray new];
        self.tabBarItem			= [[self class] tabBarItem];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
	
	
	_calendarDataSource			=	[ISEventKitDataSource dataSource];
	
	_kalVC	=	[[KalViewController alloc] initWithSelectedDate:[NSDate date]];
	[_kalVC setDataSource:_calendarDataSource];
	[_kalVC setDelegate:self];
	
	CGSize	calSize	=	(deviceIsPad)?CGSizeMake(self.view.width, iPadCalendarHeight):self.view.bounds.size;
	CGRect calFrame	=	CGRectZero;
	if(deviceIsPad){
		calFrame	= CGRectMake(0, self.view.height - calSize.height, calSize.width, calSize.height);
		[_kalVC.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
	}else{
		calFrame = CGRectMake(0, 0, calSize.width, calSize.height);
		[_kalVC.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
	}

	[_kalVC.view setFrame:calFrame];
///	[_kalVC.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[self.view addSubview:_kalVC.view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
		
	[[self kalVC] didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - ISRenderVCDelegate
-(void) didRenderImage:(UIImage*)image thumbnail:(UIImage*)renderThumbnailImage forRenderObject:(id)renderObject renderVC:(ISRenderVC*)vc{
	self.exportingCalImage	=	renderThumbnailImage;
	
//	if ([renderObject isKindOfClass:[EKEvent class]]){
//		
//	}
	
	[[swypWorkspaceViewController sharedSwypWorkspace] setContentDataSource:self];
	[[self datasourceDelegate] datasourceSignificantlyModifiedContent:self];
	[[swypWorkspaceViewController sharedSwypWorkspace] presentContentWorkspaceAtopViewController:[[[UIApplication sharedApplication] keyWindow] rootViewController]];
}

#pragma mark - CalendarView Delegate
-(void)rePressedOnDay:(NSDate *)date withView:(UIView *)dayTile withController:(KalViewController *)controller{
	
	[[self swypPendingEvents] removeAllObjects];
	for (MAEvent * mEvent in [controller dayView:controller.dayView eventsForDate:date]){
		EKEvent * eEvent = [[mEvent userInfo] valueForKey:@"EKEvent"];
		
		if (eEvent){
			[[self swypPendingEvents] addObject:eEvent];
		}
	}
	
	[ISCalendarDayRenderVC beginRenderWithObject:[controller dayView:controller.dayView eventsForDate:date] retainedDelegate:self];
}

-(void)tappedOnEvent:(EKEvent *)event withController:(KalViewController *)controller{
	
	[[self swypPendingEvents] removeAllObjects];
	if (event){
		[[self swypPendingEvents] addObject:event];
	}

	[ISCalendarEventRenderVC beginRenderWithObject:event retainedDelegate:self];
}

#pragma mark public
-(NSDictionary*) exportDictionaryForEvents:(NSArray*)exportEvents{
	NSMutableDictionary * exportDict	=	[NSMutableDictionary dictionary];
	NSMutableArray	* eventArray		=	[NSMutableArray array];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	for (EKEvent * nextEvent in exportEvents){
		NSMutableDictionary * particularDictionary	=	[NSMutableDictionary dictionary];
		
		[particularDictionary setValue:[dateFormatter stringFromDate:nextEvent.startDate] forKey:@"startDate"];
		[particularDictionary setValue:[dateFormatter stringFromDate:nextEvent.endDate] forKey:@"endDate"];
		[particularDictionary setValue:nextEvent.title forKey:@"title"];
		[particularDictionary setValue:[NSNumber numberWithBool:nextEvent.isAllDay] forKey:@"isAllDay"];
		[particularDictionary setValue:[[UIColor colorWithCGColor:nextEvent.calendar.CGColor] swypEncodedColorStringValue] forKey:@"backgroundColor"];
		
		[eventArray addObject:particularDictionary];
	}
	[exportDict setValue:eventArray forKey:@"events"];
	
	return exportDict;
}

#pragma mark <swypContentDataSourceProtocol, swypConnectionSessionDataDelegate>
- (NSArray*)	idsForAllContent{
	return [NSArray arrayWithObject:@"PREVIEW_DISPLAYED_CAL_ITEM"];
}
- (UIImage *)	iconImageForContentWithID: (NSString*)contentID ofMaxSize:(CGSize)maxIconSize{	
	UIImage * returnImage	=	self.exportingCalImage;
	if (returnImage == nil){
		returnImage	=	[UIImage imageNamed:@"swypPromptHud.png"];
	}
	return returnImage;
}

- (NSArray*)		supportedFileTypesForContentWithID: (NSString*)contentID{
	return [NSArray arrayWithObjects:[NSString swypCalendarEventsFileType], [NSString imageJPEGFileType],[NSString imagePNGFileType], nil];
}

- (NSData*)	dataForContentWithID: (NSString*)contentID fileType:	(swypFileTypeString*)type{
	NSData *	sendData	=	nil;	
	
	if ([type isFileType:[NSString swypCalendarEventsFileType]]){
		NSDictionary * sendEventsDictionary	=	[self exportDictionaryForEvents:[self swypPendingEvents]];
		NSString *jsonString				=	[sendEventsDictionary jsonStringValue];
		sendData	=	[jsonString dataUsingEncoding:NSUTF8StringEncoding];
	}else if ([type isFileType:[NSString imagePNGFileType]]){
		sendData	=	UIImagePNGRepresentation(self.exportingCalImage);
	}else if ([type isFileType:[NSString imageJPEGFileType]]){
		sendData	=	 UIImageJPEGRepresentation(self.exportingCalImage,.8);
	}else{
		EXOLog(@"No data coverage for content type %@ of ID %@",type,contentID);
	}
	
	
	return sendData;
}


@end
