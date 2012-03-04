//
//  ISUnifiedSwypSpace.h
//  swyp
//
//  Created by Alexander List on 3/4/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISSwypHistoryItem.h"


@interface ISUnifiedSwypSpace : UIViewController <swypConnectionSessionDataDelegate, swypContentDataSourceProtocol>{
	
	NSManagedObjectContext *		_objectContext;
	swypWorkspaceViewController *	_swypWorkspace;
	
	UIButton *						_photoButton;
	UIButton *						_contactButton;
	UIButton *						_calendarButton;
	UIButton *						_historyButton;
	UIView *						_buttonTray;
	
}
@property (nonatomic, assign) id<swypContentDataSourceDelegate>	datasourceDelegate;
@property (nonatomic, strong) NSManagedObjectContext *			objectContext;
@property (nonatomic, strong) swypWorkspaceView *				workspaceView;
@property (nonatomic, strong) NSMutableDictionary *				contentThumbnailForPendingFilesBySession;


-(id) initWithObjectContext:(NSManagedObjectContext*)context swypWorkspace:(swypWorkspaceViewController*)workspace;

@end
