//
//  WebView.h
//  Terror Cells
//
//  Created by Gal Blank on 11/7/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebView : UIViewController<UIWebViewDelegate>
{
    NSString *link;
    NSString *title;
    UIImage *image;
    UIWebView *loadView;
    NSMutableArray *itemsArray;
}
@property(nonatomic,retain)UIImage *image;
@property(nonatomic,retain)NSString *link;
@property(nonatomic,retain)NSString *title;

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webViewDidStartLoad:(UIWebView *)webView;
@end
