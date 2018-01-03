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

#include "FuenteModif.h"

FuenteModif::FuenteModif() {
    // TODO Auto-generated constructor stub
    this->secuencia = 0;
    this->nuevoEvento = new cMessage();
}

FuenteModif::~FuenteModif() {
    // TODO Auto-generated destructor stub
    cancelAndDelete(nuevoEvento);
}

void FuenteModif::initialize() {
    this->startTime = par("startTime");
    this->lamda = par("lambda");
    scheduleAt(startTime, nuevoEvento);
}

void FuenteModif::handleMessage(cMessage* msg) {

    send(generarPaquete(), "out");
    try {

        scheduleAt(simTime()+ exponential(lamda), nuevoEvento);
    } catch (cException e) {
        delete(msg);
    }
}

Paquete* FuenteModif::generarPaquete() {
    char nombre[15];
    double tamPkt = par("tamPaquete");
    sprintf(nombre, "msg-%d", secuencia);
    Paquete* msg = new Paquete(nombre, 0);
    msg->setSecuencia(secuencia++);
    msg->setBitLength(exponential(tamPkt));
    msg->setTimestamp(simTime());

    return msg;
}
