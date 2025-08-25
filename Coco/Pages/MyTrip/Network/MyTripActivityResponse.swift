//
//  MyTripActivityResponse.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 23/08/25.
//

import Foundation

protocol MyTripActivityFetcherProtocol: AnyObject {
    func fetchTopDestination(
        completion: @escaping (Result<ActivityTopDestinationModelArray, NetworkServiceError>) -> Void
    )
    func fetchTopDestination() async throws -> ActivityTopDestinationModelArray
    func fetchActivity(
        request: ActivitySearchRequest,
        completion: @escaping (Result<ActivityModelArray, NetworkServiceError>) -> Void
    )
    func fetchActivity(request: ActivitySearchRequest) async throws -> ActivityModelArray
}

final class MyTripActivityFetcher: MyTripActivityFetcherProtocol {
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func fetchTopDestination(
        completion: @escaping (Result<ActivityTopDestinationModelArray, NetworkServiceError>) -> Void
    ) {
        networkService.request(
            urlString: ActivityEndpoint.topDestination.urlString,
            method: .post,
            parameters: [:],
            headers: [:],
            body: nil,
            completion: completion
        )
    }
    
    func fetchTopDestination() async throws -> ActivityTopDestinationModelArray {
        try await networkService.request(
            urlString: ActivityEndpoint.topDestination.urlString,
            method: .post,
            parameters: [:],
            headers: [:],
            body: nil
        )
    }
    
    func fetchActivity(
        request: ActivitySearchRequest,
        completion: @escaping (Result<ActivityModelArray, NetworkServiceError>) -> Void
    ) {
        networkService.request(
            urlString: ActivityEndpoint.all.urlString,
            method: .post,
            parameters: [:],
            headers: [:],
            body: request,
            completion: completion
        )
    }
    
    func fetchActivity(request: ActivitySearchRequest) async throws -> ActivityModelArray {
        try await networkService.request(
            urlString: ActivityEndpoint.all.urlString,
            method: .post,
            parameters: [:],
            headers: [:],
            body: request
        )
    }
    
    private let networkService: NetworkServiceProtocol
}
