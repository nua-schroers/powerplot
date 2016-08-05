//
//  WSAxisProperties.m
//  PowerPlot
//
//  Created by Wolfram Schroers on 1/22/12.
//  Copyright (c) 2012-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSAxisProperties.h"
#import "WSColor.h"
#import "WSAuxiliary.h"

@implementation WSAxisProperties

- (instancetype)init {
    self = [super init];
    if (self) {
        _axisLabel = @"";
        _labelFont = [UIFont systemFontOfSize:12];
        _labelColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:[self axisStyle] forKey:kAxisStyleKey];
    [encoder encodeFloat:[self axisOverhang] forKey:kAxisOverhangKey];
    [encoder encodeFloat:[self axisPadding] forKey:kAxisPaddingKey];
    [encoder encodeInt:[self gridStyle] forKey:kGridStyleKey];
    [encoder encodeInt:[self labelStyle] forKey:kLabelStyleKey];
    [encoder encodeFloat:[self labelOffset] forKey:kLabelOffsetKey];
    [encoder encodeObject:[self axisLabel] forKey:kAxisLabelKey];
    [encoder encodeObject:[self labelColor] forKey:kLabelColorKey];
    [encoder encodeObject:[[self labelFont] fontName] forKey:kLabelFontnameKey];
    [encoder encodeFloat:[[self labelFont] pointSize] forKey:kLabelFontsizeKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _axisStyle = [decoder decodeIntForKey:kAxisStyleKey];
        _axisOverhang = [decoder decodeFloatForKey:kAxisOverhangKey];
        _axisPadding = [decoder decodeFloatForKey:kAxisPaddingKey];
        _gridStyle = [decoder decodeIntForKey:kGridStyleKey];
        _labelStyle = [decoder decodeIntForKey:kLabelStyleKey];
        _labelOffset = [decoder decodeFloatForKey:kLabelOffsetKey];
        _axisLabel = [decoder decodeObjectForKey:kAxisLabelKey];
        _labelColor = [decoder decodeObjectForKey:kLabelColorKey];
        _labelFont = [UIFont fontWithName:[decoder decodeObjectForKey:kLabelFontnameKey]
                                     size:[decoder decodeFloatForKey:kLabelFontsizeKey]];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WSAxisProperties *copy = [[[self class] allocWithZone:zone] init];
    [copy setAxisStyle:[self axisStyle]];
    [copy setAxisOverhang:[self axisOverhang]];
    [copy setAxisPadding:[self axisPadding]];
    [copy setGridStyle:[self gridStyle]];
    [copy setLabelStyle:[self labelStyle]];
    [copy setLabelOffset:[self labelOffset]];
    [copy setAxisLabel:[[self axisLabel] copyWithZone:zone]];
    [copy setLabelColor:[[self labelColor] copyWithZone:zone]];
    [copy setLabelFont:[[self labelFont] copyWithZone:zone]];
    return copy;
}

@end
