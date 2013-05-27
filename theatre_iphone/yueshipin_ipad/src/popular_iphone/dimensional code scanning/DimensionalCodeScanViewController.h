//
//  DimensionalCodeScanViewController.h
//  yueshipin
//
//  Created by 08 on 13-4-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
@interface DimensionalCodeScanViewController : ZBarReaderViewController <ZBarReaderDelegate>
{
    
}

@property (nonatomic,strong) UIImageView *scanSymbolView;

@end
