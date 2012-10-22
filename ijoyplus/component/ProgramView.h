//
//  ProgramView.h
//  ijoyplus
//
//  Created by joyplus1 on 12-10-22.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgramView : UIView<UIWebViewDelegate>
- (id)initWithUrl:(NSString *)url;
@end
