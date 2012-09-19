//
//  TestViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterflowView.h"
#import "MyWaterflowView.h"

@interface TestViewController : UIViewController< MyWaterflowViewDelegate,MyWaterflowViewDatasource,UIScrollViewDelegate>

@end
