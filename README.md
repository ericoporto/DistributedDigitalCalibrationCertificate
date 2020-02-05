# DistributedDigitalCalibrationCertificate

### Distributed Digital Calibration Certificate written in Solidity for Ethereum Blockchain

The international standard ISO/IEC 17025, which deals with the general 
requirements for calibration laboratories, is the reference document used by 
important reference laboratories around the world, like the *Physikalisch-Technische 
Bundesanstalt* (PTB), the *Instituto Nacional de Metrologia, Qualidade e Tecnologia* 
(INMETRO), and the National Institute of Standards and Technology (NIST) [[1]][[2]][[3]][[4]].
The items 7.8.2  and 7.8.4 - Common requirements for reports (test, calibration or 
sampling) and Specific requirements for calibration certificates - are 
objective in defining what is required on a calibration certificate, and item 8
adds minimal requirements for management system for assuring the quality of the
laboratory results. The ISO GUM, Guides to the Expression of Uncertainty in Measurement,
defines, among other things, the vocabulary to be used in documents that deals with
expressing uncertainty in measurement[[5]]. We are going to use these documents to 
guide the requirements for what needs to be implemented in our code product,
and the language we should use in it's API and the code itself when appropriate.
Languages different than English usually provide their translation of the ISO GUM,
as an example in Portuguese, the *Vocabulário Internacional de Metrologia*, VIM,
is provided[[6]].

Research in creating a registry or a format for digital calibration certificates
has existed for some time now [[7]][[8]], businesses in the industry have shown 
needs for digital traceable data on their measurement instruments to achieve the 
digitization of manufacturing, required to meet their customers expectations [[9]].
Unfortunately, in available works, it's not a main concern that the certificate be
tamper-proof, with data immutability, ensuring the responsabilities for the measurement
are traceable, and not dependant on a central, local or national institution of
trust, making the in development systems hard to have global reach.

The proof of concept implementation presented here uses the Ethereum Block-chain
to materialize a vision on Distributed Digital Calibration Certificates. In this
work, the calibration certificates produced by a laboratory are stored in a Smart
Contract, where it's deployed instance hash is tied to uniquely indentify this
laboratory. Equipments calibrated have it's describing information like manufacturer,
model and serial number individually hashed using the keccak256 algorithm, which
unifies it's identification accross different calibration certificates allowing
a fast assessment of data on an instrument accross the smart contracts of the
different laboratories you trust. 

The calibration technician and involved personal are uniquely identified by their 
Ehtereum wallets, which naturally uses asymmetric encryption through a public 
identifiable key and a private one only known by the owner. A simple data structure 
is used to store this data in a digital calibration report in the Ethereum 
Block-chain, locking the report from tampering. The precise hour and date is also
stored in automatic and immutable manner, enabling traceability when there is need
for defined periodic calibration due to legal requirements or security requirements.
A simple system to manage the permissions of laboratory personel is also implemented.

[1]:https://web.archive.org/web/20190618204442/https://www.iso.org/ISO-IEC-17025-testing-and-calibration-laboratories.html
[1] https://web.archive.org/web/20190618204442/https://www.iso.org/ISO-IEC-17025-testing-and-calibration-laboratories.html

[2]:https://web.archive.org/web/20190503113315/https://www.ptb.de/cms/en/ptb/ptb-management/pstab/pst2/pst2qualitaetsmanagementsystem.html
[2] https://web.archive.org/web/20190503113315/https://www.ptb.de/cms/en/ptb/ptb-management/pstab/pst2/pst2qualitaetsmanagementsystem.html

[3]:https://web.archive.org/web/20191211014257/http://www4.inmetro.gov.br/acreditacao/servicos/acreditacao
[3] https://web.archive.org/web/20191211014257/http://www4.inmetro.gov.br/acreditacao/servicos/acreditacao

[4]:https://web.archive.org/web/20191206053325/https://www.nist.gov/nist-quality-system
[4] https://web.archive.org/web/20191206053325/https://www.nist.gov/nist-quality-system

[5]:https://web.archive.org/web/20190524204206/http://www.iso.org/sites/JCGM/GUM-introduction.htm
[5] https://web.archive.org/web/20190524204206/http://www.iso.org/sites/JCGM/GUM-introduction.htm

[6]:https://web.archive.org/web/20170330030916/http://www.inmetro.gov.br/metcientifica/vim/vimGum.asp
[6] https://web.archive.org/web/20170330030916/http://www.inmetro.gov.br/metcientifica/vim/vimGum.asp

[7]:https://web.archive.org/web/20191211014509/https://us.flukecal.com/literature/articles-and-education/electrical-calibration/white-paper/proposal-standard-calibration-d
[7] https://web.archive.org/web/20191211014509/https://us.flukecal.com/literature/articles-and-education/electrical-calibration/white-paper/proposal-standard-calibration-d

[8]:https://web.archive.org/web/20191211015214/https://cfmetrologie.edpsciences.org/articles/metrology/pdf/2019/01/metrology_cim2019_01002.pdf
[8] https://web.archive.org/web/20191211015214/https://cfmetrologie.edpsciences.org/articles/metrology/pdf/2019/01/metrology_cim2019_01002.pdf

[9]:https://web.archive.org/web/20191211015141/https://www.researchgate.net/publication/328892483_Calibration_for_Industry_40_Metrology_Touchless_Calibration
[9] https://web.archive.org/web/20191211015141/https://www.researchgate.net/publication/328892483_Calibration_for_Industry_40_Metrology_Touchless_Calibration




[Read the source...](https://github.com/ericoporto/DistributedDigitalCalibrationCertificate/blob/master/DistributedDigitalCalibrationCertificate.sol)
