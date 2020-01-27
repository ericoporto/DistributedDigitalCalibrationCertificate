pragma solidity ^0.5.11;

// Érico Vieira Porto - 2020
//
// Distributed Digital Calibration Certificate

// 
//   O padrão internacional ISO/IEC 17025, que trata dos requerimentos gerais para
// laboratórios de calibração é o documento de referência ao qual órgãos metrológicos
// ao redor do mundo [1][2][3]. Os itens 7.8.2 traz os requerimentos gerais para
// relatórios e o item 7.8.4 traz os requerimentos específicos para certificados de
// calibração, de forma objetiva, e o item 8 traz os requerimentos mínimos de gestão
// de documentação. Já o ISO GUM, Guides to the experession of Uncertainty in
// Measurement, define o vocabulário a ser utilizado nos documentos que comuniquem a
// incerteza de instrumentos de medição em língua inglesa - em português, a tradução
// oficialmente aceita é o VIM, o Vocabulário Internacional de Metrologia [6]. 
//
//   Há algum tempo é buscado um registro digital de dados de calibração, havendo
// propostas de formato de dados padrão [7][8] que reiteram a importância dos dados
// relevantes em meio digital no avanço da indústria [9]. Porém, nos trabalhos
// correntes não tem se buscado a garantia da imutabilidade dos dados, o registro
// perene, sistemática de assinaturas digitais para garantia de responsabilidade de
// usuários, e ainda, todos os esforços se apoiam a instituições de abrangência local
// ou nacional, de forma que a sistematização não poderia ser aproveitada.
//
//   Na implementação de conceito aqui apresentada, é apresentado um código que se
// aproveita da Block-chain do Ethereum para materializar a visão de Certificados de
// Calibração Digitais Distribuídos, ou Distributed Digital Calibration Certificates.
// Nesse trabalho, os certificados de calibração emitidos por um laboratório estão
// armazenados em um contrato inteligente, onde o hash desse contrato identifica
// unicamente o laboratório. Os equipamentos a serem calibrados tem seu fabricante e
// código serial aplicados um hash keccak256, que unifica sua identificação através
// dos contratos dos diversos laboratórios. Uma estrutura de dados simples registra
// os dados da medição realizadas no processo de calibração e o responsável pela
// calibração é identificado pela sua carteira na rede Ethereum. Datas são
// registradas de forma automática e inviolável, garantindo rastreio em casos de
// exigência legal que determinem prazos de calibração. Ainda, um sistema simples
// gerencia as permissões entre os integrantes do laboratório.
//
//
//
// [1] https://web.archive.org/web/20190618204442/https://www.iso.org/ISO-IEC-17025-testing-and-calibration-laboratories.html
// [2] https://web.archive.org/web/20190503113315/https://www.ptb.de/cms/en/ptb/ptb-management/pstab/pst2/pst2qualitaetsmanagementsystem.html
// [3] https://web.archive.org/web/20191211014257/http://www4.inmetro.gov.br/acreditacao/servicos/acreditacao
// [4] https://web.archive.org/web/20191206053325/https://www.nist.gov/nist-quality-system
// [5] https://web.archive.org/web/20190524204206/http://www.iso.org/sites/JCGM/GUM-introduction.htm
// [6] https://web.archive.org/web/20170330030916/http://www.inmetro.gov.br/metcientifica/vim/vimGum.asp
// [7] https://web.archive.org/web/20191211014509/https://us.flukecal.com/literature/articles-and-education/electrical-calibration/white-paper/proposal-standard-calibration-d
// [8] http://web.archive.org/web/20191211015214/https://cfmetrologie.edpsciences.org/articles/metrology/pdf/2019/01/metrology_cim2019_01002.pdf
// [9] http://web.archive.org/web/20191211015141/https://www.researchgate.net/publication/328892483_Calibration_for_Industry_40_Metrology_Touchless_Calibration
// 

//   The idea of this project is any laboratory can deploy this contract and use it to store 
// it's calibration certificates in descentralized manner.
//
//   Even though different laboratories have to register the equipment data on their own storage,
// their IDs are deterministic and should be the same accross different contracts as long as the
// same string is used. Equipment should only be registered on demand - when needed for a certificate,
// so just in time instead of just in case.
//
//   The person who deploys this contract is included in the admin group of the Laboratory. An
// admin can authorize and deauthorize a person (preferably a metrologist in the Laboratory) to
// be able to issue calibration certificates.
//
//   The association of which address of a deployed LaboratoryCalibrationCertificateStorage with 
// the actual name of the laboratory is assumed to be stored off-chain, since there's no mechanism
// to verify truth currently that is not centralized.
// 
// Note: Currently this contract requires the deploy be set with at least 3100000 as gas limit

 
contract LaboratoryCalibrationCertificateStorage { 

    // an specific physical equipment unit, identified by a serial number (despite the name, 
    // serial numbers are usually alphanumeric). 
    // Note: we also store which certificates this unit has stored in this laboratory contract.
    // Ex: S/N 228-E632
    struct SerialCode {
        string serial;
        uint[] certificates;
    }

    // Data for a equipment 
    //   An equipment name is the unique identifier that the manufacturer uses to refer to an 
    // specific unit but not an specific manufactured unit.
    // Ex: Anton Paar manufactures the LDENS-427 densitometer. LDENS-427 is the name of the equipment.
    // LG manufactures the 65UM7520PSB TV. 65UM7520PSB is the name of the equipment.
    struct Equipment {
        string name;
        uint[] serialIDs; // a list of serial IDs of this equipment available
        
        mapping ( uint => SerialCode )  serials; //   maps a serial ID to the struct with data of that 
                                                 // specific equipment unit (including actual serial number)
    }

    // Manufacturer data
    //   The company name of the manufacturer of equipments.
    // Ex: Anton Paar makes densitometers. Anton Paar is the name of the manufacturer.    
    struct Manufacturer {
        string name;
        uint[] equipmentIDs;
        
        mapping ( uint => Equipment )  equipments;
    }

    uint[] manufacturersID; // list of manufacturers ID, useful for traversing registered manufacturers
    mapping ( uint => Manufacturer ) manufacturers; // stores the Manufacturer data, it's name and equipments.

    // the minimal data to identify the object of a calibration.
    struct Object {
        uint manufacturerID;
        uint equipmentID;
        uint serialID;
    }
    
    // A struct to store a float number
    struct Real {
        uint value; // ex: for 0.95, we store 95 here
        uint8 decimalPlaces; // ex: for 0.95, we store 2 here.
    }

    // The calibration data, including the point of measurement (value) and the uncertainty obtained.
    struct MeasurementData {
        string unit; // The measurement unit: m for meters, kg for kilograms, s for seconds. Preferably SI units.
        Real value; // The reading on the calibrated equipment for a specific measured point.
        Real uncertainty; // The uncertainty for this specific measurement.
        Real coverageFactor; // Coverage Factor as defined on ISO GUM.
        Real coverageProbability; // The coverage probability, also known as level of confidence of the interval.
        uint dateTime; // this specific point register moment, in unix timestamp.
        
        // NOTE: coverageFactor : numerical factor k used as a multiplier of the combined
        // standard uncertainty in order to obtain an expanded uncertainty.
    }
    
    // The data on the Digital Calibration Certificate
    struct CalibrationData {
        address responsible; // who is responsible by the calibration
        Object object; // what I am calibrating
        uint dateTime; // moment (unix timestamp) the certificate was requested to register in the chain.
        
        // mapping instead of array to prevents UnimplementedFeatureError when pushing a struct from memory[] to storage.
        uint measurementCount;
        mapping ( uint => MeasurementData )  measurements;
    }

    // The actual certificates 
    CalibrationData[] certificates;

    // Very simple user register to store priveledges
    
    //    authorized users can register manufacturers, equipments, serial numbers, 
    // and certificates and add measurement data to a certificate.
    mapping (address => bool) IsUserAuthorized; 
    
     //   administrative users can authorize and deauthorize users and also turn 
     // users in administrators.
    mapping (address => bool) IsUserAdmin;

    //   Note: an admin has to explicitly authorize him/herself to be able to store calibration 
    // certificates and data on equipments and manufacturers, if needed.
    modifier OnlyAuthorizedUser () {
        require(IsUserAuthorized[msg.sender],"You are not authorized to store certificates on this contract.");
        _; 
    } 

    modifier OnlyAdmin () {
       require(IsUserAdmin[msg.sender],"This action requires administrative priveledges.");
        _;
    }

    // whoever deploys this contract is authomatically turned an administrator
    constructor () public {
        IsUserAdmin[msg.sender] = true;
    }
    
    // <---- Getters, anyone can use them -------------------------------------------------------------------------- 
    // They don't modify the data stored in the ethereum blockchain
    
    // use the count Functions to predict how many elements are stored of a type
    // and then traverse from index 0 with this information to retrieve the IDs
    // Finally you can use the IDs to retrieve information.
    // This pattern is useful to fill comboboxes or similar UI with information.
    
    function GetManufacturerCount() public view returns (uint) {
        return manufacturersID.length;
    }
    
    function GetManufacturerIDbyIndex(uint _index) public view returns (uint) {
        return manufacturersID[_index];
    }
    
    function GetManufacturerNameByID(uint _manufacturerID) public view returns (string memory) {
        return manufacturers[_manufacturerID].name;
    }
    
    function GetEquipmentCount(uint _manufacturerID) public view returns (uint) {
        return manufacturers[_manufacturerID].equipmentIDs.length;
    }
    
    function GetEquipmentIDbyIndex(uint _manufacturerID, uint _index) public view returns (uint) {
        return manufacturers[_manufacturerID].equipmentIDs[_index];
    }
    
    function GetEquipmentNameByID(uint _manufacturerID, uint _equipmentID) public view returns (string memory) {
        return manufacturers[_manufacturerID].equipments[_equipmentID].name;
    }
    
    function GetSerialCount(uint _manufacturerID, uint _equipmentID ) public view returns (uint) {
        return manufacturers[_manufacturerID].equipments[_equipmentID].serialIDs.length;
    }
    
    function GetSerialIDbyIndex(uint _manufacturerID, uint _equipmentID, uint _index) public view returns (uint) {
        return manufacturers[_manufacturerID].equipments[_equipmentID].serialIDs[_index];
    }
    
    function GetSerialByID(uint _manufacturerID, uint _equipmentID, uint _serialID) public view returns (string memory) {
        return manufacturers[_manufacturerID].equipments[_equipmentID].serials[_serialID].serial;
    }
    
    function GetCertificateMeasurementCount(uint _certificateID) public view returns (uint) {
        return certificates[_certificateID].measurementCount;
    }
    
    function GetCertificateMeasurement(uint _certificateID, uint _measurementIndex) 
        public view returns 
        (string memory, uint, uint8, uint, uint8, uint, uint8, uint, uint8, uint) {
            
        MeasurementData memory measure = certificates[_certificateID].measurements[_measurementIndex];
        return (measure.unit, 
                measure.value.value,               measure.value.decimalPlaces, 
                measure.uncertainty.value,         measure.uncertainty.decimalPlaces, 
                measure.coverageFactor.value,      measure.coverageFactor.decimalPlaces, 
                measure.coverageProbability.value, measure.coverageProbability.decimalPlaces, 
                measure.dateTime);
    }
    
    function GetCertificate(uint _ID) public view returns (address, uint, uint, uint, uint) {
        return (certificates[_ID].responsible, 
                certificates[_ID].object.manufacturerID, 
                certificates[_ID].object.equipmentID, 
                certificates[_ID].object.serialID, 
                certificates[_ID].dateTime );
    }
    
    function GetCertificateCount() public view returns (uint) {
        return certificates.length;
    }
    
    function GetCertificateCountByObject(uint _objectManufacturerID, 
                                        uint _objectEquipmentID, 
                                        uint _objectSerialID) public view returns (uint) {
        return manufacturers[_objectManufacturerID].equipments[_objectEquipmentID].serials[_objectSerialID].certificates.length;
    }
        
    function GetCertificateIDByObject(uint _objectManufacturerID,
                                      uint _objectEquipmentID, 
                                      uint _objectSerialID, 
                                      uint _index) public view returns (uint) {
        return manufacturers[_objectManufacturerID].equipments[_objectEquipmentID].serials[_objectSerialID].certificates[_index];
    }
    
    // >---- end of Getters ------------------------------------------------------------------------------------ 
    
    // <---- User Priveledge Tests -----------------------------------------------------------------------------
    
    function TestIsUserAdmin(address _user) public view returns (bool) {
        return IsUserAdmin[_user];
    }
    
    function TestIsUserAuthorized(address _user) public view returns (bool) {
        return IsUserAuthorized[_user];
    }
    
    // >---- end of User Priveledge Tests ---------------------------------------------------------------------- 
    
    // <---- Functions to register Manufacturer, Equipment and Serial Number -----------------------------------
    
    function NewManufacturer(string memory _manufacturerName)
             public OnlyAuthorizedUser returns (uint) {
                 
       uint _new_id;
       _new_id = uint(keccak256(abi.encode(_manufacturerName)));
       
       // we only go through if manufacturer is not already initialized
       bytes memory _manufacturerNameAsBytes = bytes(manufacturers[_new_id].name);
       require( _manufacturerNameAsBytes.length <= 0, "This manufacturer is already registered."); 
              
       
       manufacturers[_new_id].name = _manufacturerName;
       manufacturersID.push(_new_id);
       return _new_id;
    }
    
    function NewEquipment(uint _manufacturerID, string memory _equipmentName) 
             public OnlyAuthorizedUser returns (uint) {
                 
       uint _new_id;
       _new_id = uint(keccak256(abi.encode(_equipmentName)));
       
       // we only go through if equipment is not already initialized
       bytes memory _equipmentNameAsBytes = bytes(manufacturers[_manufacturerID].equipments[_new_id].name);
       require( _equipmentNameAsBytes.length <= 0, "This equipment is already registered."); 
              
       manufacturers[_manufacturerID].equipments[_new_id].name = _equipmentName;
       manufacturers[_manufacturerID].equipmentIDs.push(_new_id);
       return _new_id;
    }
    
    function NewSerial(uint _manufacturerID, uint _equipmentID, string memory _serial) 
             public OnlyAuthorizedUser returns (uint) {
                 
       uint _new_id;
       _new_id = uint(keccak256(abi.encode(_serial)));
       
       // we only go through if serial is not already initialized
       bytes memory _serialAsBytes = bytes(manufacturers[_manufacturerID].equipments[_equipmentID].serials[_new_id].serial);
       require( _serialAsBytes.length <= 0, "This unit serial is already registered."); 
              
       manufacturers[_manufacturerID].equipments[_equipmentID].serials[_new_id].serial = _serial;
       manufacturers[_manufacturerID].equipments[_equipmentID].serialIDs.push(_new_id);
       return _new_id;
    }
    
    // >---- end of Functions to register Manufacturer, Equipment and Serial Number ----------------------------
    
    // <---- Functions to store a calibration certificate ------------------------------------------------------
    
    
    // This function actually instantiates a certificate tied to an specific equipment and this contract, 
    // and can only be executed by and authorized user.
    // The actual calibration data has to be added later to the certificate ID returned by this function.
    // Calibration data can only be added by the user who stored this certificate and only until 5 days of it's publication date.
    function Certify(uint _objectManufacturerID,
                     uint _objectEquipmentID,
                     uint _objectSerialID) OnlyAuthorizedUser public returns (uint) {
        CalibrationData memory _certificate;
        _certificate.responsible = msg.sender;
        _certificate.object.manufacturerID = _objectManufacturerID;
        _certificate.object.equipmentID = _objectEquipmentID;
        _certificate.object.serialID = _objectSerialID;
        _certificate.dateTime = now;
        
        certificates.push(_certificate);
        
        uint _certificateIndex = certificates.length - 1;
        
        manufacturers[_objectManufacturerID].equipments[_objectEquipmentID].serials[_objectSerialID].certificates.push(_certificateIndex);
        
        return _certificateIndex;
    }

    // Adds a the actual calibration measurements to the certificate
    function AddMeasurementToCertificate(uint _certificateID, string memory _measurement_unit, 
    uint _value, uint8 _value_fp, 
    uint _uncertainty, uint8 _uncertainty_fp, 
    uint _coverageFactor, uint8 _coverageFactor_fp, 
    uint _coverageProbability, uint8 _coverageProbability_fp) public OnlyAuthorizedUser {
        
        MeasurementData memory _measure;
        require(msg.sender == certificates[_certificateID].responsible, 
                "Only the responsible by this certificate can add measurements to it.");
        require(now < certificates[_certificateID].dateTime + 5 days, 
                "This certificate has been emitted for more than five days, you can't add measurements after this time.");
        
        _measure.unit = _measurement_unit;
        _measure.value.value = _value;
        _measure.value.decimalPlaces = _value_fp;
        
        _measure.uncertainty.value = _uncertainty;
        _measure.uncertainty.decimalPlaces = _uncertainty_fp;
        
        _measure.coverageFactor.value = _coverageFactor;
        _measure.coverageFactor.decimalPlaces = _coverageFactor_fp;
        
        _measure.coverageProbability.value = _coverageProbability;
        _measure.coverageProbability.decimalPlaces = _coverageProbability_fp;
        
        _measure.dateTime = now;
        
        uint _measurementCount = certificates[_certificateID].measurementCount;
        
        certificates[_certificateID].measurements[_measurementCount] = _measure;
        
        certificates[_certificateID].measurementCount = _measurementCount + 1;
    }

    // >---- end of Functions to store a calibration certificate -----------------------------------------------
    
    // <---- Functions to modify user priviledges --------------------------------------------------------------
    //
    // The user who deployed this contract is made an administrator by the constructor
    // An admin can authorize or deauthorize any user. An admin can also turn a person an admin or remove his/her rights.
    // Only authorized users can publish calibration certificates and register equipments on this contract

    function AuthorizeUser (address _userAddress) public OnlyAdmin {
        IsUserAuthorized[_userAddress] = true;
    }

    function DeauthorizeUser (address _userAddress) public OnlyAdmin {
        IsUserAuthorized[_userAddress] = false;
    }

    function PromoteUserToAdmin (address _userAddress) public OnlyAdmin {
        IsUserAdmin[_userAddress] = true;
    }

    function DemoteUserFromAdmin (address _userAddress) public OnlyAdmin {
        IsUserAdmin[_userAddress] = false;
    } 
    
    // >---- end of Functions to modify user priviledges -------------------------------------------------------
}


