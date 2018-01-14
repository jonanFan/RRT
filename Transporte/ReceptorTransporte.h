//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

#ifndef ReceptorTransporte_H_
#define ReceptorTransporte_H_

#include <omnetpp.h>
#include "Paquetes/Transporte_m.h"
#include "Paquetes/General.h"

using namespace omnetpp;

class ReceptorTransporte: public cSimpleModule {
private:
    int puerto;
    int lenAck;
    bool answerAck;

    /*Statistics*/
    cLongHistogram paqueteTimeStat;
    cOutVector paqueteTimeVector;
protected:
    virtual void handleMessage(cMessage* msg) override;
    virtual void initialize() override;
    Transporte* generarRespuesta(Transporte* peticion);
    void refreshDisplay() const override;
public:
    ReceptorTransporte();
    virtual ~ReceptorTransporte();
};

Define_Module(ReceptorTransporte);

#endif /* ReceptorTransporte_H_ */
