angular.module('loomioApp').controller 'DiscussionsCardController', ($scope, $modal, Records, DiscussionFormService, KeyEventService, LoadingService, CurrentUser) ->
  $scope.loaded = 0
  $scope.perPage = 25

  $scope.loadMore = ->
    options =
      group_id: $scope.group.id
      from:     $scope.loaded
      per:      $scope.perPage
    $scope.loaded += $scope.perPage
    Records.discussions.fetchByGroup options
  LoadingService.applyLoadingFunction $scope, 'loadMore'
  $scope.loadMore()

  $scope.openDiscussionForm = ->
    DiscussionFormService.openNewDiscussionModal($scope.group)
  KeyEventService.registerKeyEvent $scope, 'pressedT', $scope.openDiscussionForm

  $scope.whyImEmpty = ->
    if !$scope.group.hasDiscussions
      'no_discussions_in_group'
    else if $scope.group.discussionPrivacyOptions == 'private_only'
      'discussions_are_private'
    else
      'no_public_discussions'

  $scope.canGainAccess = ->
    $scope.group.hasDiscussions and !CurrentUser.canSeePrivateContentFor($scope.group)

  $scope.joinGroup = ->
    # implement this, also convert to accessibility form
