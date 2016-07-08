//
//  WSNode.h
//  PowerPlot
//
//  Created by Wolfram Schroers on 01.11.10.
//  Copyright 2010-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSDatum.h"
#import "WSConnectionDelegate.h"

@class WSNodeProperties;

/// Category for a @p WSDatum with @p WSNodeProperties in the @p
/// customData slot. It offers convenience methods to access
/// information specific to nodes.
@interface WSDatum (WSNode)

/** @return An empty node (factory method). */
+ (instancetype)node;

/** @return A node at a point (factory method).
 
    @param point A point on the canvas in data coordinates.
 */
+ (instancetype)nodeAtPoint:(CGPoint)point;

/** @return A node at a point with label text (factory method).
 
    @param point A point on the canvas in data coordinates.
    @param label A string with the node label text.
 */
+ (instancetype)nodeAtPoint:(CGPoint)point
                      label:(NSString *)label;

/** @return A node at a point with text and properties (factory
    method).
 
    @param point A point on the canvas in data coordinates.
    @param label A string with the node label text.
    @param properties A @p WSNodeProperties object with style
           information.
 */
+ (instancetype)nodeAtPoint:(CGPoint)point
                      label:(NSString *)label
                 properties:(WSNodeProperties *)properties;

/** Set the connection delegate for this node.
 
    @param delegate Delegate satisfying the @p WSConnectionDelegate
           protocol.
 */
- (void)setConnectionDelegate:(id<WSConnectionDelegate>)delegate;

/** @return Connection delegate for this node. */
- (id<WSConnectionDelegate>)connectionDelegate;

/** @return The style information of this node. */
- (WSNodeProperties *)nodeStyle;

/** Set the @p WSNodeProperty style information on this node.
 
    @param nodeStyle The @p WSNodeProperty style information of this
           node.
 */
- (void)setNodeStyle:(WSNodeProperties *)nodeStyle;

/** @return Label of this node (the annotation of @p WSDatum). */
- (NSString *)nodeLabel;

/** Set the label of this node (the annotation of @p WSDatum). */
- (void)setNodeLabel:(NSString *)label;

/** @return Color of this node (style property). */
- (UIColor *)nodeColor;

/** Set the color of this node (style property). */
- (void)setNodeColor:(UIColor *)color;

/** @return The size of this node (style property). */
- (CGSize)size;

/** @return Total number of connections of this node.
 
    A circular connection is counted as one. The direction is
    irrelevant.
 
    @note Multiple connections to another node are counted separately.
 */
- (NSUInteger)connectionNumber;

/** @return Total number of directed incoming connections.
 
    The total number of links this node receives. An incoming
    connection is a connection whose direction property is either @p
    kGDirection with this node a as the "to" link, @p
    kGDirectionInverse with this node as the "from" link or a @p
    kGDirectionBoth with this node as either the "to" or the "from"
    link.
 
    @note Multiple connections to another node are counted separately.
 */
- (NSUInteger)incomingNumber;

/** @return Total number of directed outgoing connections.
 
    The total number of links originating from this node. The
    conventions regarding directions are as in @p incomingNumber with
    the meaning of "from" and "to" reversed.
 */
- (NSUInteger)outgoingNumber;

/** @return Total incoming connection strength.
 
    All directed incoming connections this node receives are counted
    and their respective strength is summed up. The conventions
    regarding directions are as in @p incomingNumber.
 */
- (NAFloat)incomingStrength;

/** @return Total outgoing connection strength.
 
    All directed outgoing connections this node has are counted and
    their respectives strength is summed up. The conventions regarding
    directions are as in @p incomingNumber with the meaning of "from"
    and "to" reversed.
 */
- (NAFloat)outgoingStrength;

/** @return Total node connection strength.
 
    Sum of strengths of all directed incoming and outgoing
    connections.
 */
- (NAFloat)nodeActivity;

@end
