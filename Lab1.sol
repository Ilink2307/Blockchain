// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.28;

//definitie contract
contract GeneralStructure {

    //variabile si constante
    uint public integerVar; // variabila de tip intreg explicit publica
    string stringVar; // variabila de tip string
    address payable public admin; // variabila de tip adresa platibila
    person structVar; // variabila de tip structura
    bool constant boolConst = true; // constanta booleana
    mapping (address => person) public persons; // maparea persoanelor pe baza de adresa

    //declaratie enumerare - valori indexate incepand cu 0
    enum eyecolor {brown, blue, green}

    //definitie structura
    struct person {
        string name;
        uint age;
        bool isMarried;
        eyecolor eyes;
        address payable bankAccount; // modificare camp la tip address platibila
    }

    //declaratie modificator
    modifier onlyBy() {
        require(msg.sender == admin, "Nu esti cine trebuie sa fii"); 
        _;
    }

    function processData(uint[] calldata numbers) external {
        // "numbers" --> calldata
    }

    //declaratie eveniment
    event ageSet(address, uint);

    //definitie constructor
    constructor() {
        admin = payable(msg.sender); // convertire admin la payable
        integerVar = 0;
    }

    //definitie functie
    function createPersonWithAge(
        string memory _name, 
        uint _age, 
        bool _isMarried, 
        eyecolor _eyes
    ) public {
        // instantiere structura cu apelantul ca banca
        structVar = person(_name, _age, _isMarried, _eyes, payable(msg.sender));

        // emitere eveniment pentru setarea varstei
        emit ageSet(msg.sender, structVar.age);

        // stocarea persoanei in mapare folosind adresa apelantului
        persons[msg.sender] = structVar;
        integerVar++;
    }

    // functia care gaseste o persoana dupa adresa si returneaza numele si balanta contului
    function findPerson(address _personAddress) public payable returns (string memory, uint256) {
        require(msg.value >= 1000 wei, "Nu ai trimis suficienti bani!");

        person memory p = persons[_personAddress];
        return (p.name, _personAddress.balance);
    }

    // functia care sterge o persoana pe baza adresei
    function removePerson(address _personAddress) public onlyBy {
        delete persons[_personAddress]; // sterge persoana din mapare
    }

    // private
    function doPureMath(uint a) private pure returns (uint) {
        uint tmp = a + 1; // stocat in memorie
        return tmp + 2;
    }

    // functia getter pentru variabila integerVar
    function getIntegerVar() public view returns (uint) {
        return integerVar;
    }

}
