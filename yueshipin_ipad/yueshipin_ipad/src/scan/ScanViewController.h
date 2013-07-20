//
//  ScanViewController.h
//  yueshipin
//
//  Created by lily on 13-7-10.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#define ZBarReader  @"ZBarReader"
@interface ScanViewController : ZBarReaderViewController <ZBarReaderDelegate>
@property (nonatomic,strong) UIImageView *scanSymbolView;
@end
