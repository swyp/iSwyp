//
//  ISContactCardVC.h
//  swyp
//
//  Created by Ethan Sherbondy on 2/14/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusModels.h"
#import "ISContactManager.h"

@interface ISContactCardVC : UIViewController <UITextFieldDelegate, 
UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    NITableViewModel*           _model;
    UITextField*                _activeField;
    UIImagePickerController*    _imagePickerController;
    BOOL                        _isEditing;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *faceButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) NSDictionary *contactInfo;

- (UIViewController *)_rootVC;
- (NSString *)	_documentsPathForFileName:(NSString *)name;
- (void)	_toggleEditing;
@end
