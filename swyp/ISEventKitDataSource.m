/*
 * Copyright (c) 2010 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "ISEventKitDataSource.h"
#import <EventKit/EventKit.h>

static BOOL IsDateBetweenInclusive(NSDate *date, NSDate *begin, NSDate *end)
{
  return [date compare:begin] != NSOrderedAscending && [date compare:end] != NSOrderedDescending;
}

@interface ISEventKitDataSource ()
- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate;
- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate;
@end

@implementation ISEventKitDataSource
@synthesize dateOfLastModifiedEvent, didAutodisplayLastModifiedAlready;

+ (ISEventKitDataSource *)dataSource
{
  return [[[self class] alloc] init];
}

- (id)init
{
  if ((self = [super init])) {
    eventStore = [[EKEventStore alloc] init];
    events = [[NSMutableArray alloc] init];
    items = [[NSMutableArray alloc] init];
    eventStoreQueue = dispatch_queue_create("com.highfyve.calendarqueue", NULL);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChanged:) name:EKEventStoreChangedNotification object:nil];
  }
  return self;
}

- (void)eventStoreChanged:(NSNotification *)note
{
  [[NSNotificationCenter defaultCenter] postNotificationName:KalDataSourceChangedNotification object:nil];
}

- (EKEvent *)eventAtIndexPath:(NSIndexPath *)indexPath
{
  return [items objectAtIndex:indexPath.row];
}

#pragma mark UITableViewDataSource protocol conformance

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *identifier = @"MyCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
  }

  EKEvent *event = [self eventAtIndexPath:indexPath];
  cell.textLabel.text = event.title;
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [items count];
}

#pragma mark KalDataSource protocol conformance

- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{	
  // asynchronous callback on the main thread
  [events removeAllObjects];
  dispatch_async(eventStoreQueue, ^{
		NSDate *fetchProfilerStart = [NSDate date];
		NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:fromDate endDate:toDate calendars:nil];
		NSArray *matchedEvents = [eventStore eventsMatchingPredicate:predicate];
		NSArray *dateOrderedEvents		=	[matchedEvents sortedArrayUsingComparator:^NSComparisonResult(EKEvent* obj1, EKEvent* obj2) {
			return [[obj1 lastModifiedDate] compare:[obj2 lastModifiedDate]];
		}];
	  
	  
	  if (abs([[[dateOrderedEvents lastObject] lastModifiedDate] timeIntervalSinceNow]) < 5*60){ //displays the most recent app run one time
		  if ([dateOfLastModifiedEvent isEqualToDate:[[dateOrderedEvents lastObject] startDate]] == NO){
			  dateOfLastModifiedEvent			=	[[dateOrderedEvents lastObject] startDate];
			  didAutodisplayLastModifiedAlready	=	NO;
		  }
	  }else{
		  dateOfLastModifiedEvent	=	nil;
	  }
	  
		dispatch_async(dispatch_get_main_queue(), ^{
		EXOLog(@"Fetched %d events in %f seconds w/ last date %@", [matchedEvents count], -1.f * [fetchProfilerStart timeIntervalSinceNow], [[dateOrderedEvents lastObject] description]);
		[events addObjectsFromArray:matchedEvents];
		[delegate loadedDataSource:self];

    });
  });
}

- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
  // synchronous callback on the main thread
  return [[self eventsFrom:fromDate to:toDate] valueForKeyPath:@"startDate"];
}

- (void)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
  // synchronous callback on the main thread
  [items addObjectsFromArray:[self eventsFrom:fromDate to:toDate]];
}

- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
	NSMutableArray *matches = [NSMutableArray array];
	for (EKEvent *event in events)
		if (IsDateBetweenInclusive(event.startDate, fromDate, toDate))
			[matches addObject:event];
	
	return matches;
}

- (void)removeAllItems
{
  // synchronous callback on the main thread
  [items removeAllObjects];
}

#pragma mark -

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:EKEventStoreChangedNotification object:nil];
  dispatch_release(eventStoreQueue);
}

@end
