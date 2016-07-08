//
//  WSBarProperties.m
//  PowerPlot
//
//  Created by Wolfram Schroers on 16.10.10.
//  Copyright 2010-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSBarProperties.h"
#import "WSAuxiliary.h"

@implementation WSBarProperties

- (instancetype)init {
    self = [super init];
    if (self) {
        _barWidth = kBarWidth;
        _barOffset = 0.f;
        _outlineStroke = kOutlineStroke;
        _shadowScale = kShadowScale;
        _style = kBarOutline;
        _shadowEnabled = NO;
        _outlineColor = [UIColor colorWithRed:0.1f
                                        green:0.1f
                                         blue:0.4f
                                        alpha:1.0f];
        _barColor = [UIColor colorWithRed:0.3f
                                    green:0.3f
                                     blue:1.0f
                                    alpha:1.0f];
        _barColor2 = [UIColor whiteColor];
        _shadowColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeFloat:[self barWidth] forKey:kWidthKey];
    [encoder encodeFloat:[self barOffset] forKey:kOffsetKey];
    [encoder encodeFloat:[self outlineStroke] forKey:kOutlineStrokeKey];
    [encoder encodeFloat:[self shadowScale] forKey:kShadowScaleKey];
    [encoder encodeInt:[self style] forKey:kStyleKey];
    [encoder encodeBool:[self isShadowEnabled] forKey:kShadowEnabledKey];
    [encoder encodeObject:[self outlineColor] forKey:kOutlineColorKey];
    [encoder encodeObject:[self barColor] forKey:kColorKey];
    [encoder encodeObject:[self barColor2] forKey:kColorAltKey];
    [encoder encodeObject:[self shadowColor] forKey:kShadowColorKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _barWidth = [decoder decodeFloatForKey:kWidthKey];
        _barOffset = [decoder decodeFloatForKey:kOffsetKey];
        _outlineStroke = [decoder decodeFloatForKey:kOutlineStrokeKey];
        _shadowScale = [decoder decodeFloatForKey:kShadowScaleKey];
        _style = [decoder decodeIntForKey:kStyleKey];
        _shadowEnabled = [decoder decodeBoolForKey:kShadowEnabledKey];
        _outlineColor = [decoder decodeObjectForKey:kOutlineColorKey];
        _barColor = [decoder decodeObjectForKey:kColorKey];
        _barColor2 = [decoder decodeObjectForKey:kColorAltKey];
        _shadowColor = [decoder decodeObjectForKey:kShadowColorKey];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WSBarProperties *copy = [[[self class] allocWithZone:zone] init];
    [copy setBarWidth:[self barWidth]];
    [copy setOutlineStroke:[self outlineStroke]];
    [copy setShadowScale:[self shadowScale]];
    [copy setStyle:[self style]];
    [copy setShadowEnabled:[self isShadowEnabled]];
    [copy setOutlineColor:[[self outlineColor] copyWithZone:zone]];
    [copy setBarColor:[[self barColor] copyWithZone:zone]];
    [copy setBarColor2:[[self barColor2] copyWithZone:zone]];
    [copy setShadowColor:[[self shadowColor] copyWithZone:zone]];
    return copy;
}

@end
