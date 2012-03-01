//
//  ISPreviewCalendarDayVC.h
//  swyp
//
//  Created by Alexander List on 2/26/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISSwypHistoryItem.h"
#import "MADayView.h"
#import "MAEvent.h"
#import <EventKitUI/EventKitUI.h>

@interface ISPreviewCalendarDayVC : UIViewController <MADayViewDelegate, MADayViewDataSource, EKEventEditViewDelegate>

@property (nonatomic, strong) NSMutableArray *	displayedEvents;
@property (nonatomic, strong) MADayView *		dayView;
@property (nonatomic, strong) EKEventStore *	localStore;

-(id)	loadContentFromHistoryItem:		(ISSwypHistoryItem*)item;

@end
