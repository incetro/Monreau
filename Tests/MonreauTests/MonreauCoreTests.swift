//
//  MonreauCoreTests.swift
//  Monreau
//
//  Created by incetro on 05/07/2017.
//
//

import XCTest
import Monreau
import CoreData

// MARK: - MonreauCoreTests

class MonreauCoreTests: XCTestCase {
    
    typealias UserStorage = CoreStorage<UserCoreDataObject>

    private lazy var storage: UserStorage = {
        do {
            return try CoreStorage<UserCoreDataObject>(configuration: CoreStorageConfig(containerName: "Monreau", storeType: .memory))
        } catch {
            fatalError()
        }
    }()

    private let modelsCount = 1000
    
    /// Create an object using configuration
    func testMNRC1() {
        do {
            let name = "Name"
            let id: Int64 = 13
            let age: Int16 = 20
            let user = try storage.create { user in
                user.name = name
                user.id = id
                user.age = age
            }
            XCTAssertEqual(user.id, id)
            XCTAssertEqual(user.age, age)
            XCTAssertEqual(user.name, name)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// Read all
    func testMNRC2() {
        
        /// given

        var usersData: [(id: Int64, name: String, age: Int16)] = []

        for i in 0..<modelsCount {
            usersData.append((id: Int64(i), name: "Name #\(i)", age: Int16(i + 10)))
        }

        do {

            /// when

            try storage.create(count: usersData.count) { users in
                for (user, data) in zip(users, usersData) {
                    user.id   = data.id
                    user.age  = data.age
                    user.name = data.name
                }
            }
            
            /// then
            
            let objects = try storage.read().sorted { $0.id < $1.id }
            XCTAssert(objects.count == modelsCount)
            
            for i in 0..<objects.count {
                let data   = usersData[i]
                let object = objects[i]
                XCTAssertEqual(data.id,   object.id)
                XCTAssertEqual(data.age,  object.age)
                XCTAssertEqual(data.name, object.name)
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// Read all with ordering by the given property
    func testMNRC3() {
        
        /// given

        var usersData: [(id: Int64, name: String, age: Int16)] = []

        for i in 0..<modelsCount {
            usersData.append((id: Int64(i), name: "Name #\(i)", age: Int16(i + 10)))
        }

        do {

            /// when

            try storage.create(count: usersData.count) { users in
                for (user, data) in zip(users, usersData) {
                    user.id   = data.id
                    user.age  = data.age
                    user.name = data.name
                }
            }
            
            /// then
            
            let objects = try storage.read(orderedBy: UserCoreDataObject.primaryKey, ascending: true)
            XCTAssert(objects.count == modelsCount)
            
            for i in 0..<objects.count {
                let data   = usersData[i]
                let object = objects[i]
                XCTAssertEqual(data.id,   object.id)
                XCTAssertEqual(data.age,  object.age)
                XCTAssertEqual(data.name, object.name)
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// Read objects with the given predicate
    func testMNRC4() {
        
        /// given

        let predicateId = 5
        let predicate = "id > \(predicateId)"
        var usersData: [(id: Int64, name: String, age: Int16)] = []

        for i in 0..<modelsCount {
            usersData.append((id: Int64(i), name: "Name #\(i)", age: Int16(i + 10)))
        }

        do {

            /// when

            try storage.create(count: usersData.count) { users in
                for (user, data) in zip(users, usersData) {
                    user.id   = data.id
                    user.age  = data.age
                    user.name = data.name
                }
            }
            
            /// then
            
            let objects = try storage.read(predicatedBy: predicate).sorted { $0.id < $1.id }
            XCTAssert(objects.count == modelsCount - predicateId - 1)
            
            for i in 0..<objects.count {
                let data   = usersData[i + predicateId + 1]
                let object = objects[i]
                XCTAssertEqual(data.id,   object.id)
                XCTAssertEqual(data.age,  object.age)
                XCTAssertEqual(data.name, object.name)
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// Read objects with the given predicate and sort descriptor
    func testMNRC5() {
        
        /// given

        let predicateId = 5
        let predicate = "id > \(predicateId)"
        let sortDescriptor = SortDescriptor(key: "id", ascending: true)
        var usersData: [(id: Int64, name: String, age: Int16)] = []

        for i in 0..<modelsCount {
            usersData.append((id: Int64(i), name: "Name #\(i)", age: Int16(i + 10)))
        }

        do {

            /// when

            try storage.create(count: usersData.count) { users in
                for (user, data) in zip(users, usersData) {
                    user.id   = data.id
                    user.age  = data.age
                    user.name = data.name
                }
            }
            
            /// then
            
            let objects = try storage.read(predicatedBy: predicate, includeSubentities: true, sortDescriptors: [sortDescriptor])
            XCTAssert(objects.count == modelsCount - predicateId - 1)
            
            for i in 0..<objects.count {
                let data   = usersData[i + predicateId + 1]
                let object = objects[i]
                XCTAssertEqual(data.id,   object.id)
                XCTAssertEqual(data.age,  object.age)
                XCTAssertEqual(data.name, object.name)
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// Read by primary key
    func testMNRC6() {
        
        /// given

        let primaryKey: UserCoreDataObject.PrimaryType = 5
        var usersData: [(id: Int64, name: String, age: Int16)] = []

        for i in 0..<modelsCount {
            usersData.append((id: Int64(i), name: "Name #\(i)", age: Int16(i + 10)))
        }

        do {

            /// when

            try storage.create(count: usersData.count) { users in
                for (user, data) in zip(users, usersData) {
                    user.id   = data.id
                    user.age  = data.age
                    user.name = data.name
                }
            }

            /// then
            
            let object = try storage.read(byPrimaryKey: primaryKey)
            XCTAssertNotNil(object)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// Persist objects array
    func testMNRC7() {
        
        /// given

        var usersData: [(id: Int64, name: String, age: Int16)] = []

        for i in 0..<modelsCount {
            usersData.append((id: Int64(i), name: "Name #\(i)", age: Int16(i + 10)))
        }

        do {

            /// when

            try storage.create(count: usersData.count) { users in
                for (user, data) in zip(users, usersData) {
                    user.id   = data.id
                    user.age  = data.age
                    user.name = data.name
                }
            }
            
            /// then
            
            do {
                let objects = try storage.read()
                objects.forEach {
                    $0.age = 14
                }
                try storage.persist(objects: objects)
            }
            let objects = try storage.read().sorted { $0.id < $1.id }
            XCTAssert(objects.count == modelsCount)
            
            for i in 0..<objects.count {
                let data   = usersData[i]
                let object = objects[i]
                XCTAssertEqual(data.id, object.id)
                XCTAssertEqual(14, object.age)
                XCTAssertEqual(data.name, object.name)
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// Persist objects by predicate
    func testMNRC8() {
        
        /// given

        let predicateId = 5
        let predicate = "id > \(predicateId)"
        let sortDescriptor = SortDescriptor(key: "id", ascending: true)
        var usersData: [(id: Int64, name: String, age: Int16)] = []

        for i in 0..<modelsCount {
            usersData.append((id: Int64(i), name: "Name #\(i)", age: Int16(i + 10)))
        }

        do {

            /// when

            try storage.create(count: usersData.count) { users in
                for (user, data) in zip(users, usersData) {
                    user.id   = data.id
                    user.age  = data.age
                    user.name = data.name
                }
            }
            
            /// then
            
            try storage.persist(predicatedBy: predicate) { objects in
                objects.forEach {
                    $0.age = 13
                }
            }
            let objects = try storage.read(predicatedBy: predicate, includeSubentities: true, sortDescriptors: [sortDescriptor])
            XCTAssert(objects.count == modelsCount - predicateId - 1)
            
            for i in 0..<objects.count {
                let data   = usersData[i + predicateId + 1]
                let object = objects[i]
                XCTAssertEqual(data.id, object.id)
                XCTAssertEqual(13, object.age)
                XCTAssertEqual(data.name, object.name)
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    /// Create without config
    func testMNRC9() {
        
        /// given

        var usersData: [(id: Int64, name: String, age: Int16)] = []

        for i in 0..<modelsCount {
            usersData.append((id: Int64(i), name: "Name #\(i)", age: Int16(i + 10)))
        }

        do {

            /// when

            var objects: [UserCoreDataObject] = try storage.create(count: usersData.count)
            for (object, data) in zip(objects, usersData) {
                object.age = data.age
                object.id = data.id
                object.name = data.name
            }

            try storage.persist(objects: objects)
            
            /// then
            
            objects = try storage.read().sorted { $0.id < $1.id }
            XCTAssert(objects.count == modelsCount)
            
            for i in 0..<objects.count {
                let data   = usersData[i]
                let object = objects[i]
                XCTAssertEqual(data.id, object.id)
                XCTAssertEqual(data.age, object.age)
                XCTAssertEqual(data.name, object.name)
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// Persisting by primary key
    func testMNRC10() {
        
        /// given

        var usersData: [(id: Int64, name: String, age: Int16)] = []

        for i in 0..<modelsCount {
            usersData.append((id: Int64(i), name: "Name #\(i)", age: Int16(i + 10)))
        }

        do {

            /// when

            try storage.create(count: usersData.count) { users in
                for (user, data) in zip(users, usersData) {
                    user.id   = data.id
                    user.age  = data.age
                    user.name = data.name
                }
            }
            
            /// then
            
            for i in 0..<modelsCount {
                try storage.persist(withPrimaryKey: Int64(i)) {
                    $0?.age = 13
                }
            }
            
            let objects = try storage.read().sorted { $0.id < $1.id }
            XCTAssert(objects.count == modelsCount)
            
            for i in 0..<objects.count {
                let data   = usersData[i]
                let object = objects[i]
                XCTAssertEqual(data.id, object.id)
                XCTAssertEqual(13, object.age)
                XCTAssertEqual(data.name, object.name)
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
