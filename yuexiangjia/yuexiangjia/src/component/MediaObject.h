//
//  MediaObject.h
//  ijoyplus
//
//  Created by joyplus1 on 12-11-8.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MEDIA_WIDTH  70
#define MEDIA_HEIGHT 70
#define MEDIA_GAP 8


@interface MediaObject : NSObject

@property (nonatomic, strong)NSString *mediaType;
@property (nonatomic, strong)NSString *mediaURL;
@property (nonatomic, strong)UIImage *image;
@property (nonatomic, strong)UIImage *creationDate;
@property (nonatomic, assign)double duration;

@end
