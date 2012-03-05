//
//  ISHistoryScrollView.m
//  swyp
//
//  Created by Alexander List on 2/3/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "ISHistoryScrollVC.h"
#import "ISDoodleRecognizingGestureRecognizer.h"
#include <QuartzCore/QuartzCore.h>


@implementation ISHistoryScrollVC
@synthesize sectionedDataModel = _sectionedDataModel, resultsController = _resultsController, 
            objectContext = _objectContext, previewVC = _previewVC, datasourceDelegate = _datasourceDelegate,
            contentThumbnailForPendingFilesBySession = _contentThumbnailForPendingFilesBySession;

- (ISPreviewVC *)previewVC{
	if (_previewVC == nil){
		_previewVC	=	[[ISPreviewVC alloc] init];
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

- (NITableViewModel *) sectionedDataModel{
	if (_sectionedDataModel == nil){
		NSMutableArray	* sectionArray	=	[[NSMutableArray alloc] init];
		NSArray	* historyItems			= [[self resultsController] fetchedObjects];
		[sectionArray addObjectsFromArray:historyItems];
		_sectionedDataModel	=	[[NITableViewModel alloc] initWithSectionedArray:sectionArray delegate:(id)[NICellFactory class]];
	}
	return _sectionedDataModel;
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
	
	[self.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"historyBGTile"]]];
	
	_swypHistoryTableView	= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
	[_swypHistoryTableView setBackgroundColor:[UIColor clearColor]];
	[_swypHistoryTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	[_swypHistoryTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[_swypHistoryTableView setDelegate:self];
	
	[_swypHistoryTableView setTableHeaderView:[self swypDropZoneView]]; 
	[self.view addSubview:_swypHistoryTableView];
    
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
	_sectionedDataModel = nil;
	[_swypHistoryTableView setDataSource:[self sectionedDataModel]];
}

- (void)_done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - delegation

#pragma mark UITableViewDelegate
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	CGFloat height	=	0;
	
	id object  =  [(NITableViewModel*)[tableView dataSource] objectAtIndexPath:indexPath];
	id class	=	[object cellClass];
	if ([class respondsToSelector:@selector(heightForObject:atIndexPath:tableView:)]){
		height	=	[class heightForObject:object atIndexPath:indexPath tableView:tableView];
	}
	return height;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
	
	ISSwypHistoryItem* object  =  [(NITableViewModel*)[tableView dataSource] objectAtIndexPath:indexPath];
	[[self previewVC] setDisplayedHistoryItem:object];
	[[self navigationController] pushViewController:[self previewVC] animated:TRUE];
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
	
	[self _refreshDataModel];
	[_swypHistoryTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
		
}

@end
