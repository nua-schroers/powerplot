//
//  WSNodeProperties.m
//  PowerPlot
//
//  Created by Wolfram Schroers on 19.10.10.
//  Copyright 2010-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSNodeProperties.h"
#import "WSNodeProperties.h"
#import "WSAuxiliary.h"

@implementation WSNodeProperties

- (instancetype)init {
    self = [super init];
    if (self) {
        _size = CGSizeMake(kNodeWidth, kNodeHeight);
        _outlineStroke = kOutlineStroke;
        _shadowScale = kShadowScale;
        _labelPadding = kLabelPadding;
        _shadowEnabled = YES;
        _outlineColor = [UIColor colorWithRed:0.1
                                        green:0.1
                                         blue:0.4
                                        alpha:1.0];
        _nodeColor = [UIColor colorWithRed:0.3
                                     green:0.3
                                      blue:1.0
                                     alpha:1.0];
        _shadowColor = [UIColor blackColor];
        _labelColor = [_shadowColor copy];
        _labelFont = [UIFont systemFontOfSize:12];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeFloat:[self size].width forKey:kWidthKey];
    [encoder encodeFloat:[self size].height forKey:kHeightKey];
    [encoder encodeFloat:[self outlineStroke] forKey:kOutlineStrokeKey];
    [encoder encodeFloat:[self shadowScale] forKey:kShadowScaleKey];
    [encoder encodeFloat:[self labelPadding] forKey:kLabelPaddingKey];
    [encoder encodeBool:[self isShadowEnabled] forKey:kShadowEnabledKey];
    [encoder encodeObject:[self outlineColor] forKey:kOutlineColorKey];
    [encoder encodeObject:[self nodeColor] forKey:kColorKey];
    [encoder encodeObject:[self shadowColor] forKey:kShadowColorKey];
    [encoder encodeObject:[self labelColor] forKey:kLabelColorKey];
    [encoder encodeObject:[[self labelFont] fontName] forKey:kLabelFontnameKey];
    [encoder encodeFloat:[[self labelFont] pointSize] forKey:kLabelFontsizeKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _size = CGSizeMake([decoder decodeFloatForKey:kWidthKey],
                           [decoder decodeFloatForKey:kHeightKey]);
        _outlineStroke = [decoder decodeFloatForKey:kOutlineStrokeKey];
        _shadowScale = [decoder decodeFloatForKey:kShadowScaleKey];
        _labelPadding = [decoder decodeFloatForKey:kLabelPaddingKey];
        _shadowEnabled = [decoder decodeBoolForKey:kShadowEnabledKey];
        _outlineColor = [decoder decodeObjectForKey:kOutlineColorKey];
        _nodeColor = [decoder decodeObjectForKey:kColorKey];
        _shadowColor = [decoder decodeObjectForKey:kShadowColorKey];
        _labelColor = [decoder decodeObjectForKey:kLabelColorKey];
        _labelFont = [UIFont fontWithName:[decoder decodeObjectForKey:kLabelFontnameKey]
                                      size:[decoder decodeFloatForKey:kLabelFontsizeKey]];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WSNodeProperties *copy = [[[self class] allocWithZone:zone] init];
    [copy setSize:CGSizeMake([self size].width, [self size].height)];
    [copy setOutlineStroke:[self outlineStroke]];
    [copy setShadowScale:[self shadowScale]];
    [copy setLabelPadding:[self labelPadding]];
    [copy setShadowEnabled:[self isShadowEnabled]];
    [copy setOutlineColor:[[self outlineColor] copyWithZone:zone]];
    [copy setNodeColor:[[self nodeColor] copyWithZone:zone]];
    [copy setShadowColor:[[self shadowColor] copyWithZone:zone]];
    [copy setLabelColor:[[self labelColor] copyWithZone:zone]];
    [copy setLabelFont:[[self labelFont] copyWithZone:zone]];
    return copy;
}

@end
