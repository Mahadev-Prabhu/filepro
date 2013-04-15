//
//  MPOutlineView.h
//  HomeScreen
//
//  Created by Mahadevaprabhu K S on 07/02/13.
//  Copyright (c) 2013 Mahadevaprabhu K S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol MPOutlineViewDataSource;
@protocol MPOutlineViewDelegate;

@interface MPOutlineView : UITableView <UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <MPOutlineViewDataSource> outlineViewDataSource;
@property (nonatomic, weak) id <MPOutlineViewDelegate> outlineViewDelegate;

- (void)reload;

@end

//*********************************************************************************************************//

@protocol MPOutlineViewDataSource

@required

- (NSUInteger)outlineView:(MPOutlineView *)outlineView numberOfChildrenForItem:(NSObject *)item;
- (NSObject *)outlineView:(MPOutlineView *)outlineView itemForIndex:(NSInteger)index inRoot:(NSObject *)root;
- (BOOL)outlineView:(MPOutlineView *)outlineView isThisExtendebleItem:(NSObject *)item;
- (NSString *)outlineView:(MPOutlineView *)outlineView titleForItem:(NSObject *)item;

@end

//*********************************************************************************************************//

@protocol MPOutlineViewDelegate

@optional

- (void)outlineView:(MPOutlineView *)outlineView didSelectAtItem:(NSObject *)item;

@end

//*********************************************************************************************************//