//
//  HomeViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterflowView.h"

@interface HomeViewController : UIViewController< WaterflowViewDelegate,WaterflowViewDatasource,UIScrollViewDelegate>{

}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

@end
