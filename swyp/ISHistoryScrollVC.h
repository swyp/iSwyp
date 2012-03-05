//
//  ISHistoryScrollView.h
//  swyp
//
//  Created by Alexander List on 2/3/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISSwypHistoryItem.h"
#import "swypWorkspaceView.h"
#import "ISPreviewVC.h"
#import <SSToolkit/SSCollectionViewController.h>

///The view that shows a swyp workspace drop-zone in the header, and the history of all swyp-received content below
@interface ISHistoryScrollVC : UIViewController <SSCollectionViewDelegate, SSCollectionViewDataSource, 
                                                           NSFetchedResultsControllerDelegate,swypConnectionSessionDataDelegate> {
	NSManagedObjectContext *		_objectContext;
	swypWorkspaceViewController *	_swypWorkspace;
    NSArray *                     _dataModel;
    SSCollectionView *            _collectionView;
}

@property (nonatomic, strong) swypWorkspaceView *               swypDropZoneView;
@property (nonatomic, strong) NSFetchedResultsController*		resultsController;
@property (nonatomic, assign) id<swypContentDataSourceDelegate>	datasourceDelegate;
@property (nonatomic, strong) NSManagedObjectContext *			objectContext;
@property (nonatomic, strong) ISPreviewVC *						previewVC;
@property (nonatomic, strong) NSMutableDictionary *				contentThumbnailForPendingFilesBySession;

- (id)initWithObjectContext:(NSManagedObjectContext*)context swypWorkspace:(swypWorkspaceViewController*)workspace;

//
//private
- (NSFetchRequest*)	_newOrUpdatedFetchRequest;
- (void)				_refreshDataModel;
@end
