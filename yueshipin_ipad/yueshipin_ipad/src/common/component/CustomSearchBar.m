//
//  CustomSearchBar.h
//  SmartBaby
//
//  Created by zhipeng zhang on 12-5-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomSearchBar.h"
#import "CMConstants.h"
#define SEARCH_BTN_TAG  (12321)
@interface CustomSearchBar (){
    UIButton *cancelButton;
}
@end
@implementation CustomSearchBar
@synthesize searchBtnImg,searchSelectedBtnImage;
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
    for(id subview in self.subviews) {
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
        {
            UIView * searchBtn = (UIView *)[self viewWithTag:SEARCH_BTN_TAG];
            [searchBtn removeFromSuperview];
            UIView * firstSubView = (UIView *)subview;
            for (UIView * secSubView in firstSubView.subviews)
            {
                if ([secSubView isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
                {
                    [secSubView removeFromSuperview];
                } else if([secSubView isKindOfClass:NSClassFromString(@"UISearchBarTextField")]){
                    UITextField *textField = (UITextField *)secSubView;
                    textField.backgroundColor = [UIColor clearColor];
                    textField.background = nil;
                } else if([secSubView isKindOfClass:[UIButton class]]){
                    cancelButton = (UIButton *)secSubView;
                    
                    [cancelButton setHidden:YES];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    if (!searchBtnImg)
                    {
                        searchBtnImg = @"search_btn";
                    }
                    if (!searchSelectedBtnImage)
                    {
                        searchSelectedBtnImage = @"search_btn_pressed";
                    }
                    [btn setBackgroundImage:[UIImage imageNamed:@"search_btn_pressed"] forState:UIControlStateHighlighted];
                    [btn setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
                    btn.frame = CGRectMake(self.frame.size.width - 68, -3, 68, 42);
                    [btn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
                    [self addSubview:btn];
                    btn.tag = SEARCH_BTN_TAG;
                }
            }
        }
        else
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subview removeFromSuperview];
            } else if([subview isKindOfClass:NSClassFromString(@"UISearchBarTextField")]){
                UITextField *textField = (UITextField *)subview;
                [textField setBackground:nil];
            } else if([subview isKindOfClass:[UIButton class]]){
                cancelButton = (UIButton *)subview;
                
                [cancelButton setHidden:YES];
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                if (!searchBtnImg)
                {
                    searchBtnImg = @"search_btn";
                }
                if (!searchSelectedBtnImage)
                {
                    searchSelectedBtnImage = @"search_btn_pressed";
                }
                [btn setBackgroundImage:[UIImage imageNamed:@"search_btn_pressed"] forState:UIControlStateHighlighted];
                [btn setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
                btn.frame = CGRectMake(self.frame.size.width - 68, -3, 68, 42);
                [btn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:btn];
            }
        }
        
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"search_box_text"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 10, 2, 10)]];
    imageView.frame = CGRectMake(0, 0, self.frame.size.width - 72, 40);
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
