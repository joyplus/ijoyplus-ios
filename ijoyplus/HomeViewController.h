//
//  HomeViewController
//  ijoyplus
//
//  Created by joyplus1 on 12-9-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterflowView.h"
#import "UIGenericViewController.h"

@interface HomeViewController : UIGenericViewController< WaterflowViewDelegate,WaterflowViewDatasource,UIScrollViewDelegate, UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate >
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *roundImageView;
@property (weak, nonatomic) IBOutlet UILabel *watchedNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *watchBtn;
@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;
@property (weak, nonatomic) IBOutlet UILabel *username;
- (IBAction)followUser:(id)sender;
- (IBAction)fansUser:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *watchedLabel;
@property (weak, nonatomic) IBOutlet UIButton *avatarImageViewBtn;
@property (weak, nonatomic) IBOutlet UILabel *fansLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;
- (void)bgImageClicked:(id)sender;
- (IBAction)avatarImageClicked:(id)sender;
@property (strong, nonatomic)NSString *userid;
@property (assign, nonatomic)int offsety;
@end
