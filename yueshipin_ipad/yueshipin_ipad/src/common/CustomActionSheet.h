//
//  CustomActionSheet.h
//  yueshipin
//
//  Created by lily on 13-7-18.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomActionSheetDelegate <NSObject>
-(void)CustomActionSheetDelegateDidSelectAtIndex:(int)index;
@end

@interface CustomActionSheet : UIView{

   __weak id <CustomActionSheetDelegate> delegate_;
}
@property (nonatomic, weak) id <CustomActionSheetDelegate> delegate;
-(void)initCustomActionSheet;
-(void)actionSheetShow;
-(void)actionSheetHidde;
@end

