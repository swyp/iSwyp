//
//  ISHistoryScrollView.m
//  swyp
//
//  Created by Alexander List on 2/3/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "ISHistoryScrollVC.h"
#import "ISHistoryCell.h"

@implementation ISHistoryScrollVC
@synthesize resultsController = _resultsController, 
            objectContext = _objectContext, previewVC = _previewVC, datasourceDelegate = _datasourceDelegate,
            contentThumbnailForPendingFilesBySession = _contentThumbnailForPendingFilesBySession;

- (ISPreviewVC *)previewVC{
	if (_previewVC == nil){
		_previewVC = [[ISPreviewVC alloc] init];
	}
	return _previewVC;
}

- (NSFetchedResultsController *)resultsController{
	if (_resultsController == nil){
		NSFetchRequest *request = [self _newOrUpdatedFetchRequest];
		_resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                 managedObjectContext:_objectContext 
                                                                   sectionNameKeyPath:nil 
                                                                            cacheName:nil];
		[_resultsController setDelegate:self];
	}
	return _resultsController;
}

- (NSArray *) dataModel{
	if (_dataModel == nil){
		_dataModel = [[self resultsController] fetchedObjects];
	}
	return _dataModel;
}

#pragma mark - UIViewController
- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	
	[[swypWorkspaceViewController sharedSwypWorkspace] setContentDataSource:self];
}

- (id)initWithObjectContext:(NSManagedObjectContext*)context swypWorkspace:(swypWorkspaceViewController*)workspace{
	if (self  = [super initWithNibName:nil bundle:nil]){
		self.contentThumbnailForPendingFilesBySession	=	[NSMutableDictionary new];
		_objectContext	= context;
        _swypWorkspace = workspace;
		[_swypWorkspace addDataDelegate:self];
	}
	return self;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
	[_swypWorkspace removeDataDelegate:self];
}

- (void)viewDidLoad{
    [super viewDidLoad];
	
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"historyBGTile"]]];
	
    _collectionView = [[SSCollectionView alloc] initWithFrame:self.view.frame];
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
	[_collectionView setDelegate:self];	
    [_collectionView setDataSource:self];
    [self.view addSubview:_collectionView];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                target:self 
                                                                                action:@selector(_done:)];
    self.title = LocStr(@"Recently Received",nil);
    self.navigationItem.rightBarButtonItem = doneButton;
	
	NSError *error = nil;
	[[self resultsController] performFetch:&error];
	if (error != nil){
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSException exceptionWithName:[error domain] reason:[error description] userInfo:nil];
	}	
	[self _refreshDataModel];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	if (deviceIsPhone_ish){
		return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	}else{
		return TRUE;
	}
}

#pragma mark - private
-(NSFetchRequest*)	_newOrUpdatedFetchRequest{
	NSFetchRequest* request = nil;
	request = _resultsController.fetchRequest;
	
	if (request == nil){
		NSEntityDescription *requestEntity =	[NSEntityDescription entityForName:@"SwypHistoryItem" inManagedObjectContext:_objectContext];
		
		request = [[NSFetchRequest alloc] init];
		[request setEntity:requestEntity];
		[request setFetchLimit:20];
	}
	
	NSSortDescriptor *dateSortOrder = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:FALSE];
	[request setSortDescriptors:[NSArray arrayWithObjects:dateSortOrder, nil]];
	
	return request;
}

-(void)	_refreshDataModel{
    [_collectionView reloadData];
}

- (void)_done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - delegation

#pragma mark SSCollectionViewDelegate
- (CGSize)collectionView:(SSCollectionView *)aCollectionView itemSizeForSection:(NSUInteger)section{
	return CGSizeMake(100, 100);
}

- (void)collectionView:(SSCollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
	[aCollectionView deselectItemAtIndexPath:indexPath animated:TRUE];
	
	ISHistoryCell *cell = [aCollectionView itemForIndexPath:indexPath];
	[[self previewVC] setDisplayedHistoryItem:cell.historyItem];
	[[self navigationController] pushViewController:[self previewVC] animated:TRUE];
}

#pragma mark SSCollectionViewDatasource

- (NSUInteger)collectionView:(SSCollectionView *)aCollectionView numberOfItemsInSection:(NSUInteger)section {
    return [self dataModel].count;
}

- (SSCollectionViewItem *)collectionView:(SSCollectionView *)aCollectionView itemForIndexPath:(NSIndexPath *)indexPath {
    ISHistoryCell *cell = [aCollectionView dequeueReusableItemWithIdentifier:@"History Cell"];
    if (cell == nil){
        cell = [[ISHistoryCell alloc] initWithStyle:SSCollectionViewItemStyleImage reuseIdentifier:@"History Cell"];
        cell.historyItem = [[self dataModel] objectAtIndex:indexPath.row];
    }

    return cell;
}


#pragma mark NSFetchedResultsController
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
	[self _refreshDataModel];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
	
    if (type == NSFetchedResultsChangeInsert){
//		[_swypHistoryTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
}

#pragma mark swypConnectionSessionDataDelegate
-(NSArray*)supportedFileTypesForReceipt{
	//everything supported, plus the thumbnail type as a hack
	return [NSArray arrayWithObjects:[NSString swypCalendarEventsFileType], 
                                     [NSString swypAddressFileType],
                                     [NSString swypContactFileType], 
                                     [NSString textPlainFileType],
                                     [NSString imagePNGFileType],
                                     [NSString imageJPEGFileType],
                                     [NSString swypWorkspaceThumbnailFileType], nil];
}

-(void)	yieldedData:(NSData*)streamData ofType:(NSString *)streamType fromDiscernedStream:(swypDiscernedInputStream *)discernedStream inConnectionSession:(swypConnectionSession *)session{
	EXOLog(@" datasource received data of type: %@",[discernedStream streamType]);
	
	if ([streamType isFileType:[NSString swypWorkspaceThumbnailFileType]]){
		[self.contentThumbnailForPendingFilesBySession setObject:streamData forKey:[NSValue valueWithNonretainedObject:session]];
		return;
	}
	
	ISSwypHistoryItem* item =	[NSEntityDescription insertNewObjectForEntityForName:@"SwypHistoryItem" inManagedObjectContext:[self objectContext]];
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
	
	[_collectionView reloadData];
		
}

@end
