//
//  DDProgressView.h
//  DDProgressView
//
//  Created by Damien DeVille on 3/13/11.
//  Copyright 2011 Snappy Code. All rights reserved.
//


#import <UIKit/UIKit.h>
@interface DDProgressView : UIView
{
@private
	float progress ;
	UIColor *innerColor ;
	UIColor *outerColor ;
    UIColor *emptyColor ;
}

@property (nonatomic,strong) UIColor *innerColor ;
@property (nonatomic,strong) UIColor *outerColor ;
@property (nonatomic,strong) UIColor *emptyColor ;
@property (nonatomic,assign) float progress ;

@end
