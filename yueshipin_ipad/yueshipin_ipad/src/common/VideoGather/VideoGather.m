//
//  VideoGather.m
//  yueshipin
//
//  Created by lily on 13-7-17.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "VideoGather.h"
#import "RegexKitLite.h"
static VideoGather *videoGather = nil;
#define VID_ASYNC "VID_ASYNC"
@implementation VideoGather
+(VideoGather *)Create{
    if (videoGather == nil) {
        return [[VideoGather alloc] init];
    }
    return nil;
}
-(NSArray *)getLetvUrls:(NSString *)htmlUrl{
//    dispatch_async(dispatch_queue_create(VID_ASYNC, NULL), ^{
//     NSString *vid = [VideoGather getVid:htmlUrl];
//    
//    });
    NSString *vid = [VideoGather getVid:htmlUrl];
    NSString *xmlUrl = [NSString stringWithFormat:@"http://www.letv.com/v_xml/%@.xml",vid];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:xmlUrl]]; //设置XML数据
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    [parser setDelegate:self];
    [parser parse];
    return nil;
}

+(NSString *)getVid:(NSString *)htmlUrl{
    NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:htmlUrl]];
    TFHpple *tfHpple = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements  = [tfHpple searchWithXPathQuery:@"//script"];
    for (TFHppleElement * element in elements)
    {
        NSArray *arr = [element children];
        for (int i = 0;i< [arr count];i++) {
            TFHppleElement *object = [arr objectAtIndex:i];
            NSString *content = [object content];
            int index = [content rangeOfString:@"vid:"].location;
            if ( index != NSNotFound) {
                NSString *str = [content substringWithRange:NSMakeRange(index, 16)];
                NSArray *arrOne = [str componentsSeparatedByString:@","];
                if ([arrOne count] > 0) {
                    NSString *strOne = [arrOne objectAtIndex:0];
                    NSArray *arrTwo = [strOne componentsSeparatedByString:@":"];
                    if ([arrTwo count]>1) {
                       return  [arrTwo objectAtIndex:1];
                    }
                }
                
            }
        }
        
    }
    return nil;
}

//NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict

{
    
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string

{   NSString *str = [string  stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    NSString *regexString = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSArray *t = [str componentsMatchedByRegex:regexString ];
    
}
@end
