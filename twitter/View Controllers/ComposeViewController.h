//
//  ComposeViewController.h
//  twitter
//
//  Created by Benjamin Charles Hora on 6/30/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ComposeViewControllerDelegate

- (void)didTweet:(Tweet *)tweet;

@end

@interface ComposeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *NewTweet;

@property (strong, nonatomic) Tweet *tweet;

@property (nonatomic) BOOL reply;

@property (nonatomic, weak) id<ComposeViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
