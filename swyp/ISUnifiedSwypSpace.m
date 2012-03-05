//
//  ISUnifiedSwypSpace.m
//  swyp
//
//  Created by Alexander List on 3/4/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "ISUnifiedSwypSpace.h"

@implementation ISUnifiedSwypSpace
@synthesize datasourceDelegate = _datasourceDelegate, objectContext = _objectContext, contentThumbnailForPendingFilesBySession, swypWorkspace = _swypWorkspace, workspaceView = _workspaceView;
@synthesize   contactVC = _contactVC, calendarVC = _calendarVC, imageVC = _imageVC, cameraVC = _cameraVC;
@synthesize displayPopoper = _displayPopoper;
@synthesize historyVC = _historyVC;



-(id) initWithObjectContext:(NSManagedObjectContext*)context swypWorkspace:(swypWorkspaceViewController*)workspace{
	if (self  = [super initWithNibName:nil bundle:nil]){
		self.contentThumbnailForPendingFilesBySession	=	[NSMutableDictionary new];
		
		_objectContext	=	context;
		_swypWorkspace	=	workspace;
		[_swypWorkspace addDataDelegate:self];
	}
	return self;
}

-(void) viewWillUnload{
	[_swypWorkspace removeEmbeddableSwypWorkspaceView:_workspaceView];
}

-(void) dealloc{
	[_swypWorkspace removeDataDelegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	if (deviceIsPhone_ish){
		return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	}else{
		return TRUE;
	}
}

-(void) viewDidLoad{
	[super viewDidLoad];
	
	
	_buttonTray			=	[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, ((deviceIsPad)?200:100))];
	_buttonTray.origin	= CGPointMake(0, self.view.height - _buttonTray.size.height);
	[_buttonTray setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
	[_buttonTray setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"historyBGTile"]]];
	
	double	buttonHeight	=	65;
	_photoButton	=	[UIButton buttonWithType:UIButtonTypeRoundedRect];
	[_photoButton setFrame:CGRectMake(0, 0, round(_buttonTray.width / 3), buttonHeight)];
	[_photoButton setTitle:LocStr(@"Photos",@"photos workspace button") forState:UIControlStateNormal];
	[_photoButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleRightMargin];
	[_photoButton addTarget:self action:@selector(pressedPhotoButton:) forControlEvents:UIControlEventTouchUpInside];
	[_buttonTray addSubview:_photoButton];

	_calendarButton	=	[UIButton buttonWithType:UIButtonTypeRoundedRect];
	[_calendarButton setFrame:CGRectMake(round(_buttonTray.width / 3), 0, round(_buttonTray.width / 3), buttonHeight)];
	[_calendarButton setTitle:LocStr(@"Calendar",@"Calendar workspace button") forState:UIControlStateNormal];
	[_calendarButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
	[_calendarButton addTarget:self action:@selector(pressedCalendarButton:) forControlEvents:UIControlEventTouchUpInside];
	[_buttonTray addSubview:_calendarButton];

	_contactButton	=	[UIButton buttonWithType:UIButtonTypeRoundedRect];
	[_contactButton setFrame:CGRectMake(2*round(_buttonTray.width / 3), 0, round(_buttonTray.width / 3), buttonHeight)];
	[_contactButton setTitle:LocStr(@"Contact",@"Contact workspace button") forState:UIControlStateNormal];
	[_contactButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin];
	[_contactButton addTarget:self action:@selector(pressedContactButton:) forControlEvents:UIControlEventTouchUpInside];
	[_buttonTray addSubview:_contactButton];
	
	
	double	heightOffset	=	buttonHeight;
	_historyButton	=	[UIButton buttonWithType:UIButtonTypeRoundedRect];
	[_historyButton setFrame:CGRectMake(0, heightOffset, self.view.width, _buttonTray.size.height - heightOffset)];
	[_historyButton setTitle:LocStr(@"Received Stuff",@"received items workspace button") forState:UIControlStateNormal];
	[_historyButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[_historyButton addTarget:self action:@selector(pressedHistoryButton:) forControlEvents:UIControlEventTouchUpInside];
	[_buttonTray addSubview:_historyButton];
	
	[self.view addSubview:_buttonTray];
	
	_workspaceView	=	[_swypWorkspace embeddableSwypWorkspaceViewForWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - _buttonTray.height)];
	UIView * workspacePromptImageView	=	[_workspaceView swypPromptImageView];
	CGPoint center	=	[workspacePromptImageView center];
	if (deviceIsPhone_ish){
		workspacePromptImageView.transform = CGAffineTransformScale([workspacePromptImageView transform], .7, .7);
		[workspacePromptImageView setCenter:center];
	}
	[self.view addSubview:_workspaceView];
	
}

#pragma mark button response
-(void) pressedPhotoButton:(UIButton*)sender{
	if (_imageVC == nil){
		self.imageVC			=	[[UIImagePickerController alloc] init];
		_imageVC.allowsEditing	=	NO;
		[_imageVC setDelegate:self];
	}
	
	CGRect dispRect		= [sender convertRect:sender.frame toView:self.view];
	dispRect.origin.x	=	sender.origin.x;
	[self displayVC:self.imageVC fromRect:dispRect fromVC:self];

	//gotta call this after display
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
		[[[_imageVC navigationBar] topItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(pressedCameraButton:)]];
	}
}

-(void) pressedCameraButton:(UIBarButtonItem*)sender{
	if (_cameraVC == nil){
		self.cameraVC			=	[[UIImagePickerController alloc] init];
		_cameraVC.allowsEditing	=	NO;
		[_cameraVC setSourceType:UIImagePickerControllerSourceTypeCamera];
		[_cameraVC setShowsCameraControls:TRUE];
		[_cameraVC setDelegate:self];
	}
	
	CGRect dispRect		= [_photoButton convertRect:_photoButton.frame toView:self.view];
	dispRect.origin.x	= _photoButton.origin.x;
	[self displayVC:self.cameraVC fromRect:dispRect fromVC:self];
}

-(void) pressedContactButton:(UIButton*) sender{
	if (_contactVC == nil){
		self.contactVC =	[[ISContactVC alloc] init];
	}
	
	CGRect dispRect		= [sender convertRect:sender.frame toView:self.view];
	dispRect.origin.x	=	sender.origin.x;
	[self displayVC:self.contactVC fromRect:dispRect fromVC:self];
	
}
-(void) pressedCalendarButton:(UIButton*) sender{
	if (_calendarVC == nil){
		self.calendarVC =	[[ISCalendarVC alloc] init];
	}
	
	CGRect dispRect		= [sender convertRect:sender.frame toView:self.view];
	dispRect.origin.x	=	sender.origin.x;
	[self displayVC:self.calendarVC fromRect:dispRect fromVC:self];
}
-(void) pressedHistoryButton:(UIButton*)sender{
	if (_historyVC == nil){
		self.historyVC = [[ISHistoryScrollVC alloc] initWithObjectContext:self.objectContext swypWorkspace:self.swypWorkspace];
	}
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.historyVC];
	[self displayVC:navController fromRect:[sender convertRect:sender.frame toView:self.view] fromVC:self];
}

#pragma mark specialty viewC
-(void) displayVC:(UIViewController*)vc fromRect:(CGRect)rect fromVC:(UIViewController*)displayController{
		
	if (deviceIsPad){
		if (_displayPopoper == nil){
			_displayPopoper = [[UIPopoverController alloc] initWithContentViewController:vc];
		}
		
		[_displayPopoper setContentViewController:vc];
		[_displayPopoper presentPopoverFromRect:rect inView:displayController.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:FALSE];
	}else{
		[displayController presentModalViewController:vc animated:TRUE];
	}
}

#pragma mark swypContentDataSourceProtocol
#pragma mark - delegation
- (NSArray*)	idsForAllContent{
	return nil;
}
- (UIImage *)	iconImageForContentWithID: (NSString*)contentID ofMaxSize:(CGSize)maxIconSize{	
	return nil;
	
}
- (NSArray*)		supportedFileTypesForContentWithID: (NSString*)contentID{
	return nil;
}

- (NSData*)	dataForContentWithID: (NSString*)contentID fileType:	(swypFileTypeString*)type{
	NSData *	sendPhotoData	=	nil;	
	return sendPhotoData;
}

-(void)	setDatasourceDelegate:			(id<swypContentDataSourceDelegate>)delegate{
	_datasourceDelegate	=	delegate;
}
-(id<swypContentDataSourceDelegate>)	datasourceDelegate{
	return _datasourceDelegate;
}

-(void)	contentWithIDWasDraggedOffWorkspace:(NSString*)contentID{
	
	EXOLog(@"Dragged content off! %@",contentID);
	[_datasourceDelegate datasourceRemovedContentWithID:contentID withDatasource:self];
}

#pragma mark swypConnectionSessionDataDelegate
-(NSArray*)supportedFileTypesForReceipt{
	//everything supported, plus the thumbnail type as a hack
	return [NSArray arrayWithObjects:[NSString swypCalendarEventsFileType], [NSString swypAddressFileType],[NSString swypContactFileType], [NSString textPlainFileType],[NSString imagePNGFileType],[NSString imageJPEGFileType],[NSString swypWorkspaceThumbnailFileType], nil];
}

-(void)	yieldedData:(NSData*)streamData ofType:(NSString *)streamType fromDiscernedStream:(swypDiscernedInputStream *)discernedStream inConnectionSession:(swypConnectionSession *)session{
	EXOLog(@" datasource received data of type: %@",[discernedStream streamType]);
	
	if ([streamType isFileType:[NSString swypWorkspaceThumbnailFileType]]){
		[self.contentThumbnailForPendingFilesBySession setObject:streamData forKey:[NSValue valueWithNonretainedObject:session]];
		return;
	}
	
	ISSwypHistoryItem* item	=	[NSEntityDescription insertNewObjectForEntityForName:@"SwypHistoryItem" inManagedObjectContext:[self objectContext]];
	NSData * thumbnail	=	[self.contentThumbnailForPendingFilesBySession objectForKey:[NSValue valueWithNonretainedObject:session]];
	if ([thumbnail length] > 0){
		[item setItemPreviewImage:thumbnail];
	}
	[self.contentThumbnailForPendingFilesBySession removeObjectForKey:[NSValue valueWithNonretainedObject:session]];
	
	[item setItemType:[discernedStream streamType]];
	[item setItemData:streamData];
	
	NSError * error = nil;
	if (![[self objectContext] save:&error]){
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	} 
		
}

#pragma mark - Delegation 
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	UIImage * selectedImage	=	[info valueForKey:UIImagePickerControllerOriginalImage];
	
	if (_displayPopoper){
		[_displayPopoper dismissPopoverAnimated:TRUE];
	}else{
		[self dismissModalViewControllerAnimated:TRUE];
	}
	
	NSMutableDictionary *workingDictionary = [NSMutableDictionary dictionary];
	[workingDictionary setObject:@"kUTTypeImage" forKey:@"UIImagePickerControllerMediaType"];
	[workingDictionary setObject:selectedImage forKey:@"UIImagePickerControllerOriginalImage"];
	
		
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	if (_displayPopoper){
		[_displayPopoper dismissPopoverAnimated:TRUE];
	}else{
		[self dismissModalViewControllerAnimated:TRUE];
	}
}


@end
