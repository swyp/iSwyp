//
//  ISHistoryScrollView.h
//  swyp
//
//  Created by Alexander List on 2/3/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusModels.h"

@interface ISHistoryScrollVC : UIViewController <UITableViewDelegate>{
	NSManagedObjectContext *		_objectContext;
	swypWorkspaceViewController *	_swypWorkspace;
	
	UITableView *					_swypHistoryTableView;
	
}
@property (nonatomic, strong) UIView *				swypDropZoneView;
@property (nonatomic, strong) NITableViewModel *	sectionedDataModel;

-(id) initWithObjectContext:(NSManagedObjectContext*)context swypWorkspace:(swypWorkspaceViewController*)workspace;

@end