//
//  HexUtil.m
//  HexUtil
//
//  Created by Tam Nguyen on 5/5/15.
//  Copyright (c) 2015 MagTek. All rights reserved.
//

#import "HexUtil.h"


@implementation HexUtil {
    
    
}


+ (NSString *)toHex:(NSData *)aData {
    return [HexUtil toHex:aData offset:0 len:aData.length];
}

+ (NSData *)getBytesFromHexString:(NSString*)strIn
{
    const char *chars = [strIn UTF8String];
    int i = 0;
    NSInteger len = strIn.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}


+ (NSString *)toHex:(NSData *)aData offset:(uint)aOffset len:(NSUInteger)aLen {
    NSMutableString *sb = [[NSMutableString alloc] initWithCapacity:aData.length*2];
    uint8_t const *bytes = aData.bytes;
    NSUInteger max = aOffset+aLen;
    for(NSUInteger i=aOffset; i < max; i++) {
        uint8_t b = bytes[i];
        [sb appendFormat:@"%02X", b];
    }
    return sb;
}
+ (NSData *) dataFromHexString:(NSString*)stringIn
{
    if ([stringIn rangeOfString:@"."].location == NSNotFound) {
        stringIn = [stringIn stringByAppendingString:@".00"];
    }
    NSCharacterSet *setToRemove = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    NSCharacterSet *setToKeep = [setToRemove invertedSet];
    
    stringIn =  [[stringIn componentsSeparatedByCharactersInSet: setToKeep] componentsJoinedByString:@""];
//    if(![stringIn containsString:@"."])
        stringIn = [NSString stringWithFormat:@"%.02f",stringIn.doubleValue];
   
    
    
  
    
    
    
    NSString * cleanString = [self cleanNonHexCharsFromHexString:stringIn];
    if (cleanString == nil) {
        return nil;
    }
    
    if(cleanString.length % 2)
    {
        cleanString = [NSString stringWithFormat:@"0%@", cleanString];
    }
    
    
    NSMutableData *result = [[NSMutableData alloc] init];
    
    int i = 0;
    for (i = 0; i+2 <= cleanString.length; i+=2) {
        NSRange range = NSMakeRange(i, 2);
        NSString* hexStr = [cleanString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        unsigned char uc = (unsigned char) intValue;
        [result appendBytes:&uc length:1];
    }
    NSData * data = [NSData dataWithData:result];
    //[result release];
    return [self reverseData:data];
}
+ (NSString *) cleanNonHexCharsFromHexString:(NSString *)input
{
    if (input == nil) {
        return nil;
        
    }
    
    NSString * output = [input stringByReplacingOccurrencesOfString:@"0x" withString:@""
                                                            options:NSCaseInsensitiveSearch range:NSMakeRange(0, input.length)];
    NSString * hexChars = @"-0123456789abcdefABCDEF";
    NSCharacterSet *hexc = [NSCharacterSet characterSetWithCharactersInString:hexChars];
    NSCharacterSet *invalidHexc = [hexc invertedSet];
    NSString * allHex = [[output componentsSeparatedByCharactersInSet:invalidHexc] componentsJoinedByString:@""];
    return allHex;
}
+ (NSData *)reverseData:(NSData*)dataIn
{
    NSMutableData *data = [[NSMutableData alloc] init];
    for(int i = (int)dataIn.length - 1; i >=0; i--){
        [data appendBytes: &dataIn.bytes[i] length:1];
    }
    return [data copy];
}

+ (NSString *)stringFromHexString:(NSString *)hexString {
    
    
    if (([hexString length] % 2) != 0)
        return nil;
    
    NSMutableString *string = [NSMutableString string];
    
    for (NSInteger i = 0; i < [hexString length]; i += 2) {
        
        NSString *hex = [hexString substringWithRange:NSMakeRange(i, 2)];
        unsigned int decimalValue = 0;
        sscanf([hex UTF8String], "%x", &decimalValue);
        [string appendFormat:@"%c", decimalValue];
        
    }
    
    
    return string;
}
@end
