//
//  RNViewController.m
//  RNMDParser
//
//  Created by Ryan Nystrom on 11/12/12.
//  Copyright (c) 2012 Ryan Nystrom. All rights reserved.
//

#import "RNViewController.h"
#import "RNMDView.h"
#import "NSString+RNAttributedMarkdown.h"

@interface RNViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet RNMDView *markdownView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation RNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"md"];
    NSError *parsingError = nil;
    NSString *rawMarkdown = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&parsingError];
    if (parsingError) {
        NSLog(@"%@",parsingError.localizedDescription);
    }
    self.textView.text = rawMarkdown;
    
    NSAttributedString *markdown = [rawMarkdown markdownAttributedString];
    self.markdownView.markdown = markdown;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = self.textView.contentSize;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)_updateMarkdown {
    
}

#pragma mark - Text View delegate

- (void)textViewDidChange:(UITextView *)textView {
    self.markdownView.markdown = [textView.text markdownAttributedString];
    self.scrollView.contentSize = textView.contentSize;
}

@end
