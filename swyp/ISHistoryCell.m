//
//  ISHistoryCell.m
//  swyp
//
//  Created by Alexander List on 2/3/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "ISHistoryCell.h"
#import "NSDate+Relative.h"
#import <SSToolkit/SSLabel.h>

@implementation ISHistoryCell
@synthesize historyItem = _historyItem;
@synthesize dateLabel = _dateLabel;

- (id)initWithStyle:(SSCollectionViewItemStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {

		UIView	* backgroundView		=	[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
		[backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight];
		backgroundView.backgroundColor	=	[UIColor whiteColor];
		[backgroundView setAlpha:.7];
		self.backgroundView = backgroundView;
		
        
        self.detailTextLabel.frame = CGRectMake(0, self.height-20, self.width, 20);
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
		[self.detailTextLabel setTextAlignment:UITextAlignmentRight];
		[self.detailTextLabel setFont:[UIFont fontWithName:@"futura" size:12]];
		[self.detailTextLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [self bringSubviewToFront:self.detailTextLabel];
		
		[self.imageView setContentMode:UIViewContentModeScaleAspectFill];
		[self.imageView setClipsToBounds:TRUE];
				
		UILongPressGestureRecognizer * optionsPress	=	[[UILongPressGestureRecognizer alloc] initWithTarget:self 
                                                                                                    action:@selector(longPressForOptionsMenuOccured)];
		[optionsPress setMinimumPressDuration:.4];
		[self addGestureRecognizer:optionsPress];
		
	}
	return self;
}

- (void)setHistoryItem:(ISSwypHistoryItem *)historyItem {
	if (_historyItem != historyItem){
		_historyItem	=	historyItem;
		[self.detailTextLabel setText:[NSString stringWithFormat:@"%@ ago", 
                                 [[_historyItem dateAdded] distanceOfTimeInWordsToNow]]];
		[self updateCellContents];
	}
}

-(void)	updateCellContents{
	[self.imageView setImage:[UIImage imageWithData:[self.historyItem itemPreviewImage]]];
}


#pragma mark - export actions
-(void)swypPressed:(UIMenuController*)sender{
	[[self historyItem] displayInSwypWorkspace];
}

-(void)exportPressed:(UIMenuController*)sender{
	swypHistoryItemExportAction exportAction	=	[[[[self historyItem] localizedActionNamesByExportAction] keyForObject:[[[sender menuItems] lastObject] title]] intValue];
	
	if (exportAction > swypHistoryItemExportActionNone){
		[[self historyItem] performExportAction:exportAction withSendingViewController:nil];
	}
}

-(void)copyPressed:(UIMenuController*)sender{
	[[self historyItem] addToPasteboard];
}


#pragma mark - UIMenuController
-(void)longPressForOptionsMenuOccured{
	UIMenuController * selectionMenu = [UIMenuController sharedMenuController];
	[self setSelected:TRUE];
	[self becomeFirstResponder];
	
	
	UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:LocStr(@"Copy",@"MenuItem on history scroll view") 
                                                      action:@selector(copyPressed:)] ;
	UIMenuItem *swypItem = [[UIMenuItem alloc] initWithTitle:LocStr(@"Swÿp",@"MenuItem on history scroll view") 
                                                      action:@selector(swypPressed:)] ;

	UIMenuItem *exportItem =  nil;
	NSIndexSet * supportedActions = [[self historyItem] supportedExportActions];
	if ([supportedActions count] > 0){
		NSString * exportActionName		=	[[[self historyItem] localizedActionNamesByExportAction] objectForKey:[NSNumber numberWithInt:[supportedActions firstIndex]]];
		exportItem =  [[UIMenuItem alloc] initWithTitle:exportActionName action:@selector(exportPressed:)];
	}
	
	[selectionMenu setMenuItems:[NSArray arrayWithObjects:copyItem,swypItem,exportItem,nil]];
	[selectionMenu setArrowDirection:UIMenuControllerArrowDown];
	
	[selectionMenu setTargetRect:self.bounds inView:self];
	[selectionMenu setMenuVisible:TRUE animated:FALSE];
}


-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
	if (action == @selector(copyPressed:))
		return YES;
	if (action == @selector(swypPressed:))
		return YES;
	if (action == @selector(exportPressed:))
		return YES;
	return NO;
}

-(BOOL)canBecomeFirstResponder{
	return TRUE;
}

-(BOOL)becomeFirstResponder{
	[super becomeFirstResponder];
	return TRUE;
}


-(BOOL)resignFirstResponder{
	[super resignFirstResponder];
	[self setSelected:FALSE animated:TRUE];
	return TRUE;
}



@end
