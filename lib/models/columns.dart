class BDColumns {
  // User columns
  static const String userId = 'id';
  static const String username = 'username';
  static const String email = 'email';
  static const String firstName = 'first_name';
  static const String lastName = 'last_name';

  // Program columns
  static const String programId = 'id';
  static const String programName = 'name';
  static const String programCode = 'code';

  // Role columns
  static const String roleId = 'id';
  static const String roleName = 'name';
  static const String roleDescription = 'description';

  // UserRole columns
  static const String userRoleId = 'id';
  static const String userRoleUser = 'user';
  static const String userRoleRole = 'role';

  // Subscription columns
  static const String subscriptionId = 'id';
  static const String subscriptionUser = 'user';
  static const String subscriptionProgram = 'program';
  static const String subscriptionSubscribedAt = 'subscribed_at';

  // News columns
  static const String newsId = 'id';
  static const String newsAuthor = 'author';
  static const String newsProgram = 'program';
  static const String newsTitleDraft = 'title_draft';
  static const String newsContentDraft = 'content_draft';
  static const String newsTitleFinal = 'title_final';
  static const String newsContentFinal = 'content_final';
  static const String newsImportance = 'importance';
  static const String newsModeratorApproved = 'moderator_approved';
  static const String newsModerator = 'moderator';
  static const String newsWrittenAt = 'written_at';
  static const String newsModeratedAt = 'moderated_at';
  static const String newsPublishDateRequested = 'publish_date_requested';
  static const String newsPublishDateEffective = 'publish_date_effective';
  static const String newsInvalidated = 'invalidated';
  static const String newsInvalidatedBy = 'invalidated_by';
  static const String newsInvalidationReason = 'invalidation_reason';
  static const String newsCreatedAt = 'created_at';
  static const String newsUpdatedAt = 'updated_at';
  static const String newsAttachments = 'attachments';
  // Moderation columns
  static const String moderationId = 'id';
  static const String moderationNews = 'news';
  static const String moderationModerator = 'moderator';
  static const String moderationApproved = 'approved';
  static const String moderationComment = 'comment';
  static const String moderationModeratedAt = 'moderated_at';

  // Attachment columns
  static const String attachmentId = 'id';
  static const String attachmentNews = 'news';
  static const String attachmentFile = 'file';
  static const String attachmentMime = 'mime';
  static const String attachmentFilesize = 'filesize';

  // PublicationLog columns
  static const String publicationLogId = 'id';
  static const String publicationLogNews = 'news';
  static const String publicationLogScheduledAt = 'scheduled_at';
  static const String publicationLogPublishedAt = 'published_at';
  static const String publicationLogChannel = 'channel';
  static const String publicationLogSentCount = 'sent_count';

  // NotificationPref columns
  static const String notificationPrefId = 'id';
  static const String notificationPrefUser = 'user';
  static const String notificationPrefFrequency = 'frequency';
  static const String notificationPrefPushEnabled = 'push_enabled';
  static const String notificationPrefEmailEnabled = 'email_enabled';
  static const String notificationPrefUpdatedAt = 'updated_at';

  // NewsView columns
  static const String newsViewId = 'id';
  static const String newsViewUser = 'user';
  static const String newsViewNews = 'news';
  static const String newsViewViewedAt = 'viewed_at';

  // PushSubscription columns
  static const String pushSubscriptionId = 'id';
  static const String pushSubscriptionUser = 'user';
  static const String pushSubscriptionExternalUserId = 'external_user_id';
  static const String pushSubscriptionDeviceToken = 'device_token';
  static const String pushSubscriptionCreatedAt = 'created_at';
}
