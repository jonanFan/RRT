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

#ifndef FuenteModif_H_
#define FuenteModif_H_

#include <omnetpp.h>
#include "paquete_m.h"

using namespace omnetpp;

class FuenteModif: public cSimpleModule {
private:
    simtime_t lamda;
    simtime_t startTime;
    int       secuencia;
    cMessage* nuevoEvento;
protected:
    virtual void handleMessage(cMessage* msg) override;
    virtual void initialize() override;
    Paquete* generarPaquete();
public:
    FuenteModif();
    virtual ~FuenteModif();
};

Define_Module(FuenteModif);

#endif /* FuenteModif_H_ */
