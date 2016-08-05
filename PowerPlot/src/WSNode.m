//
//  WSNode.m
//  PowerPlot
//
//  Created by Wolfram Schroers on 01.11.10.
//  Copyright 2010-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSNode.h"
#import "WSDatum.h"
#import "WSNodeProperties.h"

@implementation WSDatum (WSNode)

+ (instancetype)node {
    WSDatum *result = [[[self class] alloc] init];
    result.customDatum = [[WSNodeProperties alloc] init];

    return result;
}

+ (instancetype)nodeAtPoint:(CGPoint)point {
    WSDatum *result = [self nodeAtPoint:point
                                  label:@""
                             properties:[[WSNodeProperties alloc] init]];
    
    return result;
}

+ (instancetype)nodeAtPoint:(CGPoint)point
                      label:(NSString *)label {
    WSDatum *result = [self nodeAtPoint:point
                                  label:label
                             properties:[[WSNodeProperties alloc] init]];

    return result;    
}

+ (instancetype)nodeAtPoint:(CGPoint)point
                      label:(NSString *)label
                 properties:(WSNodeProperties *)properties {
    WSDatum *result = [self node];

    result.valueX = point.x;
    result.valueY = point.y;
    result.annotation = label;
    result.customDatum = properties;
    
    return result;
}

- (void)setConnectionDelegate:(id<WSConnectionDelegate>)delegate {
    self.delegate = delegate;
}

- (id<WSConnectionDelegate>)connectionDelegate {
    return (id<WSConnectionDelegate>)self.delegate;
}

- (WSNodeProperties *)nodeStyle {
    return (WSNodeProperties *)self.customDatum;
}

- (void)setNodeStyle:(WSNodeProperties *)nodeStyle {
    self.customDatum = nodeStyle;
}

- (NSString *)nodeLabel {
    return self.annotation;
}

- (void)setNodeLabel:(NSString *)label {
    self.annotation = label;
}

- (UIColor *)nodeColor {
    return self.nodeStyle.nodeColor;
}

- (void)setNodeColor:(UIColor *)color {
    self.nodeStyle.nodeColor = color;
}

- (CGSize)size {
    return ((WSNodeProperties *)self.customDatum).size;
}

- (NSUInteger)connectionNumber {
    NSInteger index = [self.connectionDelegate indexOfNode:self];
    return [self.connectionDelegate connectionsOfNode:index];
}

- (NSUInteger)incomingNumber {
    NSInteger index = [self.connectionDelegate indexOfNode:self];
    return [self.connectionDelegate incomingToNode:index];
}

- (NSUInteger)outgoingNumber {
    NSInteger index = [self.connectionDelegate indexOfNode:self];
    return [self.connectionDelegate outgoingFromNode:index];
}

- (NAFloat)incomingStrength {
    NSInteger index = [self.connectionDelegate indexOfNode:self];
    return [self.connectionDelegate incomingToNodeStrength:index];
}

- (NAFloat)outgoingStrength {
    NSInteger index = [self.connectionDelegate indexOfNode:self];
    return [self.connectionDelegate outgoingFromNodeStrength:index];
}

- (NAFloat)nodeActivity {
    NSInteger index = [self.connectionDelegate indexOfNode:self];
    return [self.connectionDelegate nodeActivity:index];
}

@end
