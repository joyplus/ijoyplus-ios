//
//  FilmReviewDetailView.h
//  yueshipin
//
//  Created by 08 on 13-3-29.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilmReviewDetailView : UIView
{
    UILabel         *_labTitle;
    UITextView      *_viewContent;
    
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSString *)content;

@end
