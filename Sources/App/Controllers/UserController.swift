//
//  UserController.swift
//  App
//
//  Created by CaptainYukinoshitaHachiman on 2018/8/14.
//

import Vapor
import Fluent
import Crypto
import Authentication

class UserController: RouteCollection {
    
    func boot(router: Router) throws {
        router.get(User.parameter, use: getHandler)
        router.get("search", use: searchUsernameHandler)
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthenticatedRoute = router.grouped(basicAuthMiddleware)
        basicAuthenticatedRoute.post("login", use: loginHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthenticatedRoute = router.grouped(tokenAuthMiddleware)
        tokenAuthenticatedRoute.post(use: createHandler)
    }
    
    func createHandler(_ request: Request) throws -> Future<User.Public> {
        return try request
            .content
            .decode(User.self)
            .flatMap { user in
                guard user.id == nil else {
                    throw Abort(.badRequest, reason: "You can't pass an id when registering since it's decided by the server.")
                }
                
                let operatorPermission = try request.authenticated(User.self)?.permission ?? .user
                guard user.permission.rawValue <= operatorPermission.rawValue else {
                    throw Abort(.badRequest, reason: "You don't have the permission to register a admin/root user.")
                }
                
                user.password = try BCrypt.hash(user.password) // Make the password hashed
                return user
                    .create(on: request)
                    .public
        }
    }
    
    func getHandler(_ request: Request) throws -> Future<User.Public> {
        return try request
            .parameters
            .next(User.self)
            .map { return $0.public }
    }
    
    func loginHandler(_ request: Request) throws -> Future<Token> {
        let user = try request.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: request)
    }
    
    func searchUsernameHandler(_ request: Request) throws -> Future<[User.Public]> {
        guard let username = request.query[String.self, at: "username"] else { throw Abort(.badRequest) }
        return User
            .query(on: request)
            .filter(\.username == username)
            .all()
            .map { $0.map { $0.public } }
    }
    
}
