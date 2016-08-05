//
//  WSDataPointProperties.m
//  PowerPlot
//
//  Created by Wolfram Schroers on 1/19/12.
//  Copyright (c) 2012-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSDataPointProperties.h"
#import "WSColor.h"
#import "WSAuxiliary.h"

@implementation WSDataPointProperties

- (instancetype)init {
    self = [super init];
    if (self) {
        _symbolStyle = kSymbolDisk;
        _symbolSize = kSymbolSize;
        _symbolColor = [UIColor blackColor];
        _errorStyle = kErrorNone;
        _errorBarColor = [UIColor blackColor];
        _errorBarLen = kErrorBarLen;
        _errorBarWidth = kErrorBarWdith;
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:[self symbolStyle] forKey:kStyleKey];
    [encoder encodeFloat:[self symbolSize] forKey:kSizeKey];
    [encoder encodeObject:[self symbolColor] forKey:kColorKey];
    [encoder encodeFloat:[self errorBarLen] forKey:kErrorbarLenKey];
    [encoder encodeFloat:[self errorBarWidth] forKey:kWidthKey];
    [encoder encodeObject:[self errorBarColor] forKey:kColorAltKey];
    [encoder encodeInt:[self errorStyle] forKey:kErrorBarStyleKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _symbolStyle = [decoder decodeIntForKey:kStyleKey];
        _symbolSize = [decoder decodeFloatForKey:kSizeKey];
        _symbolColor = [decoder decodeObjectForKey:kColorKey];
        _errorBarLen = [decoder decodeFloatForKey:kErrorbarLenKey];
        _errorBarWidth = [decoder decodeFloatForKey:kWidthKey];
        _errorBarColor = [decoder decodeObjectForKey:kColorAltKey];
        _errorStyle = [decoder decodeIntForKey:kErrorBarStyleKey];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WSDataPointProperties *copy = [[[self class] allocWithZone:zone] init];
    [copy setSymbolStyle:[self symbolStyle]];
    [copy setSymbolSize:[self symbolSize]];
    [copy setSymbolColor:[[self symbolColor] copyWithZone:zone]];
    [copy setErrorBarLen:[self errorBarLen]];
    [copy setErrorBarWidth:[self errorBarWidth]];
    [copy setErrorBarColor:[[self errorBarColor] copyWithZone:zone]];
    [copy setErrorStyle:[self errorStyle]];
    return copy;
}

@end
