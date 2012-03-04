//
//  ISUnifiedSwypSpace.h
//  swyp
//
//  Created by Alexander List on 3/4/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISSwypHistoryItem.h"
#import "ISPasteboardVC.h"
#import "ISCalendarVC.h"
#import "ISContactVC.h"
#import "ISHistoryScrollVC.h"

@interface ISUnifiedSwypSpace : UIViewController <swypConnectionSessionDataDelegate, swypContentDataSourceProtocol, UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
	
	UIButton *						_photoButton;
	UIButton *						_contactButton;
	UIButton *						_calendarButton;
	UIButton *						_historyButton;
	UIView *						_buttonTray;
	
}
@property (nonatomic, assign) id<swypContentDataSourceDelegate>	datasourceDelegate;
@property (nonatomic, strong) NSManagedObjectContext *			objectContext;
@property (nonatomic, strong) swypWorkspaceViewController *		swypWorkspace;
@property (nonatomic, strong) swypWorkspaceView *				workspaceView;
@property (nonatomic, strong) NSMutableDictionary *				contentThumbnailForPendingFilesBySession;

@property (nonatomic, strong) ISContactVC *					contactVC;
@property (nonatomic, strong) ISCalendarVC *				calendarVC;
@property (nonatomic, strong) UIImagePickerController *		imageVC;
@property (nonatomic, strong) UIImagePickerController *		cameraVC;
@property (nonatomic, strong) UIPopoverController *			displayPopoper;

@property (nonatomic, strong) ISHistoryScrollVC *			historyVC;

-(id) initWithObjectContext:(NSManagedObjectContext*)context swypWorkspace:(swypWorkspaceViewController*)workspace;


///convinience encapsulating popovers and vcs
-(void) displayVC:(UIViewController*)vc fromRect:(CGRect)rect fromVC:(UIViewController*)displayController;
@end
