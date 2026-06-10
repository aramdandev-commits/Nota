import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Nota'**
  String get appName;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'QUICK ACTIONS'**
  String get quickActions;

  /// No description provided for @welecomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome\nback 👋'**
  String get welecomeBack;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @allChangesSynced.
  ///
  /// In en, this message translates to:
  /// **'All changes\nsynced'**
  String get allChangesSynced;

  /// No description provided for @allChangesSyncedPop.
  ///
  /// In en, this message translates to:
  /// **'All changes synced'**
  String get allChangesSyncedPop;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @spaces.
  ///
  /// In en, this message translates to:
  /// **'Spaces'**
  String get spaces;

  /// No description provided for @spacesDescription.
  ///
  /// In en, this message translates to:
  /// **'Organize & collaborate\nwith workspaces'**
  String get spacesDescription;

  /// No description provided for @createSpace.
  ///
  /// In en, this message translates to:
  /// **'Create Space'**
  String get createSpace;

  /// No description provided for @searchSpaces.
  ///
  /// In en, this message translates to:
  /// **'Search spaces...'**
  String get searchSpaces;

  /// No description provided for @mySpaces.
  ///
  /// In en, this message translates to:
  /// **'MY SPACES'**
  String get mySpaces;

  /// No description provided for @noSpacesFound.
  ///
  /// In en, this message translates to:
  /// **'No Spaces Found'**
  String get noSpacesFound;

  /// No description provided for @contributor.
  ///
  /// In en, this message translates to:
  /// **'Contributor'**
  String get contributor;

  /// No description provided for @createNewSpace.
  ///
  /// In en, this message translates to:
  /// **'Create New Space'**
  String get createNewSpace;

  /// No description provided for @createNewSpaceDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a workspace to organize notes'**
  String get createNewSpaceDescription;

  /// No description provided for @spaceName.
  ///
  /// In en, this message translates to:
  /// **'Space Name'**
  String get spaceName;

  /// No description provided for @enterSpaceName.
  ///
  /// In en, this message translates to:
  /// **'Enter space name'**
  String get enterSpaceName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get enterDescription;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get public;

  /// No description provided for @publicDescription.
  ///
  /// In en, this message translates to:
  /// **'Anyone can join'**
  String get publicDescription;

  /// No description provided for @privateDescription.
  ///
  /// In en, this message translates to:
  /// **'Only invited members can access'**
  String get privateDescription;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @newSpace.
  ///
  /// In en, this message translates to:
  /// **'New Space'**
  String get newSpace;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @noNotesFound.
  ///
  /// In en, this message translates to:
  /// **'No notes found'**
  String get noNotesFound;

  /// No description provided for @noMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No members found'**
  String get noMembersFound;

  /// No description provided for @searchNotes.
  ///
  /// In en, this message translates to:
  /// **'Search notes…'**
  String get searchNotes;

  /// No description provided for @searchMembers.
  ///
  /// In en, this message translates to:
  /// **'Search members…'**
  String get searchMembers;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @inviteMembers.
  ///
  /// In en, this message translates to:
  /// **'Invite Members'**
  String get inviteMembers;

  /// No description provided for @inviteMembersDescription.
  ///
  /// In en, this message translates to:
  /// **'Send an invite by email address'**
  String get inviteMembersDescription;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @leaveSpace.
  ///
  /// In en, this message translates to:
  /// **'Leave Space'**
  String get leaveSpace;

  /// No description provided for @thisCannotBe.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone ?'**
  String get thisCannotBe;

  /// No description provided for @deleteSpace.
  ///
  /// In en, this message translates to:
  /// **'Delete Space'**
  String get deleteSpace;

  /// No description provided for @editSpace.
  ///
  /// In en, this message translates to:
  /// **'Edit Space'**
  String get editSpace;

  /// No description provided for @allowMembersToEdit.
  ///
  /// In en, this message translates to:
  /// **'Allow members to edit'**
  String get allowMembersToEdit;

  /// No description provided for @allowMembersToEditDescription.
  ///
  /// In en, this message translates to:
  /// **'Contributors can create and edit notes'**
  String get allowMembersToEditDescription;

  /// No description provided for @makeSpacePublic.
  ///
  /// In en, this message translates to:
  /// **'Make space public'**
  String get makeSpacePublic;

  /// No description provided for @anyoneWithLink.
  ///
  /// In en, this message translates to:
  /// **'Anyone with the link can view'**
  String get anyoneWithLink;

  /// No description provided for @toggleFavorite.
  ///
  /// In en, this message translates to:
  /// **'Toggle Favorite'**
  String get toggleFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove Favorite'**
  String get removeFavorite;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// No description provided for @updateYourDetail.
  ///
  /// In en, this message translates to:
  /// **'Update the details of your note'**
  String get updateYourDetail;

  /// No description provided for @updateNote.
  ///
  /// In en, this message translates to:
  /// **'updateNote'**
  String get updateNote;

  /// No description provided for @createNoteSpaces.
  ///
  /// In en, this message translates to:
  /// **'Create Note +'**
  String get createNoteSpaces;

  /// No description provided for @giveYourNoteAname.
  ///
  /// In en, this message translates to:
  /// **'Give your note a name to get started'**
  String get giveYourNoteAname;

  /// No description provided for @noteName.
  ///
  /// In en, this message translates to:
  /// **'Note Name'**
  String get noteName;

  /// No description provided for @enterNoteName.
  ///
  /// In en, this message translates to:
  /// **'Enter note name...'**
  String get enterNoteName;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tags (optional)'**
  String get tag;

  /// No description provided for @tagDescription.
  ///
  /// In en, this message translates to:
  /// **'marketing, ideas, planning...'**
  String get tagDescription;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get members;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'RECENT ACTIVITY'**
  String get recentActivity;

  /// No description provided for @summarize.
  ///
  /// In en, this message translates to:
  /// **'Summarize'**
  String get summarize;

  /// No description provided for @importPDF.
  ///
  /// In en, this message translates to:
  /// **'Import PDF'**
  String get importPDF;

  /// No description provided for @aiAnalyze.
  ///
  /// In en, this message translates to:
  /// **'AI Analyze'**
  String get aiAnalyze;

  /// No description provided for @aiSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get aiSummary;

  /// No description provided for @aiAnalyzerDescription.
  ///
  /// In en, this message translates to:
  /// **'Summarize & extract insights'**
  String get aiAnalyzerDescription;

  /// No description provided for @pasteText.
  ///
  /// In en, this message translates to:
  /// **'Paste Text'**
  String get pasteText;

  /// No description provided for @fromNote.
  ///
  /// In en, this message translates to:
  /// **'From Note'**
  String get fromNote;

  /// No description provided for @aiAnalyzer.
  ///
  /// In en, this message translates to:
  /// **'AI Analyzer'**
  String get aiAnalyzer;

  /// No description provided for @generateSummary.
  ///
  /// In en, this message translates to:
  /// **'Generate Summary'**
  String get generateSummary;

  /// No description provided for @generateAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Generate Summary'**
  String get generateAnalysis;

  /// No description provided for @selectNote.
  ///
  /// In en, this message translates to:
  /// **'Select a note to analyze'**
  String get selectNote;

  /// No description provided for @pasteOrType.
  ///
  /// In en, this message translates to:
  /// **'Paste or type text to analyze...'**
  String get pasteOrType;

  /// No description provided for @aiAnalysisResult.
  ///
  /// In en, this message translates to:
  /// **'Analysis Results'**
  String get aiAnalysisResult;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'SUMMARY'**
  String get summary;

  /// No description provided for @keyPoint.
  ///
  /// In en, this message translates to:
  /// **'KEY POINTS'**
  String get keyPoint;

  /// No description provided for @saveAsNote.
  ///
  /// In en, this message translates to:
  /// **'Save As Note'**
  String get saveAsNote;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @newAnalysis.
  ///
  /// In en, this message translates to:
  /// **'New Analysis'**
  String get newAnalysis;

  /// No description provided for @aiCard.
  ///
  /// In en, this message translates to:
  /// **'Summarize your notes instantly'**
  String get aiCard;

  /// No description provided for @tryCard.
  ///
  /// In en, this message translates to:
  /// **'Try'**
  String get tryCard;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search notes, tags...'**
  String get search;

  /// No description provided for @myNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get myNotes;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @createNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get createNote;

  /// No description provided for @createNoteDescription.
  ///
  /// In en, this message translates to:
  /// **'Start writing'**
  String get createNoteDescription;

  /// No description provided for @untitledNote.
  ///
  /// In en, this message translates to:
  /// **'Untitled Note'**
  String get untitledNote;

  /// No description provided for @noContent.
  ///
  /// In en, this message translates to:
  /// **'No Content'**
  String get noContent;

  /// No description provided for @emptyNote.
  ///
  /// In en, this message translates to:
  /// **'Empty Note'**
  String get emptyNote;

  /// No description provided for @canEdit.
  ///
  /// In en, this message translates to:
  /// **'Can Edit'**
  String get canEdit;

  /// No description provided for @viewer.
  ///
  /// In en, this message translates to:
  /// **'Can View'**
  String get viewer;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @allNotes.
  ///
  /// In en, this message translates to:
  /// **'All Notes'**
  String get allNotes;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @moveToSpaces.
  ///
  /// In en, this message translates to:
  /// **'Move to Space'**
  String get moveToSpaces;

  /// No description provided for @noteInfo.
  ///
  /// In en, this message translates to:
  /// **'Note Info'**
  String get noteInfo;

  /// No description provided for @researchSpace.
  ///
  /// In en, this message translates to:
  /// **'Research Space'**
  String get researchSpace;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// No description provided for @shareNote.
  ///
  /// In en, this message translates to:
  /// **'Share Note'**
  String get shareNote;

  /// No description provided for @shareThisNote.
  ///
  /// In en, this message translates to:
  /// **'Share this note with your team'**
  String get shareThisNote;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get enterEmail;

  /// No description provided for @sendInvite.
  ///
  /// In en, this message translates to:
  /// **'Send Invite'**
  String get sendInvite;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @deleteThisNote.
  ///
  /// In en, this message translates to:
  /// **'Delete this note ?'**
  String get deleteThisNote;

  /// No description provided for @moveToTrash.
  ///
  /// In en, this message translates to:
  /// **'This note will be moved to trash'**
  String get moveToTrash;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noteCreationGuide.
  ///
  /// In en, this message translates to:
  /// **'Press the + button to Create your first note'**
  String get noteCreationGuide;

  /// No description provided for @importPdfDescription.
  ///
  /// In en, this message translates to:
  /// **'PDF → Note'**
  String get importPdfDescription;

  /// No description provided for @importPdfDescriptionFile.
  ///
  /// In en, this message translates to:
  /// **'Upload a PDF file to convert it into a note'**
  String get importPdfDescriptionFile;

  /// No description provided for @tapToSelectPdf.
  ///
  /// In en, this message translates to:
  /// **'Tap to select PDF file'**
  String get tapToSelectPdf;

  /// No description provided for @pdfFileDescription.
  ///
  /// In en, this message translates to:
  /// **'PDF files only · Max 50MB'**
  String get pdfFileDescription;

  /// No description provided for @browseFiles.
  ///
  /// In en, this message translates to:
  /// **'Browse Files'**
  String get browseFiles;

  /// No description provided for @processingPdf.
  ///
  /// In en, this message translates to:
  /// **'Processing PDF'**
  String get processingPdf;

  /// No description provided for @analyzingPages.
  ///
  /// In en, this message translates to:
  /// **'Analyzing pages...'**
  String get analyzingPages;

  /// No description provided for @recognizingText.
  ///
  /// In en, this message translates to:
  /// **'Recognizing text...'**
  String get recognizingText;

  /// No description provided for @formattingContent.
  ///
  /// In en, this message translates to:
  /// **'Formatting content...'**
  String get formattingContent;

  /// No description provided for @conversionComplete.
  ///
  /// In en, this message translates to:
  /// **'Conversion Complete'**
  String get conversionComplete;

  /// No description provided for @processedPages.
  ///
  /// In en, this message translates to:
  /// **'9 pages processed'**
  String get processedPages;

  /// No description provided for @collaborate.
  ///
  /// In en, this message translates to:
  /// **'Collaborate'**
  String get collaborate;

  /// No description provided for @collaborateDescription.
  ///
  /// In en, this message translates to:
  /// **'Team notes'**
  String get collaborateDescription;

  /// No description provided for @recentNotes.
  ///
  /// In en, this message translates to:
  /// **'Recent Notes'**
  String get recentNotes;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noNotesFoundYet.
  ///
  /// In en, this message translates to:
  /// **'No notes found yet'**
  String get noNotesFoundYet;

  /// No description provided for @createNoteToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Create your first note to start capturing your ideas and projects'**
  String get createNoteToGetStarted;

  /// No description provided for @aiPoweredNotesTakingPlatform.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Notes Taking Platform'**
  String get aiPoweredNotesTakingPlatform;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account Created Successfully'**
  String get accountCreatedSuccessfully;

  /// No description provided for @successDescription.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created. You can now start taking notes.'**
  String get successDescription;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a reset link.'**
  String get resetPasswordSubtitle;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @passwordResetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'A password reset link has been sent to your email'**
  String get passwordResetLinkSent;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @invalidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmailAddress;

  /// No description provided for @validationPasswordAtLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordAtLeast8Characters;

  /// No description provided for @validationPasswordLowercaseLetters.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one lowercase letter'**
  String get validationPasswordLowercaseLetters;

  /// No description provided for @validationPasswordUppercaseLetters.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get validationPasswordUppercaseLetters;

  /// No description provided for @validationPasswordSpecialCharacter.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one special character'**
  String get validationPasswordSpecialCharacter;

  /// No description provided for @validationPasswordNumbers.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get validationPasswordNumbers;

  /// No description provided for @validationConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationConfirmPassword;

  /// No description provided for @validationName.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get validationName;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordResetSuccess;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @securityPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get securityPrivacy;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @notificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive updates about your notes'**
  String get notificationDescription;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushDescription.
  ///
  /// In en, this message translates to:
  /// **'Get notified about real-time updates'**
  String get pushDescription;

  /// No description provided for @twoFactorAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuthentication;

  /// No description provided for @addExtraLayer.
  ///
  /// In en, this message translates to:
  /// **'Add an extra layer of security to your account'**
  String get addExtraLayer;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?  '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?  '**
  String get alreadyHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
