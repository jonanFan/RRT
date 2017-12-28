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

#ifndef STOPWAIT_H_
#define STOPWAIT_H_

#include <omnetpp.h>
#include "paquete_m.h"

using namespace omnetpp;

class StopWait: public cSimpleModule {
private:
     double    lenACK;
     cDatarateChannel* txChannel;
     cQueue*   txQueue;
     cMessage* enviarMensajeEvento;
     cMessage* timeoutEvento;
     cMessage* setTimeoutEvento;
     Paquete*  mensajeEnviado;
protected:
    virtual void handleMessage(cMessage* msg) override;
    virtual void initialize() override;
    void sendCopyOf(Paquete* paquete);
public:
    StopWait();
    virtual ~StopWait();
};

Define_Module(StopWait);

#endif /* STOPWAIT_H_ */
