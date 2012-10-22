//
//  StringUtility.m
//  CommonUtility
//
//  Created by 永庆 李 on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StringUtility.h"

@implementation StringUtility

+ (BOOL ) stringIsEmpty:(NSString *) aString {
    
    if ((NSNull *) aString == [NSNull null]) {
        return YES;
    }
    if ([aString isEqualToString:@"EMPTY"]){
        return YES;
    }
    
    if (aString == nil) {
        return YES;
    } else if ([aString length] == 0) {
        return YES;
    } else {
        aString = [aString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([aString length] == 0) {
            return YES;
        }
    }
    
    return NO;  
}

+ (BOOL ) stringIsEmpty:(NSString *) aString shouldCleanWhiteSpace:(BOOL)cleanWhileSpace {
    
    if ((NSNull *) aString == [NSNull null]) {
        return YES;
    }
    
    if (aString == nil) {
        return YES;
    } else if ([aString length] == 0) {
        return YES;
    } 
    
    if (cleanWhileSpace) {
        aString = [aString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([aString length] == 0) {
            return YES;
        }
    }
    
    return NO;  
}

+ (NSString*) nullToEmpty:(NSString *) aString {
    
    if ([StringUtility stringIsEmpty:aString]) {
        return @"";
    } else {
        return aString;
    }

}

+ (NSString*) generateClassStudentStatusKey:(NSString *) studentId classInfoObjectId:(NSString*) classInfoObjectId {
    return [NSString stringWithFormat:@"%@_%@", studentId, classInfoObjectId];
}

//Parse may return NSNull object to the client
+ (BOOL ) isNotEqualToNull:(NSObject *) param {
     if(param != nil && ![param isKindOfClass:[NSNull class]]){
         return YES;
     } else {
         return NO;
     }
    
}

+ (BOOL) IsValidEmail:(NSString*) checkString {
    
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";  
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];  
    if(![emailTest evaluateWithObject:checkString]){
        
        return FALSE;
    }else{
        
        return TRUE;
        
    }
}

@end
