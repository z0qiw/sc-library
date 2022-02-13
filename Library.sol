// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract Library {

    event AvailableBook(uint id, string name, uint8 copiesLeft);
    event CheckUserBook(uint userId, uint bookId, address usrAddr);
    event UserAdresses(address usrAddr); 

    struct Book {
        uint id;
        string name;
        uint8 numCopiesLeft;
        uint8 numCopiesBorrowed;
    }

    struct BookArray {
        uint[] bookId;
    }

    struct BookHolder {
        uint book;
        address bookHolderAddress;
    }

    mapping(uint => BookArray) userBook;
    mapping(uint => address) public userAddress;
    uint userCounter;

    BookHolder[] public bookHolder;

    Book[] public books;

    function addBook(string memory _name, uint8 _numCopies) public {
        uint id = books.length;
        books.push(Book({id: id, name: _name, numCopiesLeft: _numCopies, numCopiesBorrowed: 0}));
    }

    function showAvailableBooks() public {
        for (uint i = 0; i < books.length; i++) {
            if (books[i].numCopiesLeft > 0) {
                emit AvailableBook(books[i].id, books[i].name, books[i].numCopiesLeft);
            }
        }
    }

    function showAllBooks() public {
        for (uint i = 0; i < books.length; i++) {
            emit AvailableBook(books[i].id, books[i].name, books[i].numCopiesLeft);
        }
    }
    function borrowBookById(uint id, address payable userAddr) public payable returns(bool) {
        if(takeBookFromLibrary(id) == false) {
            return false;
        }

        if(giveBookToUser(id, userAddr) == false) {
            returnBookToLibrary(id);
            return false;
        }

        for (uint i = 0; i < bookHolder.length; i++) {
            if (bookHolder[i].book == id) {
                return true;
            }
        }
        bookHolder.push(BookHolder({book: id, bookHolderAddress: userAddr}));

        return true;
    }

    function checkBookBorrowers(uint id) public {
        for(uint i = 0; i < bookHolder.length; i++) {
            if (id == bookHolder[i].book) {
                emit UserAdresses(bookHolder[i].bookHolderAddress);
            }
        }
    }

    function takeBookFromLibrary(uint id) public returns(bool) {
        for (uint i = 0; i < books.length; i++) {
            if ((books[i].numCopiesLeft > 0) && (books[i].id == id)) {
                require(
                    books[i].numCopiesLeft != 0,
                    "No more copies of this book available"
                );
                books[i].numCopiesLeft -= 1;
                books[i].numCopiesBorrowed += 1;
                return true;
            }
        }
        return false;
    }

    function returnBook(uint id, address userAddr) public returns(bool) {
        if(takeBookFromUser(id, userAddr) == false) {
            return false;
        }

        if(returnBookToLibrary(id) == false) {
            return false;
        }

        return true;
    }    

    function returnBookToLibrary(uint id) public returns(bool) {
        for (uint i = 0; i < books.length; i++) {
            if (books[i].id == id) {
                books[i].numCopiesLeft += 1;
                books[i].numCopiesBorrowed -= 1;
                return true;
            }
        }
        return false;
    }

    function giveBookToUser(uint id, address userAddr) public returns(bool) {
        uint i;
        uint j;
        for (i = 1; i < userCounter + 1; i++) {
            if (userAddress[i] == userAddr) {
                for (j = 0; j < userBook[i].bookId.length; j++) {
                    require(
                        id != userBook[i].bookId[j],
                        "The user already posess this book"
                    );                    
                    if (userBook[i].bookId[j] == 0xFF) {
                        userBook[i].bookId[j] = id;
                        return true;
                    }
                }
                userBook[i].bookId.push(id);
                return true;
            }
        }
        return false;
    }

    function takeBookFromUser(uint id, address userAddr) public returns(bool) {
        uint i;
        uint j;
        for (i = 1; i < userCounter + 1; i++) {
            if (userAddr == userAddress[i]) {
                for (j = 0; j < userBook[i].bookId.length; j++) {                    
                    if (userBook[i].bookId[j] == id) {
                        userBook[i].bookId[j] = 0xFF;
                        return true;
                    }
                }
            }
        }

        return false;
    }

    function checkUserBook(uint userBookId) public {
        uint j;
        for (j = 0; j < userBook[userBookId].bookId.length; j++) {
            emit CheckUserBook(userBookId, userBook[userBookId].bookId[j], userAddress[userBookId]);
        }
    } 

    function addUser(address userAddr) public {
        userCounter++;
        userAddress[userCounter] = userAddr;
        userBook[userCounter].bookId.push(0xFF);
    }
}
