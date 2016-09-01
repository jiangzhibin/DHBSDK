//
//  MarkTeleHelper.m
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/12.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#import "DHBSDKMarkTeleHelper.h"
#import "DHBSDKOpenUDID.h"
#import "DHBSDKApiManager.h"
#import "DHBSDKSignatureHelper.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "Commondef.h"
#import "DHBSDKAPIDotDianHuaDotCNClient.h"
#import "DHBSDKYuloreAPIClient.h"

@implementation DHBSDKMarkTeleHelper

// Get IP Address
+ (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] ||
                   [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}




+ (void)markTeleNumberOnlineWithNumber:(NSString *)aNumber
                        flagInfomation:(NSString *)flagInfomation
                     completionHandler:(void (^)( BOOL successed, NSError *error))completeBlock {
    
    aNumber = [aNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    aNumber = [aNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    aNumber = [aNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    aNumber = [aNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    aNumber = [aNumber stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    
    
    NSString * uid = [DHBSDKOpenUDID value];
    NSString *ip = [self getIPAddress];
    NSString * appName = [NSString  stringWithFormat:@"%@.ios", [[[NSBundle mainBundle] infoDictionary]
                                                                 objectForKey:(NSString*)kCFBundleIdentifierKey]];
    NSString *sig = [DHBSDKSignatureHelper flagSignature:aNumber withFlag:flagInfomation withAppname:appName];
    NSString *query = [NSString stringWithFormat:@"flag/?uid=%@&tel=%@&apikey=%@&sig=%@&uip=%@&flag=%@&app=%@" ,uid, aNumber, [DHBSDKApiManager shareManager].apiKey,sig,ip,flagInfomation, appName ];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    DHBSDKDLog(@"SDK ------ sig: %@", sig);
    DHBSDKDLog(@"SDK ------ uid: %@", uid);
    DHBSDKDLog(@"SDK ------ query: %@", query);
    
    [[DHBSDKAPIDotDianHuaDotCNClient sharedClient] GET:query parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                DHBSDKDLog(@"SDK ----- response");
                DHBSDKDLog(@"SDK ------ responseObject : %@", responseObject);
                
                if ([responseObject[@"msg"] isEqualToString:@"Accepted"]) {
                    completeBlock(YES, nil);
                }
                else {
                    NSError *error = [[NSError alloc] initWithDomain:@"CAN NOT MARK" code:10000 userInfo:responseObject];
                    completeBlock(NO, error);
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        DHBSDKDLog(@"SDK ------ failure");
        completeBlock(NO, error);
    }];
    //  YuloreAFJSONRequestOperation *op = [YuloreAFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
    //
    //
    //  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
    //
    //  }];
    //  [op start];
    //
}

@end
