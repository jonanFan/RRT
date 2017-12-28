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

#ifndef RECEPTOR_H_
#define RECEPTOR_H_

#include <omnetpp.h>
#include "paquete_m.h"

using namespace omnetpp;

class Receptor: public cSimpleModule {
private:
    cChannel* txChannel;
    cQueue*   txQueue;
    cMessage* enviarMensajeEvento;
    double       probPacketLoss;
    double       probAckLoss;
    double       lenAck;
protected:
    virtual void handleMessage(cMessage* msg) override;
    virtual void initialize() override;
    Paquete* generarPaquete(int error, unsigned int secuencia, simtime_t timestamp);
public:
    Receptor();
    virtual ~Receptor();
};

Define_Module(Receptor);


#endif /* RECEPTOR_H_ */
