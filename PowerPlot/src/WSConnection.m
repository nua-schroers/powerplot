//
//  WSConnection.m
//  PowerPlot
//
//  Created by Wolfram Schroers on 18.10.10.
//  Copyright 2010-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSConnection.h"
#import "WSAuxiliary.h"

@implementation WSConnection

+ (instancetype)connection {
    return [[self alloc] init];
}

+ (instancetype)connectionFrom:(NSUInteger)a
                            to:(NSUInteger)b {
    return [[self alloc] initFrom:a to:b];
}

+ (instancetype)connectionFrom:(NSUInteger)a
                            to:(NSUInteger)b
                      strength:(NAFloat)s {
    return [[self alloc] initFrom:a to:b strength:s];
}

- (instancetype)init {
    return [self initFrom:0 to:0];
}

- (instancetype)initFrom:(NSUInteger)a
                      to:(NSUInteger)b {
    return [self initFrom:a to:b strength:kStrengthDefault];
}

- (instancetype)initFrom:(NSUInteger)a
                      to:(NSUInteger)b
                strength:(NAFloat)s {
    self = [super init];
    if (self) {
        _to = b;
        _from = a;
        _direction = kGDirection;
        _strength = s;
        _label = @"";
        _color = [UIColor grayColor];
    }
    return self;    
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:[self to] forKey:kConnectionToKey];
    [encoder encodeInteger:[self from] forKey:kConnectionFromKey];
    [encoder encodeInt:[self direction] forKey:kConnectionDirectionKey];
    [encoder encodeFloat:[self strength] forKey:kConnectionStrengthKey];
    [encoder encodeObject:[self label] forKey:kLabelKey];
    [encoder encodeObject:[self color] forKey:kColorKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _to = [decoder decodeIntForKey:kConnectionToKey];
        _from = [decoder decodeIntForKey:kConnectionFromKey];
        _direction = [decoder decodeBoolForKey:kConnectionDirectionKey];
        _strength = [decoder decodeFloatForKey:kConnectionStrengthKey];
        _label = [decoder decodeObjectForKey:kLabelKey];
        _color = [decoder decodeObjectForKey:kColorKey];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WSConnection *copy = [[[self class] allocWithZone:zone] init];
    [copy setTo:[self to]];
    [copy setFrom:[self from]];
    [copy setDirection:[self direction]];
    [copy setStrength:[self strength]];
    [copy setLabel:[NSString stringWithString:[self label]]];
    [copy setColor:[self color]];
    return copy;
}

@end

