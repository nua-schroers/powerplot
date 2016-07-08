//
//  WSDatum.m
//  PowerPlot
//
//  Created by Wolfram Schroers on 28.09.10.
//  Copyright 2010-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSDatum.h"
#import "WSAuxiliary.h"

/// Private implementation.
@interface WSDatum ()

@property (strong) NSMutableDictionary *ws_datum;

@end

@implementation WSDatum {
    NAFloat _valueY;
    NAFloat _valueX;
    NSString *_annotation;
}

+ (instancetype)datum {
    return [[self alloc] init];
}

+ (instancetype)datumWithValue:(NAFloat)aValue {
    return [[self alloc] initWithValue:aValue];
}

+ (instancetype)datumWithValue:(NAFloat)aValue
                    annotation:(NSString *)anno {
    return [[self alloc] initWithValue:aValue
                            annotation:anno];
}

+ (instancetype)datumWithValue:(NAFloat)aValue
                        valueX:(NAFloat)aValueX {
    return [[self alloc] initWithValue:aValue
                                valueX:aValueX];
}

+ (instancetype)datumWithValue:(NAFloat)aValue
                        valueX:(NAFloat)aValueX
                    annotation:(NSString *)anno {
    return [[self alloc] initWithValue:aValue
                                valueX:aValueX
                            annotation:anno];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.ws_datum = [NSMutableDictionary dictionaryWithCapacity:0];
        _valueX = NAN;
        _valueY = NAN;
        _annotation = nil;
    }
    return self;
}

- (instancetype)initWithValue:(NAFloat)aValue {
    self = [self init];
    if (self) {
        _valueY = aValue;
    }
    return self;
}

- (instancetype)initWithValue:(NAFloat)aValue
                   annotation:(NSString *)anno {
    self = [self initWithValue:aValue];
    if (self) {
        _annotation = [anno copy];
    }
    return self;
}

- (instancetype)initWithValue:(NAFloat)aValue
                       valueX:(NAFloat)aValueX {

    self = [self initWithValue:aValue];
    if (self) {
        _valueX = aValueX;
    }
    return self;
}

- (instancetype)initWithValue:(NAFloat)aValue
                       valueX:(NAFloat)aValueX
                   annotation:(NSString *)anno {
    self = [self initWithValue:aValue
                        valueX:aValueX];
    if (self) {
        _annotation = [anno copy];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSMutableDictionary *datumDict = [self.ws_datum mutableCopy];
    datumDict[kValueKey] = @(_valueY);
    if (!isnan(_valueX)) {
        datumDict[kValueXKey] = @(_valueX);
    }
    if (_annotation != nil) {
        datumDict[kAnnotationKey] = _annotation;
    }
    [encoder encodeObject:datumDict forKey:kDatumKey];
    [encoder encodeObject:self.customDatum forKey:kCustomKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        NSDictionary *datumDict = [decoder decodeObjectForKey:kDatumKey];
        _valueY = [datumDict[kValueKey] floatValue];
        NSMutableDictionary *the_datum = [datumDict mutableCopy];
        [the_datum removeObjectForKey:kValueKey];
        NSNumber *valueX = the_datum[kValueXKey];
        if (valueX != nil) {
            _valueX = valueX.floatValue;
            [the_datum removeObjectForKey:kValueXKey];
        } else {
            _valueX = NAN;
        }
        _annotation = the_datum[kAnnotationKey];
        if (_annotation != nil) {
            [the_datum removeObjectForKey:kAnnotationKey];
        }
        [self setCustomDatum:[decoder decodeObjectForKey:kCustomKey]];
        self.ws_datum = the_datum;
        self.delegate = nil;
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WSDatum *copy = [[[self class] allocWithZone:zone] init];
    copy.value = self.value;
    copy.valueX = self.valueX;
    copy.annotation = self.annotation;
    id datumCopy = [[NSMutableDictionary alloc] initWithDictionary:self.datum
                                                         copyItems:YES];
    copy.datum = datumCopy;
    id customCopy = [self.customDatum copyWithZone:zone];
    copy.customDatum = customCopy;
    copy.delegate = self.delegate;
    return copy;
}

#pragma mark - KVO

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
    BOOL automatic = NO;
    
    if ([theKey isEqualToString:KVO_DATUM]) {
        automatic = NO;
    } else {
        automatic=[super automaticallyNotifiesObserversForKey:theKey];
    }
    return automatic;
}

#pragma mark -

- (void)setDatum:(NSDictionary *)datum {
    @synchronized(self) {
        [self willChangeValueForKey:KVO_DATUM];
        self.ws_datum = [datum mutableCopy];
        [self didChangeValueForKey:KVO_DATUM];
    }
}

- (NSDictionary *)datum {
    return [NSDictionary dictionaryWithDictionary:self.ws_datum];
}

- (NAFloat)valueY {
    return _valueY;
}

- (NAFloat)value {
    return self.valueY;
}

- (void)setValueY:(NAFloat)aValue {
    [self willChangeValueForKey:KVO_DATUM];
    _valueY = aValue;
    [self didChangeValueForKey:KVO_DATUM];
}

- (void)setValue:(NAFloat)aValue {
    self.valueY = aValue;
}

- (NAFloat)valueX {
    return _valueX;
}

- (void)setValueX:(NAFloat)aValue {
    [self willChangeValueForKey:KVO_DATUM];
    _valueX = aValue;
    [self didChangeValueForKey:KVO_DATUM];
}

- (NSDate *)dateTime {
    return [NSDate dateWithTimeIntervalSince1970:self.valueX];
}

- (void)setDateTime:(NSDate *)dateTime {
    [self setValueX:[dateTime timeIntervalSince1970]];
}

- (NSString *)annotation {
    return _annotation;
}

- (void)setAnnotation:(NSString *)anno {
    [self willChangeValueForKey:KVO_DATUM];
    _annotation = anno;
    [self didChangeValueForKey:KVO_DATUM];
}

- (NAFloat)errorMinX {
    return [self.datum[kErrorMinXKey] floatValue];
}

- (void)setErrorMinX:(NAFloat)aValue {
    [self willChangeValueForKey:KVO_DATUM];
    @synchronized(self) {
        self.ws_datum[kErrorMinXKey] = @(aValue);
    }
    [self didChangeValueForKey:KVO_DATUM];
}

- (NAFloat)errorMaxX {
    return [self.datum[kErrorMaxXKey] floatValue];
}

- (void)setErrorMaxX:(NAFloat)aValue {
    [self willChangeValueForKey:KVO_DATUM];
    @synchronized(self) {
        self.ws_datum[kErrorMaxXKey] = @(aValue);
    }
    [self didChangeValueForKey:KVO_DATUM];
}

- (NAFloat)errorMinY {
    return [self.datum[kErrorMinYKey] floatValue];
}

- (void)setErrorMinY:(NAFloat)aValue {
    [self willChangeValueForKey:KVO_DATUM];
    @synchronized(self) {
        self.ws_datum[kErrorMinYKey] = @(aValue);
    }
    [self didChangeValueForKey:KVO_DATUM];
}
          
- (NAFloat)errorMaxY {
    return [self.ws_datum[kErrorMaxYKey] floatValue];
}

- (void)setErrorMaxY:(NAFloat)aValue {
    [self willChangeValueForKey:KVO_DATUM];
    @synchronized(self) {
        self.ws_datum[kErrorMaxYKey] = @(aValue);
    }
    [self didChangeValueForKey:KVO_DATUM];
}

- (BOOL)hasErrorX {
    return self.ws_datum[kErrorMinXKey] ? YES : NO;
}

- (BOOL)hasErrorY {
    return self.ws_datum[kErrorMinYKey] ? YES : NO;
}

- (NAFloat)errorCorr {
    return [self.ws_datum[kCorrelationKey] floatValue];
}

- (void)setErrorCorr:(NAFloat)aValue {
    [self willChangeValueForKey:KVO_DATUM];
    @synchronized(self) {
        self.ws_datum[kCorrelationKey] = @(aValue);
    }
    [self didChangeValueForKey:KVO_DATUM];
}

- (BOOL)hasErrorCorr {
    return self.ws_datum[kCorrelationKey] ? YES : NO;
}

- (BOOL)alerted {
    return [self.ws_datum[kAlertedKey] boolValue];
}

- (void)setAlerted:(BOOL)alerted {
    [self willChangeValueForKey:KVO_DATUM];
    @synchronized(self) {
        self.ws_datum[kAlertedKey] = @(alerted);
    }
    [self didChangeValueForKey:KVO_DATUM];
}

- (NSComparisonResult)valueXCompare:(id)aDatum {
    NAFloat first = self.valueX;
    NAFloat second = ((WSDatum *)aDatum).valueX;
    if (IS_EPSILON(first - second)) {
        return NSOrderedSame;
    } else if (first < second) {
        return NSOrderedAscending;
    } else {
        return NSOrderedDescending;
    }
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: (%f, %f, %@)/\"%@\"",
            [self class],
            _valueX,
            _valueY,
            [[self datum] description],
            self.annotation];
}

@end
