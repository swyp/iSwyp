//
//  ISCalendarVC.h
//  swyp
//
//  Created by Ethan Sherbondy on 2/3/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Kal.h>
#import "ISTabVC.h"
#import "ISEventKitDataSource.h"
#import "ISRenderVC.h"

@interface ISCalendarVC : ISTabVC <KalViewControllerDelegate, ISRenderVCDelegate>
@property (nonatomic, strong) ISEventKitDataSource *	calendarDataSource;
@property (nonatomic, strong) KalViewController *		kalVC;

@property (nonatomic, strong) NSMutableArray *	swypPendingEvents;
@property (nonatomic, strong) UIImage*					exportingCalImage;


-(NSDictionary*) exportDictionaryForEvents:(NSArray*)exportEvents;

@end
