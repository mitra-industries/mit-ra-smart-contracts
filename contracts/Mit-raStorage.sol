pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './SystemOwner.sol';

/**
 * @title Mit-raStorage
 * @dev smart contract used to store the main data of the MIT-RA exchange
 */
contract Mit-raStorage {
    using SafeMath for uint256;

    // related user rank withing a system
    enum Rank {NotSet, Untrusted, Known, Trusted, Vedified, Certified, Vip}
    // the status of an entity
    enum State {Unknown, New, Active, InProgress, Finished, Rejected}
    // the role of the user
    enum Role {Undefined, Publisher, Advertiser}
    // the hit types
    enum HitType {Undefined, Display, Action}

    // user's data structure
    struct User {
        // unix timestamp
        uint created;
        // ethereum address of the user
        address owner;
        // the role of the user
        Role role;
        // name of the user
        string name;
        // details of the user (ideally URL to the full details)
        string details;
        // user's rank withing a system
        Rank rank;
        // user's state
        State state;
    }

    // publishing space data structure
    struct AdSpace {
        // unix timestamp
        uint created;
        // the UUID of the user who owns this space
        bytes16 owner;
        // visual representation of the space
        string name;
        // the URL of the website providing publishing space
        string url;
        // the full details of the space
        string details;
        // a list of advertising category ids the space can accept for publishing
        uint16[] categories;
        // publishing space state
        State state;
    }

    // advertiser offer data structure
    struct Offer {
        // unix timestamp
        uint created;
        // the UUID of the user who owns this offer
        bytes16 owner;
        // visual representation of the offer
        string name;
        // the base unit price of the display of promoted ad
        uint256 hitPrice;
        // the base unit price of actions undertaking by promoted ad
        uint256 actionPrice;
        // the full details of the offer
        string details;
        // a list of advertising category ids the offer can be associated with
        uint16[] categories;
        // advertiser offer state
        State state;
    }

    // advertising hit (display or action) data structure
    struct Hit {
        // unix timestamp
        uint created;
        // the type of the hit
        HitType hitType;
        // the UUID of the session the hit was performed by
        bytes16 session;
        // the UUID of the advertising space the hit was displayed on
        bytes16 space;
        // the UUID of the offer the hit was displayed for
        bytes16 offer;
        // the MIT-RA token amount advertiser pays for this hit
        uint256 amount;
        // the full details of the hit
        string details;
        // a list of advertising category ids the space can accept for publishing
        uint16[] categories;
        // hit state
        State state;
    }

    // list of users
    mapping (bytes16 => User) public users;
    // list of advertising spaces
    mapping (bytes16 => AdSpace) public adSpaces;
    // list of advertiser offers
    mapping (bytes16 => Offer) public offers;
    // list of advertising hits (displays or actions)
    mapping (bytes16 => Hit) public hits;

    // stores a list of system addresses who have access to crucial functionality
    SystemOwner public systemOwner;

    // check that sender actually has access to crucial functionality
    modifier onlyOwner() {
        require(systemOwner.isOwner(msg.sender));
        _;
    }

    /**
    * @param systemOwnerAddress ethereum address of the access control smart-contract
    */
    function Mit-raStorage(address systemOwnerAddress) public {
        systemOwner = SystemOwner(systemOwnerAddress);
    }

    /**
    * Set new ethereum address of the access control smart-contract
    *
    * @param systemOwnerAddress ethereum address of the access control smart-contract
    */
    function setSystemOwner(address systemOwnerAddress) public onlyOwner {
        systemOwner = SystemOwner(systemOwnerAddress);
    }

    /**
    * Set the user data
    * if any param comes with a default data value it will not be updated
    *
    * @param id UUID of the user
    * @param owner ethereum address of the user (actually receiver of the MIT-RA tokens)
    * @param role the system role of the user
    * @param name name of the user for visual identification by the system participants
    * @param details details of the user, ideally an URL with the full data available
    * @param rank system rank of the user
    * @param state status of the user (should be New in most cases)
    */
    function setUser(bytes16 id, address owner, Role role, string name, string details, Rank rank, State state) public onlyOwner {
        if (users[id].state == State.Unknown) {
            users[id] = User({
                created : now,
                owner : owner,
                role : role,
                name : name,
                details : details,
                rank : rank,
                state : state
            });
        } else {
            users[id] = User({
                created : users[id].created,
                owner : (owner == address(0)) ? users[id].owner : owner,
                role : users[id].role,
                name : (bytes(name).length == 0) ? users[id].name : name,
                details : (bytes(details).length == 0) ? users[id].details : details,
                rank : (rank == Rank.NotSet) ? users[id].rank : rank,
                state : (state == State.Unknown) ? users[id].state : state
            });
        }
    }

    /**
    * Set the advertising space data
    * if any param comes with a default data value it will not be updated
    *
    * @param id UUID of the advertising space
    * @param owner UUID of the user who owns this space
    * @param name visual representation of the space
    * @param url URL of the website providing publishing space
    * @param details full details of the space
    * @param categories a list of advertising category ids the space can accept for publishing
    * @param state status of the advertising space
    */
    function setAdSpace(bytes16 id, bytes16 owner, string name, string url, string details, uint16[] categories, State state) public onlyOwner {
        if (adSpaces[id].state == State.Unknown) {
            adSpaces[id] = AdSpace({
                created : now,
                owner : owner,
                name : name,
                url : url,
                details : details,
                categories : categories,
                state : state
            });
        } else {
            adSpaces[id] = AdSpace({
                created : adSpaces[id].created,
                owner : (owner.length == 0) ? adSpaces[id].owner : owner,
                name : (bytes(name).length == 0) ? adSpaces[id].name : name,
                url : (bytes(url).length == 0) ? adSpaces[id].url : url,
                details : (bytes(details).length == 0) ? adSpaces[id].details : details,
                categories : (categories.length == 0) ? adSpaces[id].categories : categories,
                state : (state == State.Unknown) ? adSpaces[id].state : state
            });
        }
    }

    /**
    * Set the advertiser offer data
    * if any param comes with a default data value it will not be updated
    *
    * @param id UUID of the advertiser offer
    * @param owner UUID of the user who owns this offer
    * @param name visual representation of the offer
    * @param hitPrice the base unit price of the display of promoted ad
    * @param actionPrice the base unit price of actions undertaking by promoted ad
    * @param details full details of the offer
    * @param categories a list of advertising category ids the offer can be associated with
    * @param state status of the advertiser offer
    */
    function setOffer(bytes16 id, bytes16 owner, string name, uint256 hitPrice, uint256 actionPrice, string details, uint16[] categories, State state) public onlyOwner {
        if (offers[id].state == State.Unknown) {
            offers[id] = Offer({
                created : now,
                owner : owner,
                name : name,
                hitPrice : hitPrice,
                actionPrice : actionPrice,
                details : details,
                categories : categories,
                state : state
            });
        } else {
            offers[id] = Offer({
                created : offers[id].created,
                owner : (owner.length == 0) ? offers[id].owner : owner,
                name : (bytes(name).length == 0) ? offers[id].name : name,
                hitPrice : (hitPrice < 0) ? offers[id].hitPrice : hitPrice,
                actionPrice : (actionPrice < 0) ? offers[id].actionPrice : actionPrice,
                details : (bytes(details).length == 0) ? offers[id].details : details,
                categories : (categories.length == 0) ? offers[id].categories : categories,
                state : (state == State.Unknown) ? offers[id].state : state
            });
        }
    }

    /**
    * Set the hit data
    * if any param comes with a default data value it will not be updated
    *
    * @param id UUID of the hit
    * @param hitType the type of the hit
    * @param session the UUID of the session the hit was performed by
    * @param space the UUID of the advertising space the hit was displayed on
    * @param offer the UUID of the offer the hit was displayed for
    * @param amount the MIT-RA token amount advertiser pays for this hit
    * @param details the full details of the hit
    * @param categories a list of advertising category ids the space can accept for publishing
    * @param state status of the hit
    */
    function setHit(bytes16 id, HitType hitType, bytes16 session, bytes16 space, bytes16 offer, uint256 amount, string details, uint16[] categories, State state) public onlyOwner {
        if (hits[id].state == State.Unknown) {
            hits[id] = Hit({
                created : now,
                session : session,
                space : space,
                offer : offer,
                hitType : hitType,
                amount : amount,
                details : details,
                categories : categories,
                state : state
            });
        } else {
            hits[id] = Hit({
                created : hits[id].created,
                session : (session.length == 0) ? hits[id].session : session,
                space : (space.length == 0) ? hits[id].space : space,
                offer : (offer.length == 0) ? hits[id].offer : offer,
                hitType : (hitType == HitType.Undefined) ? hits[id].hitType : hitType,
                amount : (amount < 0) ? hits[id].amount : amount,
                details : (bytes(details).length == 0) ? hits[id].details : details,
                categories : (categories.length == 0) ? hits[id].categories : categories,
                state : (state == State.Unknown) ? hits[id].state : state
            });
        }
    }
}
