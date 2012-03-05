//
//  ISHistoryCell.h
//  swyp
//
//  Created by Alexander List on 2/3/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SSToolkit/SSCollectionViewItem.h>
#import "ISSwypHistoryItem.h"

@interface ISHistoryCell : SSCollectionViewItem

@property (nonatomic, strong) ISSwypHistoryItem	*	historyItem;
@property (nonatomic, retain) UILabel *				dateLabel;

- (void)updateCellContents;

@end
