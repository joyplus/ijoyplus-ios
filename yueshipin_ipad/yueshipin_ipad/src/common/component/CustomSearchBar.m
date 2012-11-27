//
//  CustomSearchBar.h
//  SmartBaby
//
//  Created by zhipeng zhang on 12-5-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomSearchBar.h"
#import "CMConstants.h"

@implementation CustomSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsCancelButton = YES;
    }
    return self;
}

- (void)layoutSubviews {
//    UITextField *searchField;
    UIButton *cancelButton;
    for(id subview in self.subviews) {
        if([subview isKindOfClass:[UITextField class]]) { 
//            searchField = subview;
        } else if([subview isKindOfClass:[UIButton class]]){
            cancelButton = (UIButton *)subview;
            [cancelButton setTitle:@"" forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:[UIImage imageNamed:@"search_btn_pressed"] forState:UIControlStateHighlighted];
        }
    }
    for (UIView *subview in self.subviews)
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [subview removeFromSuperview];
//            break;
        }
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_box"]];
    [self insertSubview:imageView atIndex:1];
    //3自定义背景
    [super layoutSubviews];
}



//- (void)showSearchButtonInitially
//{
//    UIView * subview;
//    NSArray * subviews = [self subviews];
//    
//    for(subview in subviews){
//        if( [subview isKindOfClass:[UITextField class]] ){
//            NSLog(@"setEnablesReturnKeyAutomatically");
//            [((UITextField*)subview) setEnablesReturnKeyAutomatically:NO];
//            ((UITextField*)subview).delegate=self;
//            [((UITextField*)subview) setEnabled:TRUE];
//            ((UITextField*)subview).borderStyle = UITextBorderStyleNone;
//            break;
//        }
//    }
//}

@end
