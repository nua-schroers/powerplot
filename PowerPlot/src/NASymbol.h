/**
 *  @file
 *  NASymbol.h
 *  NuAS Amethyst Graphics System
 *
 *  This header defines basic functions of the NuAS Amethyst Graphics
 *  library. It defines functions and data types for plotting
 *  2D-symbols on screen.
 *
 *
 *  Created by Wolfram Schroers on 11/02/09.
 *  Copyright 2009-2013 Numerik & Analyse Schroers. All rights reserved.
 *
 */

#ifndef __NASYMBOL_H__
#define __NASYMBOL_H__

#include "NABase.h"

/** Possible symbol styles. */
typedef enum _NASymbolStyle {
    kSymbolNone,
    kSymbolDisk,
    kSymbolSquare, 
    kSymbolEmptySquare,
    kSymbolDiamond,
    kSymbolTriangleUp,
    kSymbolTriangleDown,
    kSymbolTriangleLeft,
    kSymbolTriangleRight,
    kSymbolPlus,
    kSymbolX,
    kSymbolStar
} NASymbolStyle;

/** @brief Draw a symbol on screen.

    @param aContext Drawing context.
    @param symbolStyle NASymbolStyle which declares the type of the
           symbol.
    @param aPoint Screen coordinates.
    @param symbolSize Screen size of symbol.
 */
void NAContextAddSymbol(const CGContextRef aContext,
                        const NASymbolStyle symbolStyle,
                        const CGPoint aPoint,
                        const NAFloat symbolSize);

#endif /* __NASYMBOL_H__ */

