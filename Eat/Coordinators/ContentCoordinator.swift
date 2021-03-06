//
//  ContentCoordinator.swift
//  Eat
//
//  Created by Milton Leung on 2018-06-17.
//  Copyright © 2018 launchpad. All rights reserved.
//

import UIKit
import SafariServices

protocol ContentCoordinatorDelegate: class {
  func contentCoordinatorDidFinish(_ coordinator: ContentCoordinator)
}

final class ContentCoordinator: Coordinator {
  fileprivate weak var delegate: ContentCoordinatorDelegate?
  fileprivate let navigationController: UINavigationController

  init(delegate: ContentCoordinatorDelegate, navigationController: UINavigationController) {
    self.delegate = delegate
    self.navigationController = navigationController
  }

  func start() {
    let viewModel = MapViewModelImpl()
    viewModel.onTapNext = showPeopleCount(searchQuery:)
    let mapViewController = MapViewController(viewModel: viewModel)
    navigationController.viewControllers = [mapViewController]
    navigationController.setNavigationBarHidden(true, animated: false)
  }
}

// MARK: View Controller Instantiations
extension ContentCoordinator {
  func instantiatePeopleCount(searchQuery: SearchQuery) -> PeopleCountViewController {
    let viewModel = PeopleCountViewModelImpl(searchQuery: searchQuery)
    let vc = PeopleCountViewController(viewModel: viewModel)

    viewModel.onNextButtonTapped = { searchQuery in
      self.showMealTime(viewController: vc, searchQuery: searchQuery)
    }
    viewModel.onBackButtonTapped = goBack
    viewModel.onCloseButtonTapped = close

    return vc
  }

  func instantiateMealTime(searchQuery: SearchQuery) -> MealTimeViewController {
    let viewModel = MealTimeViewModelImpl(searchQuery: searchQuery)
    let vc = MealTimeViewController(viewModel: viewModel)

    viewModel.onNextButtonTapped = { searchQuery in
      self.showRatingPrice(viewController: vc, searchQuery: searchQuery)
    }
    viewModel.onBackButtonTapped = goBack
    viewModel.onCloseButtonTapped = close

    return vc
  }

  func instantiateRatingPrice(searchQuery: SearchQuery) -> RatingPriceViewController {
    let viewModel = RatingPriceViewModelImpl(searchQuery: searchQuery)
    let vc = RatingPriceViewController(viewModel: viewModel)

    viewModel.onNextButtonTapped = { searchQuery in
      self.showFoodPreferences(viewController: vc, searchQuery: searchQuery)
    }
    viewModel.onBackButtonTapped = goBack
    viewModel.onCloseButtonTapped = close

    return vc
  }

  func instantiateFoodPreferences(searchQuery: SearchQuery) -> FoodPreferencesViewController {
    let viewModel = FoodPreferencesViewModelImpl(searchQuery: searchQuery)
    let vc = FoodPreferencesViewController(viewModel: viewModel)

    viewModel.onFinishButtonTapped = { searchQuery in
      self.showRestaurantCardSelection(viewController: vc, searchQuery: searchQuery)
    }
    viewModel.onBackButtonTapped = goBack
    viewModel.onCloseButtonTapped = close

    return vc
  }

  func instantiateRestaurantCardSelection(searchQuery: SearchQuery) -> RestaurantCardSelectionViewController {
    let viewModel = RestaurantCardSelectionViewModelImpl(searchQuery: searchQuery)
    let vc = RestaurantCardSelectionViewController(viewModel: viewModel)

    viewModel.onNoRestaurantsError = { error in
      self.restaurantCardSelection(vc, failedWith: error)
    }
    viewModel.onRestaurantTapped = { restaurant in
      self.showRestaurantInfo(vc, restaurant: restaurant)
    }
    viewModel.onFinalRestaurantSelected = { restaurant in
      self.showChosenRestaurant(vc, restaurant: restaurant)
    }
    viewModel.onCloseButtonTapped = close

    return vc
  }

  func instantiateNoRestaurantError() -> NoRestaurantFoundViewController {
    let viewModel = NoRestaurantFoundViewModelImpl()
    let vc = NoRestaurantFoundViewController(viewModel: viewModel)

    viewModel.onAdjustPreferencesTapped = {
      self.noRestaurantViewControllerFinished(vc)
    }

    return vc
  }

  func instantiateRestaurantInfo(restaurant: Restaurant) -> RestaurantInfoViewController {
    let viewModel = RestaurantInfoViewModelImpl(restaurant: restaurant)
    let vc = RestaurantInfoViewController(viewModel: viewModel)

    viewModel.onOpenSafari = { self.openSafari(vc, url: $0) }

    viewModel.onExitButtonTapped = {
      self.restaurantInfoViewControllerFinished(vc)
    }

    return vc
  }

  func instantiateChosenRestaurant(restaurant: Restaurant) -> ChosenRestaurantViewController {
    let viewModel = ChosenRestaurantViewModelImpl(restaurant: restaurant)
    let vc = ChosenRestaurantViewController(viewModel: viewModel)

    viewModel.onCallPhone = { self.callPhone(phoneNumber: $0) }
    viewModel.onOpenSafari = { self.openSafari(vc, url: $0) }
    viewModel.onExitButtonTapped = close

    return vc
  }
}

// MARK: Routing
extension ContentCoordinator {
  func showPeopleCount(searchQuery: SearchQuery) {
    let vc = instantiatePeopleCount(searchQuery: searchQuery)
    navigationController.pushViewController(vc, animated: true)
  }

  func showMealTime(viewController: PeopleCountViewController, searchQuery: SearchQuery) {
    let vc = instantiateMealTime(searchQuery: searchQuery)
    navigationController.pushViewController(vc, animated: true)
  }

  func showRatingPrice(viewController: MealTimeViewController, searchQuery: SearchQuery) {
    let vc = instantiateRatingPrice(searchQuery: searchQuery)
    navigationController.pushViewController(vc, animated: true)
  }

  func showFoodPreferences(viewController: RatingPriceViewController, searchQuery: SearchQuery) {
    let vc = instantiateFoodPreferences(searchQuery: searchQuery)
    navigationController.pushViewController(vc, animated: true)
  }

  func showRestaurantCardSelection(viewController: FoodPreferencesViewController, searchQuery: SearchQuery) {
    let vc = instantiateRestaurantCardSelection(searchQuery: searchQuery)
    navigationController.pushViewController(vc, animated: true)
  }

  func restaurantCardSelection(_ viewController: RestaurantCardSelectionViewController, failedWith error: GameError) {
    let vc = instantiateNoRestaurantError()
    navigationController.present(vc, animated: true) {
      self.navigationController.popToRootViewController(animated: false)
    }
  }

  func noRestaurantViewControllerFinished(_ viewController: NoRestaurantFoundViewController) {
    viewController.dismiss(animated: true, completion: nil)
  }

  func showRestaurantInfo(_ viewController: RestaurantCardSelectionViewController, restaurant: Restaurant) {
    let vc = instantiateRestaurantInfo(restaurant: restaurant)
    viewController.present(vc, animated: true, completion: nil)
  }

  func restaurantInfoViewControllerFinished(_ viewController: RestaurantInfoViewController) {
    viewController.dismiss(animated: true, completion: nil)
  }

  func showChosenRestaurant(_ viewController: RestaurantCardSelectionViewController, restaurant: Restaurant) {
    let vc = instantiateChosenRestaurant(restaurant: restaurant)
    navigationController.pushViewController(vc, animated: true)
  }

  func callPhone(phoneNumber: String) {
    if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {

      let application:UIApplication = UIApplication.shared
      if (application.canOpenURL(phoneCallURL)) {
        application.open(phoneCallURL, options: [:], completionHandler: nil)
      }
    }
  }

  func openSafari(_ viewController: UIViewController, url: URL) {
    let config = SFSafariViewController.Configuration()

    let safariVC = SFSafariViewController(url: url, configuration: config)
    viewController.present(safariVC, animated: true, completion: nil)
  }

  func goBack() {
    _ = navigationController.popViewController(animated: true)
  }

  func close() {
    _ = navigationController.popToRootViewController(animated: true)
  }
}
