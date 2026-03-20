#import "ViewController.h"
#import "KeyValidator.h"
#import "AntiDebug.h"

@interface ViewController ()
@property (nonatomic, strong) UITextField *keyField;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [AntiDebug checkPtrace];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.08 alpha:1.0];

    // Title
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"CRACKME";
    self.titleLabel.font = [UIFont monospacedSystemFontOfSize:32 weight:UIFontWeightBold];
    self.titleLabel.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.5 alpha:1.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.titleLabel];

    // Subtitle
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.text = @"Find the key. Prove yourself.";
    self.subtitleLabel.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightRegular];
    self.subtitleLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.subtitleLabel];

    // Key input field
    self.keyField = [[UITextField alloc] init];
    self.keyField.placeholder = @"Enter key...";
    self.keyField.attributedPlaceholder = [[NSAttributedString alloc]
        initWithString:@"Enter key..."
        attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.3 alpha:1.0]}];
    self.keyField.font = [UIFont monospacedSystemFontOfSize:16 weight:UIFontWeightMedium];
    self.keyField.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.5 alpha:1.0];
    self.keyField.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.12 alpha:1.0];
    self.keyField.layer.borderColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.2 alpha:1.0].CGColor;
    self.keyField.layer.borderWidth = 1.5;
    self.keyField.layer.cornerRadius = 8;
    self.keyField.textAlignment = NSTextAlignmentCenter;
    self.keyField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.keyField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.keyField.returnKeyType = UIReturnKeyDone;
    self.keyField.translatesAutoresizingMaskIntoConstraints = NO;

    // Padding
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 0)];
    self.keyField.leftView = paddingView;
    self.keyField.leftViewMode = UITextFieldViewModeAlways;

    [self.view addSubview:self.keyField];

    // Submit button
    self.submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.submitButton setTitle:@"VALIDATE" forState:UIControlStateNormal];
    self.submitButton.titleLabel.font = [UIFont monospacedSystemFontOfSize:15 weight:UIFontWeightBold];
    [self.submitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.submitButton.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.5 alpha:1.0];
    self.submitButton.layer.cornerRadius = 8;
    self.submitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.submitButton addTarget:self action:@selector(validateKey) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitButton];

    // Status label
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"";
    self.statusLabel.font = [UIFont monospacedSystemFontOfSize:14 weight:UIFontWeightMedium];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.numberOfLines = 0;
    [self.view addSubview:self.statusLabel];

    // Layout
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:80],

        [self.subtitleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:10],

        [self.keyField.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.keyField.topAnchor constraintEqualToAnchor:self.subtitleLabel.bottomAnchor constant:60],
        [self.keyField.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.82],
        [self.keyField.heightAnchor constraintEqualToConstant:52],

        [self.submitButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.submitButton.topAnchor constraintEqualToAnchor:self.keyField.bottomAnchor constant:20],
        [self.submitButton.widthAnchor constraintEqualToAnchor:self.keyField.widthAnchor],
        [self.submitButton.heightAnchor constraintEqualToConstant:48],

        [self.statusLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.submitButton.bottomAnchor constant:24],
        [self.statusLabel.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.82],
    ]];
}

- (void)validateKey {
    [self.keyField resignFirstResponder];
    NSString *input = [self.keyField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (input.length == 0) {
        [self showStatus:@"Key cannot be empty." success:NO];
        return;
    }

    BOOL valid = [KeyValidator validate:input];

    if (valid) {
        [self showStatus:@"✓ Correct! You cracked it." success:YES];
        [self triggerSuccessAnimation];
    } else {
        [self showStatus:@"✗ Wrong key. Keep trying." success:NO];
        [self triggerFailAnimation];
    }
}

- (void)showStatus:(NSString *)message success:(BOOL)success {
    self.statusLabel.text = message;
    self.statusLabel.textColor = success
        ? [UIColor colorWithRed:0.0 green:1.0 blue:0.5 alpha:1.0]
        : [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0];
}

- (void)triggerSuccessAnimation {
    [UIView animateWithDuration:0.15 animations:^{
        self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.15 blue:0.08 alpha:1.0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.08 alpha:1.0];
        }];
    }];
}

- (void)triggerFailAnimation {
    CGPoint center = self.keyField.center;
    CAKeyframeAnimation *shake = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    shake.values = @[@(center.x - 10), @(center.x + 10), @(center.x - 6), @(center.x + 6), @(center.x)];
    shake.duration = 0.35;
    [self.keyField.layer addAnimation:shake forKey:@"shake"];
}

@end
