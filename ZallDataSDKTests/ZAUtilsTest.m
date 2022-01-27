//
// ZAUtilsTest.m
// ZallDataSDKTests
//
// Created by guo on 2019/10/26.
// Copyright © 2019 ZallData. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <XCTest/XCTest.h>
#import "ZAQuickUtil.h"

@interface ZAUtilsTest : XCTestCase
@end

@implementation ZAUtilsTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

}

- (void)tearDown {

}

#pragma mark - NSString
- (void)testZalldataHashCode {
    NSString *text1 = @"1234rfsdvzfxbgtry6htge";
    NSString *text2 = @"dawefrr45tredfsghbdf";
    
    int code1= za_string_generate_hashcode(text1);
    int code2= za_string_generate_hashcode(text1);
    int code3= za_string_generate_hashcode(text2);
    BOOL equele1 = code1 == code2;
    XCTAssertTrue(equele1);

    BOOL different1 = code1!= code3;
    XCTAssertTrue(different1);

    NSString *text4 = @"^*&()%^)$*#!@#!#@";
    NSString *text5 = @"<>??<_)_!@)@UWJKSJDJ";
    int code4= za_string_generate_hashcode(text4);
    int code5= za_string_generate_hashcode(text4);
    int code6= za_string_generate_hashcode(text5);
    BOOL equele2 = code4 == code5;
    XCTAssertTrue(equele2);

    BOOL different2 = code4!= code6;
    XCTAssertTrue(different2);

    NSString *chTest6 = @"你好哈王入网她34q";
    int code7= za_string_generate_hashcode(chTest6);
    int code8= za_string_generate_hashcode(chTest6);
    BOOL equele3 = code7 == code8;
    XCTAssertTrue(equele3);

    NSString *chTest7 = @"🔥sd🙂哈哈😆👌@#🐶";
    int code9= za_string_generate_hashcode(chTest7);
    int code10= za_string_generate_hashcode(chTest7);
    BOOL equele4 = code9 == code10;
    XCTAssertTrue(equele4);
}

- (void)testStrnlenFunction {
// strlen 隐含高危漏洞，改为 strnlen
    char* containEmpty1 = "casdv\0gndfb";
    size_t emptyLenth1 = strnlen(containEmpty1, __INTMAX_MAX__);
    size_t emptyLenth2 = strlen(containEmpty1);
    BOOL emptyEquele1 = emptyLenth1 == emptyLenth2;
    XCTAssertTrue(emptyEquele1);

    char* letter1 = "casdv234555dfb4erwfdsc";
    size_t letterLenth1 = strnlen(letter1, __INTMAX_MAX__);
    size_t letterLenth2 = strlen(letter1);
    BOOL letterEquele1 = letterLenth1 == letterLenth2;
    XCTAssertTrue(letterEquele1);

    char* endEmpty1 = "casdv435646gndfb\0";
    size_t endLenth1 = strnlen(endEmpty1, __INTMAX_MAX__);
    size_t endLenth2 = strlen(endEmpty1);
    BOOL endEquele1 = endLenth1 == endLenth2;
    XCTAssertTrue(endEquele1);

    NSString *cnString = @"你好哇，继续测试234rwfss";
    char *unicode = (char *)[cnString cStringUsingEncoding:NSUnicodeStringEncoding];
    size_t cnLenth1 = strnlen(unicode, __INTMAX_MAX__);
    size_t cnLenth2 = strlen(unicode);
    BOOL cnEquele1 = cnLenth1 == cnLenth2;
    XCTAssertTrue(cnEquele1);

    char array1[50] = {'1', 'a', 'a', 'a', 'f', '2', '\0'};
    size_t arrayLenth1 = strnlen(array1, __INTMAX_MAX__);
    size_t arrayLenth2 = strlen(array1);
    BOOL arrayEquele1 = arrayLenth1 == arrayLenth2;
    XCTAssertTrue(arrayEquele1);

    char array2[50] = {'1', 'a', 'a','\0', 'a', 'f', '2'};
    size_t arrayLenth3 = strnlen(array2, __INTMAX_MAX__);
    size_t arrayLenth4 = strlen(array2);
    BOOL arrayEquele2 = arrayLenth3 == arrayLenth4;
    XCTAssertTrue(arrayEquele2);
}

- (void)testStrlcpyFunction {
// memcpy 隐含高危漏洞，改为 strlcpy
    char containEmpty1[50] = "casdv\0gndfb";
    char containEmpty2[50];
    char containEmpty3[50];
    memcpy(containEmpty2, containEmpty1,sizeof(containEmpty2));
    strlcpy(containEmpty3, containEmpty1, sizeof(containEmpty3));
    BOOL emptyEquele1 = strcmp(containEmpty2, containEmpty3) == 0;
    XCTAssertTrue(emptyEquele1);

    char letter1[50] = "casdv234555dfb4erwfdsc";
    char letter2[50];
    char letter3[50];
    memcpy(letter2, letter1,sizeof(letter2));
    strlcpy(letter3, letter1, sizeof(letter3));
    BOOL letterEquele1 = strcmp(letter2, letter3) == 0;
    XCTAssertTrue(letterEquele1);

    char endEmpty1[50] = "casdv435646gndfb\0";
    char endEmpty2[50];
    char endEmpty3[50];
    memcpy(endEmpty2, endEmpty1,sizeof(endEmpty2));
    strlcpy(endEmpty3, endEmpty1, sizeof(endEmpty3));
    BOOL endEmptyEquele1 = strcmp(endEmpty2, endEmpty3) == 0;
    XCTAssertTrue(endEmptyEquele1);
}

@end
