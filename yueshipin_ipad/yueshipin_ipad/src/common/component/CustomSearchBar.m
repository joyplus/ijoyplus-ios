//
//  CustomSearchBar.h
//  SmartBaby
//
//  Created by zhipeng zhang on 12-5-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomSearchBar.h"
#import "CMConstants.h"

@interface CustomSearchBar (){
    UIButton *cancelButton;
}

@end
@implementation CustomSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsCancelButton = YES;
        [self setTranslucent:YES];
    }
    return self;
}

- (void)layoutSubviews {
//    UITextField *searchField;
    for(id subview in self.subviews) {
        if([subview isKindOfClass:[UITextField class]]) { 
//            searchField = subview;
        } else if([subview isKindOfClass:[UIButton class]]){
            cancelButton = (UIButton *)subview;
            
            [cancelButton setHidden:YES];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setBackgroundImage:[UIImage imageNamed:@"search_btn_pressed"] forState:UIControlStateHighlighted];
            [btn setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
            btn.frame = CGRectMake(312, 1, 57, 38);
            [btn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
    }
    for (UIView *subview in self.subviews)
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [subview removeFromSuperview];
            break;
        }
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_box_text"]];
    [self insertSubview:imageView atIndex:1];
    //3自定义背景
    [super layoutSubviews];
}

- (void)cancelBtnClicked
{
    [cancelButton sendActionsForControlEvents:UIControlEventTouchUpInside];
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
