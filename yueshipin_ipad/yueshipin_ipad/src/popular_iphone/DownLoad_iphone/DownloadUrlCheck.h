//
//  DownloadUrlCheck.h
//  yueshipin
//
//  Created by 08 on 13-3-15.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DownloadUrlCheckDelegate <NSObject>

@end
@interface DownloadUrlCheck : NSObject{

    NSArray *infoArr_;
}
@property (nonatomic, strong) NSArray *infoArr;
@property (nonatomic, weak) id<DownloadUrlCheckDelegate>downloadUrlCheckdelegate;
-(void)checkDownloadUrl;
@end
