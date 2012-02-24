//
//  ISContactView.h
//  swyp
//
//  Created by Ethan Sherbondy on 2/14/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusModels.h"

@interface ISContactCardVC : UIViewController <UITextFieldDelegate, 
UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate> {
    NITableViewModel*   _model;
    UITextField*        _activeField;
    BOOL                _isEditing;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *faceButton;
@property (nonatomic, strong) UIButton *editButton;

- (UIViewController *)_rootVC;

@end
