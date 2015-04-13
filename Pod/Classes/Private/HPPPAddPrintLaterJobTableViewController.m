//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "HPPPAddPrintLaterJobTableViewController.h"
#import "UITableView+HPPPHeader.h"
#import "HPPPPrintLaterQueue.h"
#import "HPPP.h"
#import "HPPPDefaultSettingsManager.h"
#import "UIColor+HPPPStyle.h"

@interface HPPPAddPrintLaterJobTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *addToPrintQLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *dateTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *printerNameTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *printerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *printerLocationTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *printerLocationLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *addToPrintQCell;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButtonItem;
@property (strong, nonatomic) UIColor *navigationBarTintColor;
@property (strong, nonatomic) UIBarButtonItem *doneButtonItem;

@end

@implementation HPPPAddPrintLaterJobTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_OS_8_OR_LATER) {
        HPPPPrintLaterManager *printLaterManager = [HPPPPrintLaterManager sharedInstance];
        
        [printLaterManager initLocationManager];
        
        if ([printLaterManager currentLocationPermissionSet]) {
            [printLaterManager initUserNotifications];
        }
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    HPPP *hppp = [HPPP sharedInstance];
    
    self.addToPrintQLabel.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenAddToPrintQFontAttribute];
    self.addToPrintQLabel.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenAddToPrintQColorAttribute];
    
    self.nameTextField.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenJobNameFontAttribute];
    self.nameTextField.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenJobNameColorInactiveAttribute];
    
    self.dateTitleLabel.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenSubitemTitleFontAttribute];
    self.dateTitleLabel.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenSubitemTitleColorAttribute];
    
    self.dateLabel.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenSubitemFontAttribute];
    self.dateLabel.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenSubitemColorAttribute];
    
    self.printerNameTitleLabel.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenSubitemTitleFontAttribute];
    self.printerNameTitleLabel.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenSubitemTitleColorAttribute];
    
    self.printerNameLabel.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenSubitemFontAttribute];
    self.printerNameLabel.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenSubitemColorAttribute];
    
    self.printerLocationTitleLabel.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenSubitemTitleFontAttribute];
    self.printerLocationTitleLabel.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenSubitemTitleColorAttribute];
    
    self.printerLocationLabel.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenSubitemFontAttribute];
    self.printerLocationLabel.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenSubitemColorAttribute];
    
    self.nameTextField.text = self.printLaterJob.name;
    self.nameTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.nameTextField.layer.borderWidth = 2.0f;
    self.nameTextField.delegate = self;
    self.nameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:[HPPP sharedInstance].defaultDateFormat];
    self.dateLabel.text = [dateFormatter stringFromDate:self.printLaterJob.date];
    
    NSString *paperSizeTitle = [HPPPPaper titleFromSize:[HPPP sharedInstance].initialPaperSize];
    self.imageView.image = [self.printLaterJob.images objectForKey:paperSizeTitle];
    
    [self preparePrinterDisplayValues];
    
    UIButton *doneButton = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenDoneButtonAttribute];
    
    [doneButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    [doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationBarTintColor = self.navigationController.navigationBar.barTintColor;
}

- (void)preparePrinterDisplayValues
{
    HPPPDefaultSettingsManager *settings = [HPPPDefaultSettingsManager sharedInstance];
    if (settings.isDefaultPrinterSet) {
        self.printerNameLabel.text = settings.defaultPrinterName;
        self.printerLocationLabel.text = settings.defaultPrinterNetwork;
    } else {
        self.printerNameTitleLabel.hidden = YES;
        self.printerNameLabel.hidden = YES;
        self.printerLocationTitleLabel.hidden = YES;
        self.printerLocationLabel.hidden = YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    if (cell == self.addToPrintQCell) {
        
        [self.nameTextField resignFirstResponder];
        
        self.printLaterJob.name = self.nameTextField.text;
        
        BOOL result = [[HPPPPrintLaterQueue sharedInstance] addPrintLaterJob:self.printLaterJob];
        
        if (result) {
            if ([self.delegate respondsToSelector:@selector(addPrintLaterJobTableViewControllerDidFinishPrintFlow:)]) {
                [self.delegate addPrintLaterJobTableViewControllerDidFinishPrintFlow:self];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(addPrintLaterJobTableViewControllerDidCancelPrintFlow:)]) {
                [self.delegate addPrintLaterJobTableViewControllerDidCancelPrintFlow:self];
            }
        }
    }
}

- (IBAction)cancelButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addPrintLaterJobTableViewControllerDidCancelPrintFlow:)]) {
        [self.delegate addPrintLaterJobTableViewControllerDidCancelPrintFlow:self];
    }
}

- (void)doneButtonTapped:(id)sender
{
    [self.nameTextField resignFirstResponder];
    [self setNavigationBarEditing:NO];
}

- (void)setNavigationBarEditing:(BOOL)editing
{
    HPPP *hppp = [HPPP sharedInstance];

    UIColor *barTintColor = self.navigationBarTintColor;
    NSString *navigationBarTitle = @"Add Print";
    UIBarButtonItem *rightBarButtonItem = self.cancelButtonItem;
    
    UIColor *nameTextFieldColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenJobNameColorInactiveAttribute];

    if (editing) {
        navigationBarTitle = nil;
        barTintColor = [UIColor HPPPHPTabBarSelectedColor];
        rightBarButtonItem = self.doneButtonItem;
        nameTextFieldColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenJobNameColorActiveAttribute];
    }
    
    self.navigationController.navigationBar.barTintColor = barTintColor;
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem animated:YES];

    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.nameTextField.textColor = nameTextFieldColor;
                         self.navigationItem.title = navigationBarTitle;
                     }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self setNavigationBarEditing:YES];
}

@end
